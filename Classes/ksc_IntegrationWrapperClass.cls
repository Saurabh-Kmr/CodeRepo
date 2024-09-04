/*********************************************************
*Class        :  ksc_IntegrationWrapperClass
*Author       :  Shreya Mathur
*Description  :  Wrapper Class for Integration Callout Framework
*********************************************************/
public with sharing class ksc_IntegrationWrapperClass {
    @AuraEnabled
    public Integer intTimeout {get; set;}   
    @AuraEnabled
    public String strRequestMethod {get; set;}
    @AuraEnabled
    public String strRequestBody {get; set;}
    @AuraEnabled
    public String strRequestEndpoint {get; set;}
    @AuraEnabled
    public String strResponseRawJSON{get; set;}
    @AuraEnabled
    public String strResponseBody {get; set;}
    @AuraEnabled
    public String strResponseURL {get; set;}
    @AuraEnabled
    public String strResponseStatusCode {get; set;}
    @AuraEnabled
    public String strErrorMessage {get; set;} 
    @AuraEnabled
    public String strTokenExpireDateandTime {get; set;} 
    @AuraEnabled
    public String strURLExtension {get; set;}  
	@AuraEnabled
    public String strContentType {get; set;} 
    @AuraEnabled
    public String strRecordId {get; set;}  
    @AuraEnabled
    public Boolean isCalloutSuccess {get; set;}     
    @AuraEnabled
    public Object objResponseData {get; set;}   
    @AuraEnabled
    public String strCustomMetadataDetails {get; set;}
    @AuraEnabled
    public DateTime dateStartValue {get; set;}
    @AuraEnabled
    public DateTime dateEndValue {get; set;}
    @AuraEnabled
    public Map<String, String> mapRequestHeaders {get; set;} 
    @AuraEnabled
    public Map<String, String> mapResponseHeaders {get; set;}
    @AuraEnabled
    public String strLWCCardDetails {get; set;} 
    @AuraEnabled
    public String strAdditionalData {get; set;} 
    /* Encryption Flags */
    @AuraEnabled
    public String strActualContentType {get; set;} 
    @AuraEnabled
    public Boolean enableEncryptionFlag {get; set;} 
              
              

    /*
    * description: Empty constructor is required for test class coverage.
    */
    
    public ksc_IntegrationWrapperClass() {
        this.isCalloutSuccess = false;
        this.mapRequestHeaders = new Map<String,String>();
    }
}