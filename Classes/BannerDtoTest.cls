@IsTest
public with sharing class BannerDtoTest {
  @IsTest
  static void testDto() {
    System.assertEquals(
      '{"ruleExpressionFields":["Enabled_Rule__c"],"module":"Banner","ignoreFields":["Account_Customer_Events__r[].Type__c","Account_Customer_Events__r[].Start_Date__c","Account_Customer_Events__r[].End_Date__c"]}',
      Json.serialize(BannerDto.RULE_CONFIG)
    );

    BannerDto.BannersResp resp = new BannerDto.BannersResp(new List<Banner_Setting__c>{ new Banner_Setting__c(Name = 'Test') });
    System.assertEquals('{"banners":[{"attributes":{"type":"Banner_Setting__c"},"Name":"Test"}]}', Json.serialize(resp));
  }
}
