@isTest(SeeAllData = false)
private class ksc_StatementListParserClass_Test {


    @TestSetup
    static void setUpData(){
        Account acc = ksc_TestDataFactory.insertPersonAccount('Test','Last','1234');
    }
    
     /****************************************************
     * @Description - Used to test the generateParsedResponse Method     
     * @param - NONE
    *****************************************************/

    @isTest
    static void generateSuccessResponsePositiveTest(){
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions();
        ksc_IntegrationWrapperClass objWrap = new ksc_IntegrationWrapperClass();
       	String respMockBody = ksc_TestDataFactory.getStaticResourceDataTest('StatementList_API');
        Account acc = [Select id,CRN__c from Account limit 1];
        Test.setMock(HttpCalloutMock.class, new ksc_MockHttpResponseGenerator_Test(respMockBody));
        System.runAs(tUser){
            Test.startTest();
            objWrap = (ksc_IntegrationWrapperClass)ksc_IntegrationCalloutHandler.initiateCallout('StatementList_API',acc.CRN__c,'{"cardNumber":"00078967","financialYear":"22-23","typeOfProduct":"CCARD"}');
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
        errorWrapper.strLWCCardDetails='{"cardNumber":"00078967","financialYear":"22-23","typeOfProduct":"CCARD"}';
        errorWrapper.strErrorMessage = ksc_Constants.MOCK_ERROR_RESPONSE_BODY;
        errorWrapper.strResponseBody = ksc_Constants.ERROR_MESSAGE;
        System.runAs(tUser){
            Test.startTest();
            ksc_StatementListParserClass.generateParsedResponse(errorWrapper);
            ksc_StatementListParserClass.generateRequestBody(errorWrapper);
            Test.stopTest();
        }
        System.assertEquals(errorWrapper.strResponseStatusCode, ksc_Constants.STRING_ERRORCODE, 'callout Failed');
    }
}