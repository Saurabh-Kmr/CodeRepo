public with sharing class BannerController {
  @AuraEnabled
  public static BannerDto.BannersResp getBanners(Id recordId, String type) {
    return BannerService.OBJ.getBanners(recordId, type);
  }
}
