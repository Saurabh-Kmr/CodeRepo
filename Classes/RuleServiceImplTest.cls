@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage')
@IsTest
public class RuleServiceImplTest {
  private static final RuleDto.ProcessRuleConfig RULE_CONFIG = new RuleDto.ProcessRuleConfig(
    'Banner',
    Ut.listOf('Enabled_Rule__c'),
    new List<String>{
      'Account_Customer_Events__r[].Type__c',
      'Account_Customer_Events__r[].Start_Date__c',
      'Account_Customer_Events__r[].End_Date__c'
    }
  );

  private static void setupData() {
    Sf.settings.setForTx('RuleServiceBaseUrl', 'https://gateway.sunrundev.com/devmaj-sfdc-rulesengine/v1');
    Sf.settings.setForTx('RuleServiceApiKey', 'RuleServiceKey1');
  }

  @IsTest
  static void testValidate() {
    setupData();

    Test.startTest();
    HttpMock mock = new HttpMock(200, '{"valid": true, "rules": [{"id": "123", "valid": false, "vars": ["Parent.Name", "AccountId"] }] }');

    RuleDto.ValidateReq req = new RuleDto.ValidateReq();
    req.addRule('123', 'is_equals(Parent.Name) && is_not_blank(AccountId)');

    RuleDto.ValidateResp resp = Sf.rule.validate(req);
    HttpRequest httpReq = mock.calloutRequests.get(0).request;
    Test.stopTest();

    System.assertEquals(new List<String>{ 'Parent.Name', 'AccountId' }, resp.rules.get(0).vars);
    System.assertEquals('RuleServiceKey1', httpReq.getHeader('x-api-key'));
    System.assertEquals('https://gateway.sunrundev.com/devmaj-sfdc-rulesengine/v1/validate', httpReq.getEndpoint());
  }

  @IsTest
  static void testEvaluate() {
    setupData();

    Test.startTest();
    HttpMock mock = new HttpMock(200, '{"success": true, "status": "pass", "rules": [{"id": "123", "success": true, "result": "true"} ] }');

    RuleDto.EvaluateReq req = new RuleDto.EvaluateReq();
    req.addRule('123', 'is_blank(Account.Parent.Name) && is_not_blank(AccountId)');
    req.data = new Map<String, Object>{ 'AccountId' => 'Acct123' };

    RuleDto.EvaluateResp resp = Sf.rule.evaluate(req);

    HttpRequest httpReq = mock.calloutRequests.get(0).request;
    Test.stopTest();
    System.assertEquals('true', resp.rules.get(0).result);
    System.assertEquals('RuleServiceKey1', httpReq.getHeader('x-api-key'));
    System.assertEquals('https://gateway.sunrundev.com/devmaj-sfdc-rulesengine/v1/evaluate', httpReq.getEndpoint());
  }

  @IsTest
  static void testHandleBeforeAndAfterTriggerErrorState() {
    setupData();

    Banner_Setting__c banner = new Banner_Setting__c(
      Name = 'Test',
      Active__c = true,
      Sobject__c = 'Account',
      Enabled_Rule__c = 'is_equals(Name, \'Llama Household\')',
      Type__c = 'Banner'
    );
    insert banner;

    String bannerString = banner.Id + '-Enabled_Rule__c';
    HttpMock mock = new HttpMock(
      200,
      '{"valid": true, "rules": [{"id": "' + bannerString + '", "valid": false, "vars": ["Parent.Name", "AccountId"] }] }'
    );

    Test.startTest();

    RuleDTO.ProcessRuleReq req = new RuleDTO.ProcessRuleReq(
      new RuleDto.ProcessRuleConfig('Banner', Ut.listOf('Enabled_Rule__c'), new List<String>{}),
      new List<Id>{ banner.Id }
    );
    Sf.rule.processRules(req);
    HttpRequest httpReq = mock.calloutRequests.get(0).request;

    Test.stopTest();

    Banner_Setting__c updatedBanner = [SELECT Id, Rule_State__c, Rule_Status__c, Enabled_Rule__c FROM Banner_Setting__c][0];
    Assert.areEqual('POST', mock.calloutRequests.get(0).request.getMethod(), 'Post method expected');
    Assert.isTrue(
      updatedBanner.Rule_State__c.contains('"message" : " Enabled_Rule__c [null]"'),
      'Rule State should have had error. Actual Rule: ' + updatedBanner.Rule_State__c
    );
    Assert.areEqual('Error', updatedBanner.Rule_Status__c, 'Error status Expected');
  }

  @IsTest
  static void testHandleBeforeAndAfterTriggerValidState() {
    setupData();

    Banner_Setting__c banner = new Banner_Setting__c(
      Name = 'Test',
      Active__c = true,
      Sobject__c = 'Account',
      Enabled_Rule__c = 'is_equals(Name, \'Llama Household\')',
      Type__c = 'Banner'
    );
    insert banner;

    String bannerString = banner.Id + '-Enabled_Rule__c';
    HttpMock mock = new HttpMock(200, '{"valid": true, "rules": [{"id": "' + bannerString + '", "valid": true, "vars": ["Name"] }] }');

    Test.startTest();

    Sf.rule.processRules(new RuleDTO.ProcessRuleReq(RULE_CONFIG, new List<Id>{ banner.Id }));

    Test.stopTest();

    Banner_Setting__c updatedBanner = [SELECT Id, Rule_State__c, Rule_Status__c, Enabled_Rule__c FROM Banner_Setting__c][0];
    HttpRequest httpReq = mock.calloutRequests.get(0).request;

    Assert.areEqual('POST', mock.calloutRequests.get(0).request.getMethod(), 'Post method expected');
    Assert.areEqual('Valid', updatedBanner.Rule_Status__c, 'Valid status Expected');
  }

  @IsTest
  static void testbuildDataMap() {
    setupData();

    Account act = new Account(Name = 'Foo Bar', BillingStreet = '1 Market St', BillingCity = 'San Francisco');
    insert act;

    opportunity oppty = new opportunity(CloseDate = system.today(), Name = 'TestOppty', AccountId = act.Id, StageName = 'Qualification');
    insert oppty;

    Banner_Setting__c banner = new Banner_Setting__c(
      Name = 'Test',
      Active__c = true,
      Sobject__c = 'Opportunity',
      Enabled_Rule__c = 'is_equals(Name, \'TestOppty\') and is_equals(Account.Name,\'Foo Bar\')',
      Type__c = 'Banner'
    );
    insert banner;

    String bannerString = banner.Id + '-Enabled_Rule__c';
    HttpMock mock = new HttpMock(200, '{"valid": true, "rules": [{"id": "' + bannerString + '", "valid": true, "vars": ["Name","Account.Name"] }] }');

    Test.startTest();

    Sf.rule.processRules(new RuleDTO.ProcessRuleReq(RULE_CONFIG, new List<Id>{ banner.Id }));

    Test.stopTest();

    HttpRequest httpReq = mock.calloutRequests.get(0).request;
    Banner_Setting__c updatedBanner = [SELECT Id, Rule_State__c, Rule_Status__c, Enabled_Rule__c FROM Banner_Setting__c][0];
    Map<String, Object> dataMap = Sf.rule.buildDataMap(new List<Id>{ updatedBanner.Id }, oppty.Id);

    Assert.areEqual('TestOppty', dataMap.get('Name'), 'Field Value Match');
    Assert.areEqual('POST', mock.calloutRequests.get(0).request.getMethod(), 'Post method expected');
    Assert.areEqual('Valid', updatedBanner.Rule_Status__c, 'Valid status Expected');
  }

  @IsTest
  static void testRuleProcessJob() {
    // RuleProcessJob should have been covered by above methods as we do processRules but adding this here to get additional coverage
    try {
      new RuleProcessJob(null).execute(null);
      System.assert(false, 'Expected exception');
    } catch (Exception e) {
      // ignore as it is expected
    }
  }
}
