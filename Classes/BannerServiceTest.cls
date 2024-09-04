@IsTest
public class BannerServiceTest {
  private static void setupData() {
    Sf.settings.setForTx('RuleServiceBaseUrl', 'https://gateway.sunrundev.com/devmaj-sfdc-rulesengine/v1');
    Sf.settings.setForTx('RuleServiceApiKey', 'TestRuleKey1');
  }

  @IsTest
  static void testGetBannersPositive() {
    setupData();

    Account act = new Account(Name = 'Llama Household', BillingStreet = '1 Market St', BillingCity = 'San Francisco');
    insert act;

    Banner_Setting__c banner = new Banner_Setting__c(
      Name = 'Test',
      Active__c = true,
      Sobject__c = 'Account',
      Enabled_Rule__c = 'is_equals(Name, \'Llama Household\')',
      Type__c = 'Banner',
      Message__c = 'Test Message'
    );
    insert banner;

    String bannerString = banner.Id + '-Enabled_Rule__c';

    HttpMock mock = new HttpMock();
    mock.ifUrlEndsWithReturn(
      '/evaluate',
      '{"success": true, "status": "pass", "rules": [{"id": "' + bannerString + '", "success": true, "result": "true"} ] }'
    );
    mock.ifUrlEndsWithReturn('/validate', '{"valid": true, "rules": [{"id": "' + bannerString + '", "valid": true, "vars": ["Name"] }] }');

    Test.startTest();
    Sf.rule.processRules(new RuleDTO.ProcessRuleReq(BannerDto.RULE_CONFIG, new List<Id>{ banner.Id }));
    Test.stopTest();

    BannerDto.BannersResp resp = BannerController.getBanners(act.Id, 'Banner');
    Assert.areEqual(1, resp.banners.size(), 'One record expected');
    Assert.areEqual('Account', resp.banners[0].Sobject__c, 'Account Sobject expected');
    Assert.areEqual('Test Message', resp.banners[0].Message__c, 'Message match expected');
    Assert.areEqual('POST', mock.calloutRequests.get(0).request.getMethod(), 'Post method expected');
  }

  @IsTest
  static void testGetBannersNoBannersValid() {
    setupData();

    Account act = new Account(Name = 'Llama Household', BillingStreet = '1 Market St', BillingCity = 'San Francisco');
    insert act;

    Banner_Setting__c banner = new Banner_Setting__c(
      Name = 'Test',
      Active__c = true,
      Sobject__c = 'Account',
      Enabled_Rule__c = 'is_equals(Name, \'Llama Household\')',
      Type__c = 'Banner',
      Message__c = 'Test Message'
    );
    insert banner;

    Test.startTest();
    BannerDto.BannersResp resp = BannerController.getBanners(act.Id, 'Banner');
    Test.stopTest();

    Assert.areEqual(0, resp.banners.size(), 'Zero record expected');
  }

  @IsTest
  static void testGetBannersUnsuccessfulResponse() {
    setupData();

    Account act = new Account(Name = 'Test', BillingStreet = '1 Market St', BillingCity = 'San Francisco');
    insert act;

    Banner_Setting__c banner = new Banner_Setting__c(
      Name = 'Test',
      Active__c = true,
      Sobject__c = 'Account',
      Enabled_Rule__c = 'is_equals(Name, \'Llama Household\')',
      Type__c = 'Banner',
      Message__c = 'Test Message'
    );
    insert banner;

    Id bannerId = banner.Id;
    String bannerString = '"' + bannerId + '-Enabled_Rule__c"';

    HttpMock mock = new HttpMock();
    mock.ifUrlEndsWithReturn(
      '/evaluate',
      '{"success": false, "status": "fail", "rules": [{"id": ' +
        bannerString +
        ', "success": false, "result": "false","errorMessage":"Rule evaluation failed"} ] }'
    );
    mock.ifUrlEndsWithReturn('/validate', '{"valid": true, "rules": [{"id": ' + bannerString + ', "valid": true, "vars": ["Name"] }] }');

    Test.startTest();
    Sf.rule.processRules(new RuleDTO.ProcessRuleReq(BannerDto.RULE_CONFIG, new List<Id>{ bannerId }));
    Test.stopTest();

    try {
      BannerDto.BannersResp resp = BannerController.getBanners(act.Id, 'Banner');
      Assert.fail('Expected Exception Not Thrown');
    } catch (ValException ve) {
      Assert.areEqual('Error evaluating banners [Test: Rule evaluation failed]', ve.getMessage(), 'Exception Expected');
    }
  }

  @IsTest
  static void testqueryAccountCustomerEvents() {
    Account act = new Account(Name = 'Test', BillingStreet = '1 Market St', BillingCity = 'San Francisco');
    insert act;
    Customer_Event__c custEvent = new Customer_Event__c(
      Type__c = 'Bankruptcy',
      Start_Date__c = Datetime.now(),
      End_Date__c = DateTime.now().AddDays(1),
      Account__c = act.id
    );
    insert custEvent;

    Case caseTest = new Case(Subject = 'Test Case customer event', AccountId = act.id);
    insert caseTest;

    Contact contactTest = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = act.id);
    insert contactTest;

    ServiceContract objServiceContract = new ServiceContract(AccountId = act.id, Name = 'Test Service Contract');
    insert objServiceContract;

    Account testAccount = new Account(Name = 'Test2', BillingStreet = '1 Market St', BillingCity = 'San Francisco');

    List<Customer_Event__c> caseCustEvent = (List<Customer_Event__c>) BannerService.OBJ.queryAccountCustomerEvents(caseTest.id);
    Assert.areEqual(1, caseCustEvent.size(), 'Expected One record to be returned');
    Assert.areEqual('Bankruptcy', caseCustEvent[0].Type__c, 'Type matched');

    List<SObject> contactCustEvent = BannerService.OBJ.queryAccountCustomerEvents(contactTest.id);
    Assert.areEqual(1, contactCustEvent.size(), 'Expected One record to be returned');

    List<SObject> scCustEvent = BannerService.OBJ.queryAccountCustomerEvents(objServiceContract.id);
    Assert.areEqual(1, scCustEvent.size(), 'Expected One record to be returned');

    List<SObject> actCustEvent = BannerService.OBJ.queryAccountCustomerEvents(testAccount.id);
    Assert.areEqual(0, actCustEvent.size(), 'Zero record to be returned');
  }
}
