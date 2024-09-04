/*********************************************************
** Class        :  ksc_IntegrationCalloutHandler_Test
** Author       :  Shreya Mathur
** Description  :  Test Class for ksc_IntegrationCalloutHandler
** Created Date :  Dec 7, 2022
** Parent Story Number : JIRA:1234
*********************************************************/

@isTest
public with sharing class ksc_IntegrationCalloutHandler_Test {
    @TestSetup
    static void setUpData(){
        Log__c objLog = new Log__c();
        insert objLog;
        LogEntry__c objLE = new LogEntry__c();
        objLE.Log__c  = objLog.id;
        objLE.LoggingLevel__c = 'INFO';
       // objLE.LoggedByUsernameLink__c = 'Anonymous';
        insert objLE;
        
    }
    
     /****************************************************
     * @Description - Test Initate Callout
    *****************************************************/
  
    @isTest
    public static void testInitiateCallout() {
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions();
        System.runAs(tUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ksc_MockHttpResponseGenerator_Test('{"example":"test"}'));
            Object obj = ksc_IntegrationCalloutHandler.initiateCallout('OtherProfileDetails_API','','');
            system.assertNotEquals(obj, null,'obj is not null');
            Test.stopTest();
        }
    }
    
    /****************************************************
     * @Description - Test Initate Callout Catch
    *****************************************************/
    @isTest
    public static void testInitiateCalloutCatch() {
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions();
        System.runAs(tUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ksc_MockHttpResponseGenerator_Test('{"example":"test"}'));
            Object obj = ksc_IntegrationCalloutHandler.initiateCallout('OtherProfileDetails_API','','');
            system.assertNotEquals(obj, null,'obj is not null');
            Test.stopTest();
       }    

    }
    
    /****************************************************
     * @Description - Test Static Resource
    *****************************************************/
    
    @isTest
    public static void testgenerateStaticResourceResponse() {
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions();
        System.runAs(tUser){
            ksc_IntegrationDetails__mdt objIntMetadata = new ksc_IntegrationDetails__mdt();
            objIntMetadata.ksc_ClassName__c = 'ksc_OtherProfileDetailsResponseParser';
            objIntMetadata.ksc_StaticResourceName__c = 'ksc_OtherProfileDetailsMockData';
            Test.startTest();
            Object obj = ksc_IntegrationCalloutHandler.generateStaticResourceResponse(objIntMetadata);
            system.assertNotEquals(obj, null,'obj is not null');
            Test.stopTest();
        }    
    }
    
    /****************************************************
     * @Description - Test Logging
    *****************************************************/
    @isTest
    public static void testlogIntegrationDetails() {
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions();
        System.runAs(tUser){
            ksc_IntegrationWrapperClass objWrapper = new ksc_IntegrationWrapperClass();
            Map<String,String> mapMock = new Map<String,String>();
            mapMock.put('Mock Header','MockHeader');
            objWrapper.strRequestBody = 'MockBody';
            objWrapper.strResponseRawJSON ='{"name":"test"}';
            objWrapper.strResponseRawJSON ='{"name":"test"}';
            objWrapper.mapRequestHeaders = mapMock;
            objWrapper.mapResponseHeaders = mapMock;
            objWrapper.strRequestEndpoint = 'MockEndpoint';
            Test.startTest();
            ksc_IntegrationCalloutHandler.logIntegrationDetails(objWrapper,'ksc_OtherProfileDetailsResponseParser');
            system.assertNotEquals(objWrapper.strRequestBody, null,'strRequestBody is not null');
            Test.stopTest();
        }    
    }
    
        /****************************************************
     * @Description - Test Integration Wrapper
    *****************************************************/
     @isTest
    public static void testIntegrationWrapperClass() {
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions();
        System.runAs(tUser){
        ksc_IntegrationDetails__mdt objIntMetadata = new ksc_IntegrationDetails__mdt();
        objIntMetadata.ksc_ClassName__c = 'ksc_OtherProfileDetailsResponseParser';
        objIntMetadata.ksc_StaticResourceName__c = 'ksc_OtherProfileDetailsMockData';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ksc_MockHttpResponseGenerator_Test('{"example":"test"}'));
            ksc_IntegrationWrapperClass objWrapper = new ksc_IntegrationWrapperClass();
            Map<String,String> mapMock = new Map<String,String>();
            mapMock.put('MockHeader','MockHeader');
            objWrapper.strRequestBody = 'MockBody';
            objWrapper.strResponseRawJSON ='{"name":"test"}';
            objWrapper.strResponseRawJSON ='{"name":"test"}';
            objWrapper.mapRequestHeaders = mapMock;
            objWrapper.mapResponseHeaders = mapMock;
            objWrapper.strResponseURL ='mock.com';
            objWrapper.strErrorMessage ='Mock Error Msg';
            objWrapper.strTokenExpireDateandTime = String.valueOf(System.today());
            objWrapper.objResponseData = 'Mock Object';
            objWrapper.dateStartValue = System.now();
            objWrapper.dateEndValue = System.now();
            objWrapper.strLWCCardDetails ='Mock Test';
            objWrapper.strRequestEndpoint = 'www.test.com';
			objWrapper.strURLExtension  = 'Mock Extension';  
            objWrapper.intTimeout = 10;
            
            ksc_IntegrationCalloutHandler.logIntegrationDetails(objWrapper,'SampleClassName');
            ksc_IntegrationCalloutHandler.serviceCallout(objWrapper);
            system.assertEquals(objWrapper.isCalloutSuccess, false,'callout is succss');
            
        Test.stopTest();
        }    
    }
    
     /****************************************************
     * @Description - Test Initate Failed Response
    *****************************************************/
    @isTest 
    private static  void testErrorJSONWrapper() {
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions();
        System.runAs(tUser){
        Test.startTest();
            ksc_IntegrationWrapperClass objWrapper = new ksc_IntegrationWrapperClass();
            KSC_ErrorJSONWrapper objError = new KSC_ErrorJSONWrapper();
            objError.transactionId = '123';
            KSC_ErrorJSONWrapper objErrorOutput = new KSC_ErrorJSONWrapper();
            objErrorOutput = objErrorOutput.parse(JSON.serialize(objError));
            system.assertEquals(objErrorOutput.transactionId, '123', 'Values Match');
            Test.stopTest();
        }
    }
    
      /****************************************************
     * @Description - Test Initate Failed Response
    *****************************************************/
    @isTest 
    private static  void testinsertAttachment() {
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions();
         List<StaticResource> lstSR = [SELECT Id, Body FROM StaticResource 
                                         WHERE Name = 'KSC_CardTxMockData'
                               WITH SECURITY_ENFORCED];
        List<LogEntry__c> lstLogEntry = new List<LogEntry__c>() ;
        lstLogEntry = [Select id , LoggedByUsernameLink__c , Log__c, Log__r.Name
                       FROM LogEntry__c 
                      ];
      Test.startTest();
            ksc_IntegrationWrapperClass objWrapper = new ksc_IntegrationWrapperClass();
            objWrapper.strResponseRawJSON = !lstSR.isEmpty()?lstSR[0].Body.toString() : ksc_Constants.STRING_NA;
            ksc_IntegrationCalloutHandler.logIntegrationDetails(objWrapper,'SampleClassName');
            system.assertEquals(objWrapper.strResponseRawJSON.length()>100 , true, 'Correct Length received');
            Test.stopTest();
       // }
    }
    
}