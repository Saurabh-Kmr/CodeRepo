public without sharing class RuleProcessJob implements Queueable, Database.AllowsCallouts {
  private RuleDto.ProcessRuleReq req;

  public RuleProcessJob(RuleDto.ProcessRuleReq req) {
    this.req = req;
  }

  public void execute(QueueableContext ctx) {
    try {
      Sf.rule.processRules(req);
    } catch (Exception e) {
      String msg = 'Error processing rules [' + e.getMessage() + ']';
      AppLogger.logError(Ut.firstNotBlank(req.config.module, 'RuleService'), 'processRules', req.recordIds.get(0), msg, e);
    }
  }
}
