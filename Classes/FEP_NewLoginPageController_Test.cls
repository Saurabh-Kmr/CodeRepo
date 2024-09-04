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
private class FEP_NewLoginPageController_Test {

    @isTest
    static void loginCreationFieldsTest() {
       
        String sobjectName = 'User';
        Map<String, Schema.SObjectType> describeMapGlobal = Schema.getGlobalDescribe(); 
        Schema.SObjectType typeObj = describeMapGlobal.get(sobjectName);
        Schema.DescribeSObjectResult describeSobjectRes = typeObj.getDescribe();
        Map<String,Schema.FieldSet> fieldSetSchema = describeSobjectRes.FieldSets.getMap();
        //System.debug(fieldSetSchema.keySet());

        List<String> fieldSetName = new List<String>(fieldSetSchema.keySet());

        String jsonString = FEP_NewLoginPageController.loginCreationFields(sobjectName,fieldSetName[0]);

        System.assertEquals(jsonString,JSON.serialize(fieldSetSchema.get(fieldSetName[0]).getFields()));

    }
    
    @isTest
    static void verifyContactExistsTest(){
       
        String selfRegisterResult;
        selfRegisterResult = FEP_NewLoginPageController.verifyContactExists('Test','UserFep','9992228882','testfep@test.com','Email',false,'');
        Account genAcct = new Account(Name='General Account',Access_Code__c='123',Dialed_Phone_Number__c='18773580439',FEP_Timezone__c='America/New_York');
        insert genAcct;

        Contact con = new Contact(lastName='FEPTest',Company_Provided_Email__c='testfep2@test.com',Active__c=true,AccountId=genAcct.Id);
        insert con;
       selfRegisterResult = FEP_NewLoginPageController.verifyContactExists('Test','UserFep','9992228882','testfep2@test.com','Email',false,'test');
        
       // selfRegisterResult = FEP_NewLoginPageController.verifyContactExists('Test','UserFep','9992228882','testfep2@test.com','Email',false,'test');
        
        Contact con1 = new Contact(lastName='FEPTest',Company_Provided_Email__c='testfep3@test.com',Active__c=false);
        insert con1;
         selfRegisterResult = FEP_NewLoginPageController.verifyContactExists('Test','UserFep','9992228882','testfep3@test.com','Email',false,'test');
    }

    @isTest
    static void verifyContactExistsGeneralTest(){
       
        String selfRegisterResult;
       // selfRegisterResult = FEP_NewLoginPageController.verifyContactExists('Test','UserFep','9992228882','testfep@test.com','Email',false,'');
        Account genAcct = new Account(Name='General Account',Access_Code__c='123',Dialed_Phone_Number__c='18773580439',FEP_Timezone__c='America/New_York');
        insert genAcct;
        selfRegisterResult = FEP_NewLoginPageController.verifyContactExists('Test4','UserFep','9992228882','testfep4@test2.com','Email',true,'test');
    }

    @isTest
    static void verifyContactExistsSpecificAcountTest(){
       
        String selfRegisterResult;
       // selfRegisterResult = FEP_NewLoginPageController.verifyContactExists('Test','UserFep','9992228882','testfep@test.com','Email',false,'');
        Account genAcct = new Account(Name='General Account',Access_Code__c='123',Dialed_Phone_Number__c='18773580439',FEP_Timezone__c='America/New_York');
        insert genAcct;
        selfRegisterResult = FEP_NewLoginPageController.verifyContactExists('Test4','UserFep','9992228882','testfep4@test.com','Email',false,'test');
    }

}