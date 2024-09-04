public without sharing class BannerSettingTriggerHandler extends TriggerHandlerBase {
  public override void beforeInsert(TriggerDto.Context info) {
    Sf.rule.handleBeforeTrigger(info, BannerDto.RULE_CONFIG);
  }

  public override void afterInsert(TriggerDto.Context info) {
    Sf.rule.handleAfterTrigger(info, BannerDto.RULE_CONFIG);
  }

  public override void beforeUpdate(TriggerDto.Context info) {
    Sf.rule.handleBeforeTrigger(info, BannerDto.RULE_CONFIG);
  }

  public override void afterUpdate(TriggerDto.Context info) {
    Sf.rule.handleAfterTrigger(info, BannerDto.RULE_CONFIG);
  }
}
