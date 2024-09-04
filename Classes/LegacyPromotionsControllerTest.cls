@IsTest
public class LegacyPromotionsControllerTest {
  @TestSetup
  static void setup() {
    Id recordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
    Account objAccount = new Account();
    objAccount.Name = 'TestAccount';
    objAccount.RecordTypeId = recordTypeId;
    if (Schema.sObjectType.Account.isCreateable()) {
      insert objAccount;
    }

    ServiceContract objServiceContract = new ServiceContract();
    objServiceContract.AccountId = objAccount.id;
    objServiceContract.Name = 'Test Service Contract';
    objServiceContract.Legacy_ServiceContract_Id__c = String.valueOf(Math.round((Math.random() * (900000) + 100000)));
    if (Schema.sObjectType.ServiceContract.isCreateable()) {
      insert objServiceContract;
    }

    Program__c objGSP = new Program__c();
    objGSP.Name = 'Test GSP';
    if (Schema.sObjectType.Program__c.isCreateable()) {
      insert objGSP;
    }

    Program_Enrollment__c objGSPE = new Program_Enrollment__c();
    objGSPE.Service_Contract__c = objServiceContract.id;
    objGSPE.Program__c = objGSP.id;
    if (Schema.sObjectType.Program_Enrollment__c.isCreateable()) {
      insert objGSPE;
    }
  }

  @isTest
  static void getPromotionList() {
    Id existingServiceContractId = [
      SELECT Id, Legacy_ServiceContract_Id__c
      FROM ServiceContract
      LIMIT 1
    ]
    .ID;

    Test.startTest();
    HttpMock mock = new HttpMock();
    mock.ifUrlStartsWithReturn(
      'callout:SunrunLegacy/services/apexrest/v2/promotions',
      '{"appeasementPromos":[{\"wrapRec\":{\"adminOnly\":false,\"autoApply\":false,\"isDeductibleFromCommission\":false,\"managerApproval\":false,\"offerValidityStatus\":\"Valid\",\"opptyGuardrails\":false,\"opptyId\":\"0065200000GKw21AAD\",\"opptyStage\":\"7.ClosedWon\",\"promoEnabled\":\"false\",\"promoId\":\"a0Y52000002ILSCEA4\",\"promoName\":\"2022$1,000DirectSalesAppeasementOfferPromotion\",\"promoSegmentation\":\"Appeasement\",\"promoSubtype\":\"SalesAppeasement\",\"promoType\":\"Offer\",\"refereePaymentAmount\":\"1000.00\",\"restrictedApplyUnapply\":false,\"stackable\":\"Yes\",\"totalAmnt\":\"1000\",\"hasIcon\":false}}],"appliedPromos":[{\"wrapRec\":{\"adminOnly\":false,\"autoApply\":false,\"dateApplied\":\"2023-05-26\",\"exceptionOfr\":false,\"isDeductibleFromCommission\":false,\"managerApproval\":false,\"offerId\":\"a5a52000000M3V4AAK\",\"offerStatus\":\"Applied\",\"offerValidityStatus\":\"Invalid\",\"opptyGuardrails\":false,\"opptyId\":\"0065200000GKw21AAD\",\"opptyStage\":\"7.ClosedWon\",\"promoEnabled\":\"true\",\"promoId\":\"a0Y52000002IYf2EAG\",\"promoName\":\"T&Csofferpromotion\",\"promoSegmentation\":\"Appeasement\",\"promoSubtype\":\"SalesAppeasement\",\"promoType\":\"Offer\",\"refereePaymentAmount\":\"0.00\",\"restrictedApplyUnapply\":false,\"stackable\":\"Yes\",\"totalAmnt\":\"0\",\"icon\":{\"iconName\":\"utility:warning\",\"title\":\"Invalidoffer\",\"variant\":\"warning\",\"size\":\"x-small\"},\"hasIcon\":true}}],\"partnerUrl\":\"partner\","promoRec":[{\"wrapRec\":{\"adminOnly\":false,\"autoApply\":false,\"isDeductibleFromCommission\":true,\"managerApproval\":false,\"offerValidityStatus\":\"Valid\",\"opptyGuardrails\":false,\"opptyId\":\"0065200000GKw21AAD\",\"opptyStage\":\"7.ClosedWon\",\"promoEnabled\":\"false\",\"promoId\":\"a0Y52000002gTPiEAM\",\"promoName\":\"2023$1000CommDeductionOfferPromo\",\"promoSegmentation\":\"CustomerOffer-NonRetail\",\"promoSubtype\":\"Acquisition-Web\",\"promoType\":\"Offer\",\"refereePaymentAmount\":\"1000.00\",\"restrictedApplyUnapply\":true,\"stackable\":\"Yes\",\"totalAmnt\":\"1000\",\"hasIcon\":false}}],\"todaysDateValue\":\"10/03/2023\"}'
    );
    LegacyPromotionsDto.ListPromotionsResp response = LegacyPromotionsController.listPromotions(existingServiceContractId);
    Assert.areEqual('GET', mock.calloutRequests.get(0).request.getMethod(), 'GET method expected');
    Assert.areEqual(1, response.appeasementPromos.size(), 'Single record expected in list');
    Assert.areEqual(1, response.appliedPromos.size(), 'Single record expected in list');
    Assert.areEqual(1, response.promoRec.size(), 'Single record expected in list');
    Test.stopTest();
  }

  @isTest
  static void getLegacyServiceIdGSPEPositiveTest() {
    string legacyServiceContractId;
    string existingServiceContractId;
    Test.startTest();
    Program_Enrollment__c objGSPE = [SELECT Id FROM Program_Enrollment__c LIMIT 1];

    legacyServiceContractId = LegacyPromotionsController.getLegacyServiceId(objGSPE.Id);
    existingServiceContractId = [SELECT Id, Legacy_ServiceContract_Id__c FROM ServiceContract LIMIT 1].Legacy_ServiceContract_Id__c;
    Test.stopTest();
    Assert.areEqual(legacyServiceContractId, existingServiceContractId, 'Legacy Id match');
  }

  @isTest
  static void getLegacyServiceIdSCPositiveTest() {
    string legacyServiceContractId;
    string existingServiceContractId;
    Test.startTest();
    ServiceContract objSC = [SELECT Id FROM ServiceContract LIMIT 1];

    legacyServiceContractId = LegacyPromotionsController.getLegacyServiceId(objSC.Id);
    existingServiceContractId = [SELECT Id, Legacy_ServiceContract_Id__c FROM ServiceContract LIMIT 1].Legacy_ServiceContract_Id__c;
    Test.stopTest();
    Assert.areEqual(legacyServiceContractId, existingServiceContractId, 'Legacy Id match');
  }

  @isTest
  static void getLegacyServiceIdPositiveNoIdTest() {
    string legacyServiceContractId;
    string existingServiceContractId;
    try {
      Test.startTest();
      legacyServiceContractId = LegacyPromotionsController.getLegacyServiceId('');
      Assert.fail('Expected Exception Not Thrown');
      Test.stopTest();
    } catch (exception e) {
      Assert.areEqual('Invalid id: ', e.getMessage(), 'Exception Expected');
    }
  }

  @isTest
  static void invalidRecordID() {
    string legacyServiceContractId;
    string existingServiceContractId;
    try {
      Test.startTest();
      Account accRecord = [SELECT Id, Name FROM Account];
      legacyServiceContractId = LegacyPromotionsController.getLegacyServiceId(accRecord.Id);
      Assert.fail('Expected Exception Not Thrown');
      Test.stopTest();
    } catch (exception e) {
      Assert.areEqual('Invalid Object type Account', e.getMessage(), 'Exception Expected');
    }
  }
}
