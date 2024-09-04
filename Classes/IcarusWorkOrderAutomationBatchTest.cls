@isTest
public class IcarusWorkOrderAutomationBatchTest {
  @testSetup
  public static void setupCaseRecord() {
    Account servicer = new Account(Name = 'Test');
    servicer.Partner_Status__c = 'Active';
    servicer.Partner_Type__c = 'Channel Partner';
    insert servicer;

    Contact con = new Contact();
    con.AccountId = servicer.Id;
    con.LastName = 'TestContactName';
    insert con;

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

    Skill sk = [SELECT id FROM Skill WHERE MasterLabel = 'Storage' LIMIT 1];

    ServiceResource sr1 = new ServiceResource();
    sr1.RelatedRecordId = u1.Id;
    sr1.AccountId = servicer.id;
    sr1.name = 'Partner - Test User1';
    sr1.IsActive = true;
    sr1.Field_Operations_Team__c = 'Partner';
    insert sr1;

    WorkType wtype = new WorkType();
    wType.Name = 'test';
    wType.Work_Description__c = 'test';
    wType.EstimatedDuration = 10;
    wType.Number_of_Technicians__c = 2;
    wType.Customer_Presence_Needed__c = false;
    insert wtype;

    SkillRequirement sr = new SkillRequirement();
    sr.RelatedRecordId = wtype.Id;
    sr.SkillId = sk.Id;
    sr.SkillLevel = 1;
    insert sr;

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
    stm.ServiceResourceId = sr1.Id;
    stm.ServiceTerritoryId = phoenixST.Id;
    stm.EffectiveStartDate = System.today().addMonths(-1);
    insert stm;

    ServiceResourceSkill ssr = new ServiceResourceSkill();
    ssr.SkillId = sk.Id;
    ssr.ServiceResourceId = sr1.id;
    ssr.EffectiveStartDate = system.today().addMonths(-1);
    ssr.EffectiveEndDate = system.today().addMonths(2);
    ssr.Service_Territory__c = phoenixST.Id;
    insert ssr;

    Skill skill2 = [
      SELECT id, masterLabel
      FROM skill
      WHERE masterLabel = 'Test Skill Tesla certification'
      LIMIT 1
    ];
    ServiceResourceSkill ssr2 = new ServiceResourceSkill();
    ssr2.SkillId = skill2.Id;
    ssr2.ServiceResourceId = sr1.id;
    ssr2.EffectiveStartDate = system.today().addMonths(-1);
    ssr2.EffectiveEndDate = system.today().addMonths(2);
    ssr2.Service_Territory__c = phoenixST.Id;
    insert ssr2;

    Account acc = new Account(Name = 'Test');
    insert acc;
    Product2 pr = new Product2();
    pr.Manufacturer_Name__c = 'TESLA';
    pr.Name = 'test product';
    insert pr;

    Schema.Address addData = new Schema.Address();
    Schema.Location loc = new Schema.Location();
    loc.Name = 'Tes';
    insert loc;
    addData.street = '77 East Polk Street';
    addData.state = 'AZ';
    addData.postalCode = '85004';
    addData.country = 'United States';
    addData.ParentId = loc.Id;
    insert addData;
    loc.VisitorAddressId = addData.id;
    update loc;
    Asset ast = new Asset();
    ast.Name = 'Tesla Test Asset';
    ast.AccountId = acc.Id;
    ast.LocationId = loc.id;
    ast.Product2Id = pr.Id;
    ast.Servicer__c = servicer.Id;
    insert ast;
    System_Health__c healthRec = new System_health__c();
    healthRec.system_State__c = 'Test';
    healthRec.Work_Order_Automation__c = true;
    healthRec.Work_Type__c = wtype.Id;
    insert healthRec;
    Case ca = new Case();
    ca.accountId = acc.id;
    ca.assetId = ast.id;
    ca.status = 'New';
    ca.origin = 'Integration';
    ca.Customer_Source__c = 'Icarus';
    ca.subject = 'New Case Subject' + datetime.now();
    ca.description = 'New Case Description' + datetime.now();
    ca.system_state__c = 'Test';
    insert ca;
  }
  @isTest
  public static void testWorkOrderAndAppointmentCreation() {
    test.startTest();
    Database.executeBatch(new IcarusWorkOrderAutomationBatch());
    test.stopTest();
    list<ServiceAppointment> saList = [SELECT id FROM ServiceAppointment];
    list<WorkOrder> workorderData = [SELECT id FROM WorkOrder];
    System.assertEquals(saList.size() == 1, true);
    System.assertEquals(workorderData.size() == 1, true);
  }

  @isTest
  public static void testNegativeScenario() {
    Product2 pr = [SELECT id, Manufacturer_Name__c FROM Product2];
    pr.Manufacturer_Name__c = 'test';
    update pr;
    test.startTest();
    Database.executeBatch(new IcarusWorkOrderAutomationBatch());
    test.stopTest();
    list<App_Log__c> appLogs = [SELECT id FROM App_Log__c];
    System.assertEquals(appLogs.size() > 0, true);
  }

  @isTest
  public static void testErrorCodeNotFound() {
    System_Health__c sHealth = [SELECT id, System_State__c FROM System_Health__c];
    sHealth.System_State__c = 'test2';
    update sHealth;
    test.startTest();
    Database.executeBatch(new IcarusWorkOrderAutomationBatch());
    test.stopTest();
    Case cseRec = [SELECT id, Work_Order_Automation_Status__c FROM Case];
    System.assertEquals(cseRec.Work_Order_Automation_Status__c, 'Error Code Not Found');
  }
}
