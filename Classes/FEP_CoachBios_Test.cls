@isTest
private class FEP_CoachBios_Test {
@testSetup static void setup() {
        Account accObj = new Account(Name ='TestAccount 007',Access_Code__c='123',Dialed_Phone_Number__c='18773580439',FEP_Timezone__c='America/New_York');
        insert accObj;   
        Contact con = new Contact(lastName='FEPTest',Company_Provided_Email__c='testfep2@test.com',Active__c=true,AccountId=accObj.Id);
        insert con;
        User u1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FEP Customer Community User - Custom'].Id,
            LastName = 'last',
            Email = 'testfep2@test.com',
            Username = 'puser000@pwc.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId= con.Id
          );
          insert u1;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FEP Coaches']
            .Id,
            LastName = 'last',
            Email = 'puser000@pwc.com',
            Username = 'puser000@pwc.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            FEP_SchedulingSiteCoachBio__c='Test description'
          );
          insert u;
        OperatingHours oh = new OperatingHours(Name = 'Test Operating Hours');
    oh.TimeZone = 'America/Los_Angeles';
    insert oh;

    WorkType wtype = new WorkType();
        wtype.OperatingHoursId = oh.Id;
        wtype.Name = 'Test';
        wtype.EstimatedDuration = 30;
        wtype.DurationType = 'Hours';
        wtype.FEP_RelatedAccount__c=accObj.id;
        insert wtype;
		ServiceTerritory objServiceTerritory = new ServiceTerritory(
      Name = 'Test territory',
      OperatingHoursId = oh.Id,
      PostalCode = '85004',
      State = 'AZ',
      City = 'Phoenix',
      Street = '77 East Polk Street',
      Country = 'United States',
      isActive = true
    );

    insert objServiceTerritory;
        ServiceResource objServiceResource=new ServiceResource(Name='Test Resource',RelatedRecordId=u.Id,ResourceType='T',IsActive=True);
        insert objServiceResource;     
    	ServiceTerritoryMember objServiceTerritoryMember = new ServiceTerritoryMember(ServiceResourceId =objServiceResource.id,ServiceTerritoryId=objServiceTerritory.Id,EffectiveStartDate=System.datetime.now().addDays(-1),TerritoryType ='P'  );
    	insert objServiceTerritoryMember;
    }
    
     @isTest
    public static void getCoachList(){
        User userTest = [SELECT id FROM User where alias = 'alias' LIMIT 1][0];
    string result = FEP_CoachBios.getCoachList();
     List<FEP_CoachBios.coachList> coaches =  (List<FEP_CoachBios.coachList>)JSON.deserialize(result, List<FEP_CoachBios.coachList>.class);
    Assert.areEqual(coaches.size(), 1, 'Expected 1 record');
    Assert.areEqual(coaches[0].coach_name, 'Test Resource', 'Name match');
    Assert.areEqual(coaches[0].title, 'title', 'Expected title');
    Assert.areEqual(coaches[0].aboutMe, 'Test description', 'Expected Test description');

        
    }
    
     @isTest
    public static  void getAppCandidatesTest() {
      String expectedResponse = '[' +
                                    '  {' +
                                    '    \"startTime\": \"2021-03-18T16:00:00.000+0000\",' +
                                    '    \"endTime\": \"2021-03-18T17:00:00.000+0000\",' +
                                    '    \"resources\": [' +
                                    '      \"0HnRM0000000Fxv0AE\"' +
                                    '    ],' +
                                    '    \"territoryId\": \"0HhRM0000000G8W0AU\"' +
                                    '  },' +
                                    '  {' +
                                    '    \"startTime\": \"2021-03-18T19:00:00.000+0000\",' +
                                    '    \"endTime\": \"2021-03-18T20:00:00.000+0000\",' +
                                    '    \"resources\": [' +
                                    '      \"0HnRM0000000Fxv0AE\"' +
                                    '    ],' +
                                    '    \"territoryId\": \"0HhRM0000000G8W0AU\"' +
                                    '  }' +
                                    ']';
      lxscheduler.SchedulerResources.setAppointmentSlotsMock (expectedResponse);

      Test.startTest();
      User u2 = [SELECT id FROM User where alias = 'alias2' LIMIT 1][0];
      System.runAs(u2) {
        ServiceResource objServiceResource =[SELECT Id from ServiceResource LIMIT 1][0];
        ServiceTerritory objServiceTerritory = [SELECT Id from ServiceTerritory LIMIT 1][0];
        string response = FEP_CoachBios.getCoachAvailableTime(objServiceResource.Id, objServiceTerritory.Id);
         System.assertEquals('Thu Mar 18 2021 12:00 PM Eastern Time', response, 'Response match');
      }
      Test.stopTest();
   }
}