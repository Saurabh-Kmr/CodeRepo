@SuppressWarnings('PMD.ApexSOQLInjection,PMD.CognitiveComplexity,PMD.ApexCRUDViolation')
public without sharing class RuleServiceImpl extends SunrunAwsService implements RuleService {
  private static String ruleStatusField = 'Rule_Status__c';
  private static String ruleMessageField = 'Rule_Message__c';
  private static String ruleStateField = 'Rule_State__c';
  private static String targetSobjField = 'Sobject__c';

  public RuleServiceImpl() {
    super('RuleServiceBaseUrl', 'RuleServiceApiKey');
  }

  public RuleDto.EvaluateResp evaluate(RuleDto.EvaluateReq req) {
    return ((RuleDto.EvaluateResp) post('/evaluate', req, RuleDto.EvaluateResp.class)).init();
  }

  public RuleDto.ValidateResp validate(RuleDto.ValidateReq req) {
    return ((RuleDto.ValidateResp) post('/validate', req, RuleDto.ValidateResp.class)).init();
  }

  private List<String> validateFields(String sobj, List<String> fields) {
    for (String field : fields) {
      String fieldSoBrackets = field.replaceAll('\\[\\]', '');

      try {
        if (fieldSoBrackets.startsWithIgnoreCase('User.')) {
          Ut.describeField('User', Ut.removePrefix(fieldSoBrackets, 'User.'));
        } else {
          Ut.describeField(sobj, fieldSoBrackets);
        }
      } catch (Exception e) {
        throw new ValException('Invalid field [' + (field.startsWith('User.') ? '' : sobj + '.') + field + ']. ' + e.getMessage(), e);
      }
    }

    return fields;
  }

  public List<String> getRuleFields(List<Id> ruleRecIds) {
    List<Sobject> recs = Database.query('select ' + ruleStateField + ' from ' + Ut.getSobjName(ruleRecIds.get(0)) + ' where id in :ruleRecIds');
    List<String> fields = new List<String>();

    for (Sobject rec : recs) {
      RuleDto.RuleState state = String.isBlank(Ut.getValueString(rec, ruleStateField))
        ? null
        : (RuleDto.RuleState) JSON.deserialize(Ut.getValueString(rec, ruleStateField), RuleDto.RuleState.class);
      if (state != null) {
        fields.addAll(state.fields);
      }
    }

    return Ut.dedupeIc(fields);
  }

  public Map<String, String> buildSoqls(String sobj, List<String> ruleFields) {
    Map<String, String> soqls = new Map<String, String>();
    if (ruleFields.isEmpty()) {
      return soqls;
    }

    List<String> userFlds = new List<String>();
    List<String> mainFlds = new List<String>();

    for (String fld : ruleFields) {
      if (fld.startsWithIgnoreCase('User.')) {
        userFlds.add(Ut.removePrefix(fld, 'User.'));
      } else {
        mainFlds.add(fld);
      }
    }

    soqls.put(sobj, 'select ' + Ut.joinCsv(buildSoqlFields(mainFlds)) + ' from ' + sobj);
    if (!userFlds.isEmpty()) {
      soqls.put('User', 'select ' + Ut.joinCsv(buildSoqlFields(userFlds)) + ' from User');
    }

    return soqls;
  }

  public Map<String, Object> buildDataMap(List<Id> ruleRecIds, Id dataRecId) {
    String targetSobj = Ut.getSobjName(dataRecId);

    Map<String, String> soqls = buildSoqls(targetSobj, getRuleFields(ruleRecIds));
    Map<String, Object> data = new Map<String, Object>();

    String mainSoql = soqls.get(targetSobj);
    if (String.isNotBlank(mainSoql)) {
      List<Sobject> sobjs = Database.query(mainSoql + ' where id = :dataRecId');
      if (!sobjs.isEmpty()) {
        data.putAll(sobjs.get(0).getPopulatedFieldsAsMap());
      }
    }

    String userSoql = soqls.get('User');
    if (String.isNotBlank(userSoql)) {
      Id userId = UserInfo.getUserId();
      List<Sobject> sobjs = Database.query(userSoql + ' where id = :userId');
      data.put('User', sobjs.get(0).getPopulatedFieldsAsMap());
    }

    return data;
  }

  public void handleBeforeTrigger(TriggerDto.Context info, RuleDto.ProcessRuleConfig config) {
    // In the before trigger we need to set the Rule status as Pending.
    List<Sobject> updatedRecs = new List<Sobject>();
    for (Sobject nrec : info.newList) {
      Sobject orec = info.getOld(nrec.id);
      // We will process if rule fields are changed
      if (Ut.isChanged(orec, nrec, config.ruleExpressionFields, true)) {
        nrec.put(ruleStatusField, 'Pending');
      }
    }
  }

  public void handleAfterTrigger(TriggerDto.Context info, RuleDto.ProcessRuleConfig config) {
    List<Sobject> recs = Ut.filter(info.newList, ruleStatusField, 'Pending');
    if (!recs.isEmpty()) {
      System.enqueueJob(new RuleProcessJob(new RuleDto.ProcessRuleReq(config, Ut.getIdList(recs))));
    }
  }

  public void processRules(RuleDto.ProcessRuleReq req) {
    List<Sobject> recs = queryRecords(req);
    try {
      RuleDto.ValidateReq vreq = new RuleDto.ValidateReq();

      for (Sobject rec : recs) {
        for (String field : req.config.ruleExpressionFields) {
          vreq.addRule(rec.id + '-' + field, (String) rec.get(field));
        }
      }

      RuleDto.ValidateResp resp = validate(vreq);

      for (Sobject rec : recs) {
        List<String> fields = new List<String>();
        String errorMessage = '';
        String errorStack = '';

        for (String field : req.config.ruleExpressionFields) {
          RuleDto.ValidateRespRule rule = resp.rulesMap.get(rec.id + '-' + field);
          if (rule.valid) {
            fields.addAll(rule.vars);
          } else {
            errorMessage += ' ' + field + ' [' + rule.errorMessage + ']';
          }
        }

        List<String> nonIgnoredFields = new List<String>();
        if (req.config.ignoreFields != null && !req.config.ignoreFields.isEmpty()) {
          for (String field : fields) {
            if (!req.config.ignoreFields.contains(field)) {
              nonIgnoredFields.add(field);
            }
          }
        } else {
          nonIgnoredFields = fields;
        }

        try {
          validateFields((String) rec.get(targetSobjField), nonIgnoredFields);
        } catch (Exception e) {
          errorMessage += ' ' + e.getMessage();
          errorStack = Ut.getStackTrace(e);
        }

        RuleDto.RuleState state = new RuleDto.RuleState();
        state.allFields = fields;
        state.fields = nonIgnoredFields;
        state.soqls = buildSoqls((String) rec.get(targetSobjField), nonIgnoredFields);
        state.message = Ut.nullIfBlank(errorMessage);
        state.stacktrace = Ut.nullIfBlank(errorStack);

        rec.put(ruleStateField, JSON.serializePretty(state));
        rec.put(ruleStatusField, String.isBlank(errorMessage) ? 'Valid' : 'Error');
        rec.put(ruleMessageField, String.isBlank(errorMessage) ? null : Ut.truncateToText(errorMessage));
      }
    } catch (Exception e) {
      Map<String, Object> values = Ut.mapOf(
        ruleStatusField,
        'Error',
        ruleMessageField,
        Ut.truncateToText(e.getMessage()),
        ruleStateField,
        Json.serializePretty(new RuleDto.RuleState(e.getMessage(), Ut.getStackTrace(e)))
      );

      Ut.setValue(recs, values);
    }

    update recs;
  }

  private List<Sobject> queryRecords(RuleDto.ProcessRuleReq req) {
    List<Id> recordIds = req.recordIds;
    String fields = targetSobjField + ', ' + Ut.joinCsv(req.config.ruleExpressionFields);
    String soql = 'select ' + fields + ' from ' + Ut.getSobjName(req.recordIds.get(0)) + ' where id in :recordIds';
    return Database.query(soql);
  }

  public List<String> buildSoqlFields(List<String> ruleFields) {
    List<String> fields = new List<String>();
    Ut.MultiMap childFields = new Ut.MultiMap(true);

    for (String field : ruleFields) {
      if (field.containsIgnoreCase('[]')) {
        List<String> parts = field.split('\\[\\]');
        childFields.put(parts.get(0), Ut.removePrefix(parts.size() > 1 ? parts.get(1) : null, '.'));
      } else {
        fields.add(field);
      }
    }

    addId(fields);

    for (String childRel : childFields.keySet()) {
      fields.add('(select ' + Ut.joinCsv(addId(childFields.get(childRel))) + ' from ' + childRel + ')');
    }

    return fields;
  }

  private List<String> addId(List<String> fields) {
    if (fields.isEmpty() || (!fields.contains('Id') && !fields.contains('id'))) {
      if (fields.isEmpty()) {
        fields.add('Id');
      } else {
        fields.add(0, 'Id');
      }
    }

    return fields;
  }
}
