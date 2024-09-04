@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class BannerService {
  public static final BannerService OBJ = new BannerService();

  public BannerDto.BannersResp getBanners(Id recId, String type) {
    return new BannerDto.BannersResp(evaluateBanners(recId, queryBanners(Ut.getSobjName(recId), type)));
  }

  private List<Banner_Setting__c> evaluateBanners(Id recId, List<Banner_Setting__c> banners) {
    if (banners.isEmpty()) {
      return banners;
    }

    try {
      Map<String, Object> data = Sf.rule.buildDataMap(Ut.getIdList(banners), recId);
      data.put('Account_Customer_Events__r', queryAccountCustomerEvents(recId));

      RuleDto.EvaluateReq req = new RuleDto.EvaluateReq(banners, BannerDto.RULE_CONFIG.ruleExpressionFields, data);
      RuleDto.EvaluateResp resp = Sf.rule.evaluate(req);

      List<Banner_Setting__c> enabledBanners = new List<Banner_Setting__c>();
      for (Banner_Setting__c banner : banners) {
        RuleDto.RuleResp rresp = resp.rulesMap.get(banner.id + '-Enabled_Rule__c');
        if (rresp.isTrue()) {
          enabledBanners.add(banner);
        } else if (!rresp.success) {
          throw new ValException(banner.name + ': ' + rresp.errorMessage);
        }
      }

      return enabledBanners;
    } catch (Exception e) {
      throw new ValException('Error evaluating banners [' + e.getMessage() + ']', e);
    }
  }

  @TestVisible
  private List<Sobject> queryAccountCustomerEvents(Id recId) {
    String sobj = Ut.getSobjName(recId);

    Id accountId = null;
    if (sobj == 'Account') {
      accountId = recId;
    } else if (sobj == 'Case') {
      accountId = [SELECT AccountId FROM Case WHERE id = :recId].AccountId;
    } else if (sobj == 'Contact') {
      accountId = [SELECT AccountId FROM Contact WHERE id = :recId].AccountId;
    } else if (sobj == 'ServiceContract') {
      accountId = [SELECT AccountId FROM ServiceContract WHERE id = :recId].AccountId;
    } else {
      return new List<Sobject>();
    }

    return [SELECT Type__c, Start_Date__c, End_Date__C FROM Customer_Event__c WHERE Account__c = :accountId];
  }

  private List<Banner_Setting__c> queryBanners(String sobj, String type) {
    return [
      SELECT
        Id,
        Name,
        Type__c,
        Sobject__c,
        Enabled_Rule__c,
        Message__c,
        Tooltip__c,
        Rule_State__c,
        Background_Color__c,
        Text_Color__c,
        Icon__c,
        Icon_Variant__c
      FROM Banner_Setting__c
      WHERE Active__c = TRUE AND Rule_Status__c = 'Valid' AND Sobject__c = :sobj AND Type__c = :type
      ORDER BY Order__c NULLS LAST, Name
    ];
  }
}
