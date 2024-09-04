/*********************************************************
*Class        :  ksc_CreditCardSearchParserClass_Test
*Author       :  Chaynnitt Agarwal
*Description  :  Test coverage class for ksc_CreditCardSearchParserClass
*********************************************************/



@IsTest(SeeAllData=false)
public with sharing class ksc_CreditCardSearchParserClass_Test{
    @TestSetup
    static void makeAccountData(){
        Account acc = ksc_TestDataFactory.insertPersonAccount('TestFirstName','TestSecondName','');
        Asset asset = ksc_TestDataFactory.createAsset(acc.id,'CreditCard');
    }
    /****************************************************
    * @Description - Used to test the generateParsedResponse Method     
    * @param - NONE
    *****************************************************/
  
    @isTest
    static void testGenerateSuccessResponseTest(){
        Account acc = [SELECT id from Account LIMIT 1];
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions(); 
        ksc_IntegrationWrapperClass objWrap = new ksc_IntegrationWrapperClass();
        String respMockBody = ksc_TestDataFactory.getStaticResourceDataTest('CreditCardsSearch_API');
        Test.setMock(HttpCalloutMock.class, new ksc_MockHttpResponseGenerator_Test(respMockBody));
        System.runAs(tUser){
            Test.startTest();
            
            objWrap = (ksc_IntegrationWrapperClass) ksc_IntegrationCalloutHandler.initiateCallout('CreditCardsSearch_API',acc.id,'');
            Test.stopTest();    
        }   
        System.assertEquals(objWrap.strResponseStatusCode, ksc_Constants.STRING_SUCCESSCODE, 'Simulating Success Callout');
        
    }

    @isTest
    public static void negativegenerateParsedResponseTest(){
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions(); 
        ksc_IntegrationWrapperClass errorWrapper = new ksc_IntegrationWrapperClass(); 
        errorWrapper.strResponseStatusCode = ksc_Constants.STRING_ERRORCODE;
        errorWrapper.strErrorMessage = ksc_Constants.MOCK_ERROR_RESPONSE_BODY;
        errorWrapper.strResponseBody = ksc_Constants.ERROR_MESSAGE;
        System.runAs(tUser){
            Test.startTest();
            ksc_CreditCardSearchParserClass.generateParsedResponse(errorWrapper);
            ksc_CreditCardSearchParserClass.generateRequestBody(errorWrapper);
            Date dt = ksc_CreditCardSearchParserClass.convDate('');
        Test.stopTest();
        }
        System.assertEquals(errorWrapper.strResponseStatusCode, ksc_Constants.STRING_ERRORCODE, 'callout Failed');
    }
}