@isTest
private class Fep_loginandverification_Test {

   @TestSetup
   static void setUp(){
    Account genAcct = new Account(Name='General Account',Access_Code__c='123',Dialed_Phone_Number__c='18773580439',FEP_Timezone__c='America/New_York');
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
   static void handleLoginAndVerificationTest(){
    Contact con = [SELECT id FROM Contact where Company_Provided_Email__c = 'testfep2@test.com' LIMIT 1];
    Test.setFixedSearchResults(new List<Id>{con.id}) ;
    string result =Fep_loginandverification.handleLoginAndVerification('testfep2@test.com','email');
    Map<String, Object> resultObject = (Map<String, Object>)JSON.deserializeUntyped(result);
    Assert.areEqual(resultObject.get('identifier'), 'Created', 'Expected Created');
    Assert.areEqual(resultObject.get('isSuccess'), true, 'Expected True');
   }


   @isTest
   static void handleLoginAndVerificationNoUserTest(){
    Id accnt =[SELECT Id from Account LIMIT 1][0].Id;
    Contact con = new Contact(lastName='FEPTest',Company_Provided_Email__c='testfep1@test.com',Active__c=true,AccountId=accnt);
    insert con;
    Test.setFixedSearchResults(new List<Id>{con.id});
    string result =Fep_loginandverification.handleLoginAndVerification('testfep1@test.com','email');
    Map<String, Object> resultObject = (Map<String, Object>)JSON.deserializeUntyped(result);
    Assert.areEqual(resultObject.get('identifier'), 'SelfRegister', 'SelfRegister Expected');
    Assert.areEqual(resultObject.get('isSuccess'), false, 'Expected False');
    Assert.areEqual(resultObject.get('message'),'The email address you entered is not registered with us. ', 'Message Match');
    Assert.areEqual(resultObject.get('userId'),'Please register yourself by clicking here ', 'Id Match');

    
   }

   @isTest
   static void handleRegisterMobile(){
    string result =Fep_loginandverification.registerMobile();
    Map<String, Object> resultObject = (Map<String, Object>)JSON.deserializeUntyped(result);
    Assert.areEqual(resultObject.get('identifier'), 'Created', 'Expected Created');
    Assert.areEqual(resultObject.get('isSuccess'), true, 'Expected True');  
   }

   @isTest
   static void handleVerifyMobile(){
    string result =Fep_loginandverification.verifyMobile('mobile');  
    Assert.areEqual(result, 'Created', 'Expected Created');    
   }
  /* @isTest
   static void handleLoginAndVerificationInActiveTest(){
    Id accnt =[SELECT Id from Account LIMIT 1][0].Id;
    Contact con = new Contact(lastName='FEPTest',Company_Provided_Email__c='testfep3@test.com',Active__c=false,AccountId=accnt);
        insert con;
    string result =Fep_loginandverification.handleLoginAndVerification('testfep3@test.com','email');
    Map<String, Object> resultObject = (Map<String, Object>)JSON.deserializeUntyped(result);
    Assert.areEqual(resultObject.get('identifier'), '/impacted-employees', 'Impacted Employee');
    Assert.areEqual(resultObject.get('isSuccess'), false, 'Expected False');
    Assert.areEqual(resultObject.get('message'),'The email address you entered is not registered with us. ', 'Message Match');
    Assert.isNull(resultObject.get('userId'),'User Id is null');
    
   }*/

   @isTest
   static void handleLoginAndVerificationNoContactTest(){
    string result =Fep_loginandverification.handleLoginAndVerification('testfep4@test5.com','email');
    Map<String, Object> resultObject = (Map<String, Object>)JSON.deserializeUntyped(result);
    Assert.areEqual(resultObject.get('identifier'), 'contact-us', 'contact us expected');
    Assert.areEqual(resultObject.get('isSuccess'), false, 'Expected False');
    Assert.isNotNull(resultObject.get('userId'),'User Id not null');   
   }


   @isTest
   static void handleLoginAndVerificationSpecialContactTest(){
    string result =Fep_loginandverification.handleLoginAndVerification('testfep@test2.com','email');
    Map<String, Object> resultObject = (Map<String, Object>)JSON.deserializeUntyped(result);
    Assert.areEqual(resultObject.get('identifier'), 'SelfRegister', 'SelfRegister Expected');
    Assert.areEqual(resultObject.get('isSuccess'), false, 'Expected False');
    Assert.isNotNull(resultObject.get('userId'),'User Id not null');   
   }

   @isTest
   static void handleResendTest(){
    Id userId = [SELECT ID FROM USER LIMIT 1][0].Id;
    string result =Fep_loginandverification.handleResend(userId,'email');
    Map<String, Object> resultObject = (Map<String, Object>)JSON.deserializeUntyped(result);
    Assert.areEqual(resultObject.get('identifier'), 'Created', 'Expected Created');
    Assert.areEqual(resultObject.get('isSuccess'), true, 'Expected True');
   }

   @isTest
   static void handleLoginAndVerificationSpecialContactMobileTest(){
    string result =Fep_loginandverification.handleLoginAndVerification('testfep@test6.com','mobile');
    Map<String, Object> resultObject = (Map<String, Object>)JSON.deserializeUntyped(result);
    Assert.areEqual(resultObject.get('identifier'), 'contact-us', 'contact us expected');
    Assert.areEqual(resultObject.get('isSuccess'), false, 'Expected False');
    Assert.isNotNull(resultObject.get('userId'),'User Id not null');    
   }
}