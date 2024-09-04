@isTest
private class FEP_LogoutButtonController_Test {
 @TestSetup
   static void setUp(){
    Account genAcct = new Account(Name='General Account',Access_Code__c='123',Dialed_Phone_Number__c='18773580439',FEP_Timezone__c='America/New_York',FEP_CommunityLogoURL__c='Test Url',FEP_SurveyURL__c='Test Survey');
        insert genAcct;

        Contact con = new Contact(lastName='FEPTest',Company_Provided_Email__c='testfep2@test.com',Active__c=true,AccountId=genAcct.Id);
        insert con;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FEP Customer Community User - Custom'].Id,
            LastName = 'last',
            Email = 'testfep2@test.com',
            Username = 'puser000@pwc.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ContactId= con.Id
          );
          insert u;
   }
    
    @isTest
   static void getUserDetailsTest(){
    User userTest = [SELECT id FROM User where alias = 'alias' LIMIT 1][0];
    string result = FEP_LogoutButtonController.getUserDetails(userTest.id);
    Map<String, Object> resultObject = (Map<String, Object>)JSON.deserializeUntyped(result);
    Assert.areEqual(resultObject.get('fullName'), 'last', 'last Created');
    Assert.areEqual(resultObject.get('logoUrl'), 'Test Url', 'Expected Test Url');
    Assert.areEqual(resultObject.get('surveyUrl'), 'Test Survey', 'Expected Test Survey');
    Assert.areEqual(resultObject.get('isverified'), false, 'Expected false');



   }
}