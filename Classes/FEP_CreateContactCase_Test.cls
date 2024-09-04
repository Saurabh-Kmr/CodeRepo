@isTest
private class FEP_CreateContactCase_Test {

    @TestSetup
    static void setUp(){
        Account genAcct = new Account(Name='General Account',WBS_Code_s__c='123',Dialed_Phone_Number__c='18773580439');
        insert genAcct;

        Contact con = new Contact(lastName='FEPTest',Company_Provided_Email__c='testfep2@test.com',Active__c=true,AccountId=genAcct.Id);
        insert con;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FEP Customer Community User - Custom'].Id,
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
            ContactId= con.Id
          );
          insert u;
        
    }

    @isTest
    static void getRecordTypeIdAndQueueOwnerTest() {
       
        string result = FEP_CreateContactCase.getRecordTypeIdAndQueueOwner('FEP_SchedulingSiteCase','Case');
        Assert.isNotNull(result, 'Result expected');
    }

    @isTest
    static void getUserInfoTest() {
       Id userId = [SELECT ID,name FROM USER LIMIT 1][0].id;
        User result = FEP_CreateContactCase.getUserInfo(userId);
        Assert.isNotNull(result, 'Result expected');
    }

    @isTest
    static void getRecordTypeIdAndQueueOwnerTestException() {
        try{
            List<Group> queues= [SELECT name,id from group where DeveloperName = 'FEP_PWCAdminQueue'  AND Type ='Queue'];
            delete queues;
            string result=FEP_CreateContactCase.getRecordTypeIdAndQueueOwner('FEP_SchedulingSiteCase','Case');
        }catch(Exception ex){
            system.debug(ex.getMessage());
        }
    }
}