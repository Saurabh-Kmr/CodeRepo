public interface RuleService {
  RuleDto.EvaluateResp evaluate(RuleDto.EvaluateReq req);
  RuleDto.ValidateResp validate(RuleDto.ValidateReq req);

  void handleBeforeTrigger(TriggerDto.Context info, RuleDto.ProcessRuleConfig req);
  void handleAfterTrigger(TriggerDto.Context info, RuleDto.ProcessRuleConfig req);

  void processRules(RuleDto.ProcessRuleReq req);

  List<String> getRuleFields(List<Id> ruleRecIds);
  Map<String, String> buildSoqls(String sobj, List<String> ruleFields);
  Map<String, Object> buildDataMap(List<Id> ruleRecIds, Id dataRecId);
}
