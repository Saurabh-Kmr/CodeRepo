trigger BannerSettingTrigger on Banner_Setting__c(before insert, after insert, before update, after update) {
  Sf.triggers.handle(new BannerSettingTriggerHandler());
}
