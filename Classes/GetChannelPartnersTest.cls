@isTest
private class GetChannelPartnersTest {
  @TestSetup
  static void createTestData() {
    Id partnerAccount = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Partner').getRecordTypeId();
    Account channelPartnerAcc = new Account();
    channelPartnerAcc.name = 'Channel Partner Account 1';
    channelPartnerAcc.Partner_Type__c = 'Channel Partner';
    channelPartnerAcc.Partner_Status__c = 'Active';
    insert channelPartnerAcc;

    Account servicePartnerAcc = new Account();
    servicePartnerAcc.name = 'Channel Partner Account 1';
    servicePartnerAcc.Partner_Type__c = 'Service Partner';
    servicePartnerAcc.Partner_Status__c = 'Active';
    insert servicePartnerAcc;

    Contact con = new Contact();
    con.AccountId = channelPartnerAcc.Id;
    con.LastName = 'TestContactName';
    insert con;

    Asset ast = new Asset();
    ast.name = 'Test Asset';
    ast.Servicer__c = channelPartnerAcc.Id;
    ast.ContactId = con.id;
    insert ast;

    User u1 = new User(
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User']
      .Id,
      LastName = 'last',
      Email = 'puser000@sunrun.com',
      Username = 'puser000@sunrun.com' + System.currentTimeMillis(),
      CompanyName = 'TEST',
      Title = 'title',
      Alias = 'alias',
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      Disable_Flows__c = true
    );
    insert u1;

    User u2 = new User(
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User']
      .Id,
      LastName = 'last',
      Email = 'puser000@sunrun2.com',
      Username = 'puser000@sunrun.com' + System.currentTimeMillis(),
      CompanyName = 'TEST',
      Title = 'title',
      Alias = 'alias',
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US'
    );
    insert u2;

    Skill sk = [SELECT id FROM Skill WHERE MasterLabel = 'Storage' LIMIT 1];

    ServiceResource sr1 = new ServiceResource();
    sr1.RelatedRecordId = u1.Id;
    sr1.AccountId = channelPartnerAcc.id;
    sr1.name = 'Partner - Test User1';
    sr1.IsActive = true;
    sr1.Field_Operations_Team__c = 'Partner';
    insert sr1;

    ServiceResource sr2 = new ServiceResource();
    sr2.RelatedRecordId = u2.Id;
    sr2.AccountId = servicePartnerAcc.id;
    sr2.name = 'Partner - Test User1';
    sr2.IsActive = true;
    sr2.Field_Operations_Team__c = 'Partner';
    insert sr2;

    OperatingHours oh = new OperatingHours(Name = 'Test Operating Hours');
    oh.TimeZone = 'America/Los_Angeles';
    insert oh;

    ServiceTerritory phoenixST = new ServiceTerritory(
      Name = 'O&M: AZ-301 Phoenix North1',
      OperatingHoursId = oh.Id,
      PostalCode = '85004',
      State = 'AZ',
      City = 'Phoenix',
      Street = '77 East Polk Street',
      Country = 'United States',
      isActive = true
    );
    insert phoenixST;

    ServiceTerritoryMember stm = new ServiceTerritoryMember();
    stm.ServiceResourceId = sr2.Id;
    stm.ServiceTerritoryId = phoenixST.Id;
    stm.EffectiveStartDate = System.today().addMonths(-1);
    insert stm;

    WorkType installWorkType = new WorkType(
      ShouldAutoCreateSvcAppt = true,
      Name = 'Install Panel Test',
      EstimatedDuration = 60.00,
      DurationType = 'Minutes'
    );
    insert installWorkType;

    WorkOrder installWorkOrder = new WorkOrder(
      Subject = 'Test Work Order',
      workTypeId = installWorkType.Id,
      recordtypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Field_Service').getRecordTypeId(),
      PostalCode = '94105',
      State = 'CA',
      City = 'San Francisco',
      Street = '415 Mission St',
      Country = 'United States',
      AssetId = ast.id
    );
    insert installWorkOrder;

    ServiceAppointment testServiceAppointment = new ServiceAppointment();
    testServiceAppointment.ParentRecordId = installWorkOrder.Id;
    testServiceAppointment.Status = 'Ready To Be Scheduled';
    testServiceAppointment.EarliestStartTime = DateTime.now();
    testServiceAppointment.DueDate = DateTime.now().addDays(7);
    testServiceAppointment.ArrivalWindowStartTime = null;
    testServiceAppointment.ArrivalWindowEndTime = null;
    testServiceAppointment.Note__c = 'Test SA';
    testServiceAppointment.workTypeId = installWorkType.Id;
    testServiceAppointment.ServiceTerritoryId = phoenixST.Id;
    insert testServiceAppointment;

    SkillRequirement sr = new SkillRequirement();
    sr.RelatedRecordId = installWorkOrder.Id;
    sr.SkillId = sk.Id;
    sr.SkillLevel = 1;
    insert sr;

    ServiceResourceSkill ssr = new ServiceResourceSkill();
    ssr.SkillId = sk.Id;
    ssr.ServiceResourceId = sr1.id;
    ssr.EffectiveStartDate = system.today().addMonths(-1);
    ssr.EffectiveEndDate = system.today().addMonths(2);
    ssr.Service_Territory__c = phoenixST.Id;
    insert ssr;

    ServiceResourceSkill ssr2 = new ServiceResourceSkill();
    ssr2.SkillId = sk.Id;
    ssr2.ServiceResourceId = sr2.id;
    ssr2.EffectiveStartDate = system.today().addMonths(-1);
    ssr2.EffectiveEndDate = system.today().addMonths(2);
    ssr.Service_Territory__c = phoenixST.Id;
    insert ssr2;
  }

  @isTest
  static void testGetServicepartner() {
    List<Id> sAIds = new List<Id>();
    ServiceTerritory st = [SELECT id FROM ServiceTerritory WHERE Name = 'O&M: AZ-301 Phoenix North1' LIMIT 1];
    ServiceAppointment sA = [SELECT id, ServiceTerritoryId FROM ServiceAppointment LIMIT 1];
    sA.ServiceTerritoryId = st.Id;
    update sA;
    sAIds.add(sA.Id);
    List<List<PartnerDetailsWrapper>> reponse = GetChannelPartners.getChannelPartnerDetails(sAIds);
    System.assert(reponse.size() > 0, 'Channel Partner Found');
  }
}
