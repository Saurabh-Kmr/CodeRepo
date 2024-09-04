/*********************************************************
*Class        :  ksc_LimitDetailsParserClass_Test
*Author       :  Saurabh Kumar
*Description  :  Test class for Limit Details response
*********************************************************/


@isTest(SeeAllData = false)
private class ksc_LimitDetailsParserClass_Test {


    @TestSetup
    static void setUpData(){
        ksc_FieldConfigurationRecord__c config = ksc_TestDataFactory.insertFieldConfigRecord('Limit Details API','limitId','Limit ID','KSC-LMTDTLS-CLM-1');
        insert config;
        Account acc = ksc_TestDataFactory.insertPersonAccount('Test','Last','1234');
        Asset asset = ksc_TestDataFactory.createAsset(acc.id,'DebitCard');
    }
   
     /****************************************************
     * @Description - Used to test the generateParsedResponse Method     
     * @param - NONE
    *****************************************************/

    @isTest
    static void generateSuccessResponsePositiveTest(){
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions();
        ksc_IntegrationWrapperClass objWrap = new ksc_IntegrationWrapperClass();
       	String respMockBody = ksc_TestDataFactory.getStaticResourceDataTest('LimitDetails_API');
        Account acc = [Select id,CRN__c from Account limit 1];
        Test.setMock(HttpCalloutMock.class, new ksc_MockHttpResponseGenerator_Test(respMockBody));
        System.runAs(tUser){
            Test.startTest();
            objWrap = (ksc_IntegrationWrapperClass)ksc_IntegrationCalloutHandler.initiateCallout('LimitDetails_API',acc.CRN__c,'');
            Test.stopTest();
        }
        System.assertEquals(objWrap.strResponseStatusCode, ksc_Constants.STRING_SUCCESSCODE,'callout Success');
    }

    /****************************************************
     * @Description - Used to test the generateParsedResponse Method error block    
     * @param - NONE
    *****************************************************/
    @isTest
    public static void generateParsedResponseNegativeTest(){
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions();
        ksc_LimitDetailsResponseWrapper testWrapper = new ksc_LimitDetailsResponseWrapper();
        ksc_IntegrationWrapperClass errorWrapper = new ksc_IntegrationWrapperClass(); 
        errorWrapper.strResponseStatusCode = ksc_Constants.STRING_ERRORCODE;
        errorWrapper.strErrorMessage = ksc_Constants.MOCK_ERROR_RESPONSE_BODY;
        errorWrapper.strResponseBody = ksc_Constants.ERROR_MESSAGE;
        System.runAs(tUser){
            Test.startTest();
            ksc_LimitDetailsParserClass.generateParsedResponse(errorWrapper);
            ksc_LimitDetailsParserClass.generateRequestBody(errorWrapper);
            Test.stopTest();
        }
        System.assertEquals(errorWrapper.strResponseStatusCode, ksc_Constants.STRING_ERRORCODE, 'callout Failed');
    }
    
    /****************************************************
     * @Description - Used to test the getAccountId Method     
     * @param - NONE
    *****************************************************/
    @isTest
    public static void getCRNPostiveTest(){
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions();
        Asset loan = [Select id,Name from Asset limit 1];
        String str ;
        System.runAs(tUser){
            Test.startTest();
            str = ksc_LimitDetailsParserClass.getCRNFromAsset(loan.Id);
            Test.stopTest();
        }
        System.assertNotEquals(str, null, 'crn');
    }

    /****************************************************
     * @Description - Used to test the getAccountId Method     
     * @param - NONE
    *****************************************************/
    @isTest
    public static void getCRNNegativeTest(){
       try{
        String str ;
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions();
        System.runAs(tUser){
            Test.startTest();
            str = ksc_LimitDetailsParserClass.getCRNFromAsset('');
            Test.stopTest();
        }
    }catch(Exception objExp){
        string expMessage = objExp.getMessage();
        Boolean isInvalidID = expMessage.contains('Invalid id');
        System.assertEquals(true, isInvalidID,'Expectd response');
    }
    }
}