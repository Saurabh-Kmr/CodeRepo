public without sharing class BannerDto {
  public static final RuleDto.ProcessRuleConfig RULE_CONFIG = new RuleDto.ProcessRuleConfig(
    'Banner',
    Ut.listOf('Enabled_Rule__c'),
    new List<String>{
      'Account_Customer_Events__r[].Type__c',
      'Account_Customer_Events__r[].Start_Date__c',
      'Account_Customer_Events__r[].End_Date__c'
    }
  );

  public class BannersResp {
    @AuraEnabled
    public List<Banner_Setting__c> banners = new List<Banner_Setting__c>();

    public BannersResp() {
      // default
    }

    public BannersResp(List<Banner_Setting__c> banners) {
      this.banners = banners;
    }
  }
}
