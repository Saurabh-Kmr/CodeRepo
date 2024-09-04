public class RuleDto {
  public class RuleReq {
    public String id;
    public String expression;
    public String condition;

    public RuleReq(String id, String expression) {
      this(id, expression, null);
    }

    public RuleReq(String id, String expression, String condition) {
      this.id = id;
      this.expression = expression;
      this.condition = condition;
    }
  }

  public class EvaluateReq {
    public List<RuleReq> rules = new List<RuleReq>();
    public Object data;
    public Boolean valuesDefaultsToNull = true;
    public Boolean returnResultAsString = true;

    public EvaluateReq() {
      // default
    }

    public EvaluateReq(List<Sobject> recs, List<String> ruleFields, Map<String, Object> data) {
      this.data = data;

      for (Sobject rec : recs) {
        for (String field : ruleFields) {
          this.addRule(rec.id + '-' + field, Ut.getValueString(rec, field));
        }
      }
    }

    public EvaluateReq addRule(String id, String expression) {
      return addRule(id, expression, null);
    }

    public EvaluateReq addRule(String id, String expression, String condition) {
      this.rules.add(new RuleReq(id, expression, condition));
      return this;
    }
  }

  public class RuleResp {
    public String id;
    public String status;
    public boolean success;
    public String result;
    public String errorMessage;
    public String errorCode;

    public Boolean isTrue() {
      return success && Ut.isTrue(result);
    }
  }

  public class EvaluateResp {
    public Boolean success;
    public String status;
    public List<RuleResp> rules = new List<RuleResp>();
    public Map<String, RuleResp> rulesMap = new Map<String, RuleResp>();

    public EvaluateResp init() {
      rulesMap = new Map<String, RuleResp>();

      for (RuleResp rresp : rules) {
        rulesMap.put(rresp.id, rresp);
      }

      return this;
    }
  }

  public class ValidateReq {
    public List<RuleReq> rules = new List<RuleReq>();

    public ValidateReq addRule(String id, String expression) {
      this.rules.add(new RuleReq(id, expression));
      return this;
    }
  }

  public class ValidateRespRule {
    public String id;
    public boolean valid;
    public String errorMessage;
    public String errorCode;
    public List<String> vars = new List<String>();
  }

  public class ValidateResp {
    public Boolean valid;
    public List<ValidateRespRule> rules = new List<ValidateRespRule>();
    public Map<String, ValidateRespRule> rulesMap = new Map<String, ValidateRespRule>();

    public ValidateResp init() {
      rulesMap = new Map<String, ValidateRespRule>();

      for (ValidateRespRule rresp : rules) {
        rulesMap.put(rresp.id, rresp);
      }

      return this;
    }
  }

  public class ProcessRuleConfig {
    public String module;
    public List<String> ruleExpressionFields = new List<String>();
    public List<String> ignoreFields = new List<String>();

    public ProcessRuleConfig() {
      // default
    }

    public ProcessRuleConfig(String module, List<String> ruleExpressionFields, List<String> ignoreFields) {
      this.module = module;
      this.ruleExpressionFields = ruleExpressionFields;
      this.ignoreFields = ignoreFields;
    }
  }

  public class ProcessRuleReq {
    public ProcessRuleConfig config;
    public List<Id> recordIds;

    public ProcessRuleReq(ProcessRuleConfig config, List<Id> recordIds) {
      this.recordIds = recordIds;
      this.config = config;
    }
  }

  public class RuleState {
    public Map<String, String> soqls = new Map<String, String>();
    public List<String> allFields = new List<String>();
    public List<String> fields = new List<String>();
    public DateTime processedAt = Datetime.now();
    public String message = null;
    public String stacktrace = null;

    public RuleState() {
      // Default
    }

    public RuleState(String message, String stacktrace) {
      this.message = message;
      this.stacktrace = stacktrace;
    }
  }
}
