public with sharing class LegacyPromotionsController {
  @AuraEnabled
  public static LegacyPromotionsDto.ListPromotionsResp listPromotions(Id scId) {
    return LegacyPromotionsService.OBJ.listPromotions(scId);
  }

  @AuraEnabled(cacheable=true)
  public static string getLegacyServiceId(Id recordId) {
    return LegacyPromotionsService.OBJ.getLegacyServiceId(recordId);
  }
}
