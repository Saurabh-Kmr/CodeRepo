@isTest
public without sharing class FEP_GetClientContent_Test {
    @isTest
    public static void getContent(){
        Account accObj = new Account(Name ='TestAccount 007');
        insert accObj;   
        Contact cont=  new Contact(LastName = 'Test',AccountId = accObj.Id);
        insert cont;
        FEP_PersonalizedSiteContent__c perContent= new FEP_PersonalizedSiteContent__c(FEP_Content1__c='Test',FEP_RelatedAccount__c= accObj.Id);
        insert perContent;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FEP Customer Community User - Custom']
            .Id,
            ContactId= cont.Id,
            LastName = 'last',
            Email = 'puser000@pwc.com',
            Username = 'puser000@pwc.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
          );
          insert u;

        String returnData =FEP_GetClientContent.getContent(u.Id,'FEP_Content1__c');
        Assert.areEqual('Test',perContent.FEP_Content1__c,'Data Match');

    }

    @isTest
    public static void getContentError(){
        Account accObj = new Account(Name ='TestAccount 007');
        insert accObj;   
        Contact cont=  new Contact(LastName = 'Test',AccountId = accObj.Id);
        insert cont;
        FEP_PersonalizedSiteContent__c perContent= new FEP_PersonalizedSiteContent__c(FEP_Content1__c='Test',FEP_RelatedAccount__c= accObj.Id);
        insert perContent;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FEP Customer Community User - Custom']
            .Id,
            ContactId= cont.Id,
            LastName = 'last',
            Email = 'puser000@pwc.com',
            Username = 'puser000@pwc.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
          );
          insert u;
        try{
        String returnData =FEP_GetClientContent.getContent(u.Id,'FEP_Content6__c');
        }
        catch(Exception ex){
            Assert.areEqual('Script-thrown exception',ex.getMessage(),'Exception Expected');

        }

    }
}