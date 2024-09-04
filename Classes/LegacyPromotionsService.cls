public with sharing class LegacyPromotionsService {
  public static final LegacyPromotionsService OBJ = new LegacyPromotionsService();
  private HttpClient client = new HttpClient(new HttpDto.Options('callout:SunrunLegacy/services/apexrest'));

  public LegacyPromotionsDto.ListPromotionsResp listPromotions(Id scId) {
    return (LegacyPromotionsDto.ListPromotionsResp) Json.deserialize(
      client.get('/v2/promotions', Ut.mapOf('serviceContractId', scId)),
      LegacyPromotionsDto.ListPromotionsResp.class
    );
  }

  public String getLegacyServiceId(Id recordId) {
    String recordObjType = Ut.getSobjName(recordId);
    String legacyRecordId;
    if (recordObjType == 'Program_Enrollment__c') {
      legacyRecordId = [
        SELECT Id, Service_Contract__r.Legacy_ServiceContract_Id__c
        FROM Program_Enrollment__c
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ]
      .Service_Contract__r.Legacy_ServiceContract_Id__c;
    } else if (recordObjType == 'ServiceContract') {
      legacyRecordId = [
        SELECT Id, Legacy_ServiceContract_Id__c
        FROM ServiceContract
        WHERE Id = :recordId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ]
      .Legacy_ServiceContract_Id__c;
    } else {
      throw new ValException('Invalid Object type ' + recordObjType);
    }

    return legacyRecordId;
  }
}
