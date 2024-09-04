@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage,PMD.AvoidHardcodingId')
@IsTest
public class RuleDtoTest {
  @IsTest
  static void testDto() {
    RuleDto.EvaluateReq evalReq = new RuleDto.EvaluateReq();
    evalReq = new RuleDto.EvaluateReq(
      new List<Sobject>{ new Account(Name = 'Test', Id = '001DR00001SAAqgYAH') },
      Ut.listOf('Name'),
      Ut.mapOf('name', 'Test')
    );
    evalReq.addRule('001DR00001SBAWzYAP-Name', 'false');

    System.assertEquals(Ut.mapOf('name', 'Test'), (Map<String, Object>) evalReq.data);
    System.assertEquals(
      '[{"id":"001DR00001SAAqgYAH-Name","expression":"Test","condition":null},{"id":"001DR00001SBAWzYAP-Name","expression":"false","condition":null}]',
      json.serialize(evalReq.rules)
    );

    // EvaluateResp
    RuleDto.RuleResp ruleResp = new RuleDto.RuleResp();
    ruleResp.id = '001DR00001SBAWzYAP-Name';
    ruleResp.success = false;
    ruleResp.result = 'true';
    System.assertEquals(false, ruleResp.isTrue());

    ruleResp.success = true;
    ruleResp.result = 'false';
    System.assertEquals(false, ruleResp.isTrue());

    ruleResp.success = true;
    ruleResp.result = 'true';
    System.assertEquals(true, ruleResp.isTrue());

    RuleDto.EvaluateResp evalResp = new RuleDto.EvaluateResp();
    evalResp.rules = new List<RuleDto.RuleResp>{ ruleResp };
    evalResp.init();
    System.assertEquals('true', evalResp.rulesMap.get('001DR00001SBAWzYAP-Name').result);

    // ValidateReq
    RuleDto.ValidateReq valReq = new RuleDto.ValidateReq();
    valReq.addRule('id1', 'true');

    System.assertEquals('{"rules":[{"id":"id1","expression":"true","condition":null}]}', json.serialize(valReq));

    // ValidateResp
    RuleDto.ValidateResp valResp = new RuleDto.ValidateResp();
    RuleDto.ValidateRespRule valRule = new RuleDto.ValidateRespRule();
    valRule.id = 'id1';
    valResp.rules.add(valRule);
    valResp.init();
    System.assertEquals(
      '{"valid":null,"rulesMap":{"id1":{"vars":[],"valid":null,"id":"id1","errorMessage":null,"errorCode":null}},"rules":[{"vars":[],"valid":null,"id":"id1","errorMessage":null,"errorCode":null}]}',
      json.serialize(valResp)
    );

    // ProcessRuleConfig
    RuleDto.ProcessRuleConfig config = new RuleDto.ProcessRuleConfig();
    config = new RuleDto.ProcessRuleConfig('Banner', Ut.listOf('Enabled_Rule__c'), Ut.listOf('Account_Customer_Events__r[].Type__c'));
    System.assertEquals(
      '{"ruleExpressionFields":["Enabled_Rule__c"],"module":"Banner","ignoreFields":["Account_Customer_Events__r[].Type__c"]}',
      json.serialize(config)
    );

    // Others
    new RuleDto.ProcessRuleReq(null, null);
    new RuleDto.RuleState();
  }
}
