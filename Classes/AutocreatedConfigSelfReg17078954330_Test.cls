/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AutocreatedConfigSelfReg17078954330_Test {



    @TestSetup
    static void createTestData(){
        Account testAccountParameter = new Account(Name='FEP Test Account',FEP_Timezone__c='America/New_York',WBS_Code_s__c='123',Dialed_Phone_Number__c='18773580439');

        insert testAccountParameter;
        
        Contact relatedContact= new Contact(lastName='FEP Test Contact',accountId=testAccountParameter.id);
        
        insert relatedContact;

    }

    @isTest
    static void createUserTest() {
        
        Account testAccountRecord = [Select Id,Name,(Select Id,Name from Contacts) from Account where Name = 'FEP Test Account' Limit 1];

        Profile testProfileParameter = [Select Id,Name from Profile where Name = 'Customer Community Plus Login User'];
        
        Schema.DescribeFieldResult contactFieldResult = User.contactId.getDescribe();
        Schema.sObjectField contactObjectField = contactFieldResult.getSObjectField();

        Map<sObjectField,String> registrationAttributes = new Map<sObjectField,String>();

        registrationAttributes.put(contactObjectField,testAccountRecord.Contacts[0].id);
    
        
        AutocreatedConfigSelfReg1707895433051 createUserTestObj = new AutocreatedConfigSelfReg1707895433051();
        String createdUserID = createUserTestObj.createUser(testAccountRecord.id,testProfileParameter.id,registrationAttributes,'');
        System.debug(createdUserID); 

        user fetchUser = [Select Id,Name,Alias from User where accountId=:testAccountRecord.id Limit 1];
        System.debug(fetchUser);
        
        
        System.assertEquals(createdUserID,fetchUser.id);
        
        
        //String identifier = UserManagement.initVerificationMethod(Auth.VerificationMethod.EMAIL);
        //String createUserSelfReg = AutocreatedConfigSelfReg1707895433051.createSelfRegisterUser(testAccountParameter.id,testProfileParameter.id,registrationAttributes,'',Auth.VerificationMethod.EMAIL);

        //System.debug(createUserSelfReg);
       // System.debug(testAccountParameter.id);
		       
      
      //  User u = 
    }
    
     @isTest
    static void createSelfRegisterUser() {
  		Account testAccountRecord = [Select Id,Name,(Select Id,Name from Contacts) from Account where Name = 'FEP Test Account' Limit 1];

        Profile testProfileParameter = [Select Id,Name from Profile where Name = 'Customer Community Plus Login User'];
        
        Schema.DescribeFieldResult contactFieldResult = User.contactId.getDescribe();
        Schema.sObjectField contactObjectField = contactFieldResult.getSObjectField();

        Map<sObjectField,String> registrationAttributes = new Map<sObjectField,String>();

        registrationAttributes.put(contactObjectField,testAccountRecord.Contacts[0].id);
        
        String createUserSelfReg = AutocreatedConfigSelfReg1707895433051.createSelfRegisterUser(testAccountRecord.id,testProfileParameter.id,registrationAttributes,'',Auth.VerificationMethod.EMAIL);

          System.assertEquals(createUserSelfReg,'USER_REGISTERED');
    }
}