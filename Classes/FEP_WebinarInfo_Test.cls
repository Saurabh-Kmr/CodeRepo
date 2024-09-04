@isTest
private class FEP_WebinarInfo_Test {

    @isTest
    static void getWebinarInfoTest(){

        Profile p = [SELECT Id FROM Profile WHERE Name='Customer Community Plus Login User']; 
        User testUser = new user();

        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        Contact testContact =new Contact(lastName = 'tContact',Email='test@contact.com');
        
        UserRole testRole = [Select Id,Name from UserRole where DeveloperName='SDC'];

        insert testContact;
        System.runAs (thisUser) {
            Account acc = new Account(Name='Test Account',Access_Code__c='123',Dialed_Phone_Number__c='18773580439',FEP_Timezone__c='America/New_York');
            insert acc;
    
            testContact.accountId = acc.id;
    
            update testContact;
    
       
            testUser.Alias = 'tUser';
            //testUser.UserRoleId = testRole.Id;
            testUser.Email='testing@salesforce.com';
            testUser.EmailEncodingKey='UTF-8';
            testUser.LastName='Testing';
            testUser.LanguageLocaleKey='en_US';
            testUser.LocaleSidKey='en_US';
            testUser.ProfileId = p.Id;
            testUser.TimeZoneSidKey='America/Los_Angeles';
            testUser.UserName='standarduser@testorg.com';
            testUser.ContactId  = testContact.Id;

            insert testUser;
    
        }
       


        

        
        String testResult = FEP_WebinarInfo.getWebinarInfo(testUser.Id);

        List<Campaign> listResult1 =(List<Campaign>)JSON.deserialize(testResult,List<Campaign>.class);

        System.assertEquals(0,listResult1.size());



        Account acc = [SELECT id,name FROM Account WHERE Name ='Test Account' LIMIT 1][0];


      //  testContact.accountId = acc.id;

      //  update testContact;

        Campaign testCamp = new Campaign(Name='Test Campaign',Account_Name__c=acc.id,isActive=true,Attendee_URL__c='https://Test.com',Type='Financial wellbeing class',StartDate=Date.today());
        insert testCamp;
        String testResult2 = FEP_WebinarInfo.getWebinarInfo(testUser.Id);

        List<Campaign> listResult =(List<Campaign>)JSON.deserialize(testResult2,List<Campaign>.class);
        System.assertEquals(1,listResult.size());

    }
   


}