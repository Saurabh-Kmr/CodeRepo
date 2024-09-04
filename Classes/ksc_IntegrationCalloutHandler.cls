/*********************************************************
** Class        :  IntegrationCalloutHandler
** Author       :  Shreya Mathur
** Description  : Class for Integration Callout Framework
** Created Date : Oct 10, 2022
** Last Modified by : Shreya 
** Last Modified Data : Nov 25, 2022
** Parent Story Number : NA
*********************************************************/
@SuppressWarnings(
    'PMD.AvoidDeeplyNestedIfStmts,PMD.CyclomaticComplexity,PMD.ClassNamingConventions,PMD.CognitiveComplexity'
)

public with sharing class ksc_IntegrationCalloutHandler {

    public static ksc_IntegrationWrapperClass objIntWrapper = new ksc_IntegrationWrapperClass();
    public static List<ksc_IntegrationDetails__mdt> lstIntMetadata = new List<ksc_IntegrationDetails__mdt>();
    public static final String STRING_PERCENT = '%';
    public static final String STRING_INFO = 'INFO';
    public static final String STRING_SAMPLE = 'Sample';
    public static final String STRING_S = 'S';
    public static final String STRING_CONTENT_TYPE = 'Content-Type';
    public static final String STRING_STATIC_RESPONSE= 'Response from Static Resource>> ';

    /****************************************************
     * @Description - Fetches the Custom Settings and Custom Metadata to invoke a callout.     
     * @param strSettingName -    Record Name of Custom Settings and Custom Metadata.    
     * @param strRecordId -    Record Id of the object thats permforming the callout
     * @param strLWCCardDetails -  Additional or Optional Details sent from LWC card.
     * @return Object-  Response.     
    *****************************************************/    
    @AuraEnabled
    public static Object initiateCallout(String strSettingName, String strRecordId, String strLWCCardDetails){        
        strSettingName = String.escapeSingleQuotes(strSettingName).replaceAll('[^\\w]','');  
        strRecordId = String.escapeSingleQuotes(strRecordId);
        String strbody  = ksc_Constants.STRING_BLANK;
        if(String.isNotBlank(strRecordId)){
            objIntWrapper.strRecordId = strRecordId;
        }
        if(String.isNotBlank(strLWCCardDetails)){
            objIntWrapper.strLWCCardDetails = strLWCCardDetails;
        }
        ksc_IntegrationDetails__mdt objIntMetadata = new ksc_IntegrationDetails__mdt();
        try{
            if(String.isNotBlank(strSettingName)){                      
                objIntMetadata = ksc_IntegrationDetails__mdt.getinstance(strSettingName);  
                if( objIntMetadata != null && 
                 objIntMetadata.ksc_IsActive__c == true){
                    Type objTypeInstance = Type.forName(objIntMetadata.ksc_ClassName__c);
                    ksc_IIntegrationHandler objIntInstance = (ksc_IIntegrationHandler)objTypeInstance.newInstance();
                    // Check if an actual callout needs to be performed
                    if(objIntMetadata.ksc_PerformsCallout__c == true){
                        if(!String.isBlank(objIntMetadata.ksc_AuthorizationMethod__c) 
                          && objIntMetadata.ksc_AuthorizationMethod__c.contains('Named Credential')
                          && !String.isBlank(objIntMetadata.ksc_AuthorizationMethodName__c)
                        ){ 
                            objIntWrapper.strRequestEndpoint ='callout:'+ objIntMetadata.ksc_AuthorizationMethodName__c + objIntMetadata.ksc_AdditionalURLParameter__c;
                        }
                        objIntWrapper.strRequestMethod = objIntMetadata.ksc_Method__c;
                        objIntWrapper.strContentType = objIntMetadata.ksc_ContentType__c ;
                        if(objIntMetadata.ksc_Timeout__c!=null){
                            objIntWrapper.intTimeout = Integer.valueOf(objIntMetadata.ksc_Timeout__c);
                        }
                        /* Encryption Params */
                        //objIntWrapper.enableEncryptionFlag = objIntMetadata.ksc_Encryption_Required__c;
                        if(!String.isBlank(objIntMetadata.ksc_Actual_Content_Type__c)){
                            objIntWrapper.strActualContentType = objIntMetadata.ksc_Actual_Content_Type__c;
                        }
                        /* Encryption Params */
                        objIntWrapper.strCustomMetadataDetails = JSON.serialize(objIntMetadata);
                        // Configuration of request body
                        strbody = JSON.serializePretty(objIntWrapper);   
                        objIntWrapper = objIntInstance.generateRequestBody(objIntWrapper);
                        objIntWrapper = serviceCallout(objIntWrapper);
                       if(objIntWrapper != null){
                            objIntWrapper = objIntInstance.generateParsedResponse(objIntWrapper);
                        }
                        if(objIntMetadata.ksc_EnableDebug__c == true){
                            logIntegrationDetails(objIntWrapper,objIntMetadata.ksc_ClassName__c);
                        }
                    }
                    // Create a static resource generated response without the actual callout
                    else{
                        return generateStaticResourceResponse(objIntMetadata);
                    }                   
                }
            }
        }
        catch(Exception objExp){
            Logger.error(objExp.getMessage());
            Logger.saveLog();
        }
        return  objIntWrapper;    
    }

   /****************************************************
     * @Description - Performs Http callout.
     * @param strRequestDetails -  Contains Request details such as Enpoints, Method etc.
     * @return -  Response in serialzied String format (Response of Integration)  .       
    *****************************************************/   
    public static ksc_IntegrationWrapperClass serviceCallout( ksc_IntegrationWrapperClass objRequestDetails){
            Map<String,String> mapRequestHeaders = objRequestDetails.mapRequestHeaders;
            Map<String, String> mapResponseheaders = new map<String, String>();          
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();       
            Http h = new Http(); 
            if(!String.isBlank(objRequestDetails.strRequestEndpoint)){
                req.setEndpoint(objRequestDetails.strRequestEndpoint );
            }
            if(!String.isBlank(objRequestDetails.strRequestMethod )){
                req.setMethod(objRequestDetails.strRequestMethod );
            }
            if(objRequestDetails.intTimeout != null){
                req.setTimeout(Integer.valueOf(objRequestDetails.intTimeout));
            }
            /* Encryption Headers */
            if(!String.isBlank(objRequestDetails.strActualContentType)){
                mapRequestHeaders.put(ksc_Constants.HRD_ACTUAL_CONTENT_TYPE, objRequestDetails.strActualContentType);
            }
            //mapRequestHeaders.put(ksc_Constants.HRD_REQUIRED_ENCRYPTION, String.valueOf(objRequestDetails.enableEncryptionFlag));
            /* Encryption Headers */
            if(mapRequestHeaders!= null){
                for(String header : mapRequestHeaders.keySet()){
                    if(mapRequestHeaders.get(header) != null){
                        req.setHeader(header, mapRequestHeaders.get(header));                   
                    }
                }
            }

        	if(!String.isBlank(objRequestDetails.strRequestBody)){               
				req.setBody(objRequestDetails.strRequestBody);
            }
            if(!String.isBlank(objRequestDetails.strContentType)){
               req.setHeader(STRING_CONTENT_TYPE , objRequestDetails.strContentType);               
            }
            
            res = h.send(req);      
        	
            if(res.getHeaderKeys() != null){
                List<String> lstheaderkeys = res.getHeaderKeys();               
                if(!lstheaderkeys.isEmpty()){
                    for(String strKey : lstheaderkeys){
                        mapResponseheaders.put(strKey , res.getHeader(strKey));
                    }
                }
            }
            objRequestDetails.strResponseStatusCode = String.valueOf(res.getStatusCode());
            // objRequestDetails.strResponseRawJSON = res.getBody(); 
            // system.debug('[+] res.getBody() >> '+res.getBody()); 
            objRequestDetails.strResponseRawJSON = ksc_UtilityClass.doDecryption(mapResponseheaders, res.getBody());           
            if(!mapResponseheaders.isEmpty()){
                objRequestDetails.mapResponseHeaders = mapResponseheaders;
            }
        return objRequestDetails;
    } 

     /*********************************************************************************
    * @Description - Processes the Response with Static Resource Input
    * @param objIntMetadata -Instance of ksc_IntegrationDetails__mdt. 
    * @return -  String-  Parsed response.  
    **********************************************************************************/
   
    public static Object generateStaticResourceResponse(ksc_IntegrationDetails__mdt objIntMetadata){
 Type objTypeInstance = Type.forName(objIntMetadata.ksc_ClassName__c);
        ksc_IIntegrationHandler objIntInstance = (ksc_IIntegrationHandler)objTypeInstance.newInstance();
        objIntWrapper.isCalloutSuccess = false;
        objIntWrapper.strResponseBody = ksc_Constants.STRING_BLANK;  

        // The debug statement is required in order to check if the callout response was generated via mock response
        
        system.debug(STRING_STATIC_RESPONSE);                        
        if(String.IsNotBlank(objIntMetadata.ksc_StaticResourceName__c) ){
            StaticResource objStaticResource = new StaticResource();
            List<StaticResource> lstSR = [SELECT Id, Body FROM StaticResource 
                                         WHERE Name = : objIntMetadata.ksc_StaticResourceName__c
                                         WITH SECURITY_ENFORCED];
            if(lstSR != null && !lstSR.isEmpty()){
                objStaticResource = lstSR[0]; 
            }
            if(objStaticResource !=null && objStaticResource.Body != null && objStaticResource.Body.toString() != null){                                
                objIntWrapper.isCalloutSuccess = true;
                objIntWrapper.strResponseStatusCode = ksc_Constants.STRING_SUCCESSCODE;
                objIntWrapper.strResponseRawJSON = objStaticResource.Body.toString();    
                objIntWrapper.strResponseBody = objStaticResource.Body.toString(); 
                return objIntInstance.generateParsedResponse(objIntWrapper);
            }
        }
        return objIntWrapper;
    }

     /****************************************************
     * @Description - Stores the integration Details.
     * @param objIntMdt -  Contains The Custom Metadata Record
     * @return - void.       
    *****************************************************/
    public static void logIntegrationDetails( ksc_IntegrationWrapperClass objRequestDetails,String strClassName ){
        ksc_LoggerOutput objLogger = new ksc_LoggerOutput();
        Boolean boolAttachment = false;
        objLogger.strRequestBody = String.isNotBlank(objRequestDetails.strRequestBody) ? objRequestDetails.strRequestBody : ksc_Constants.STRING_NA;
        if(objRequestDetails.mapRequestHeaders!=null && !objRequestDetails.mapRequestHeaders.isEmpty()){
            objLogger.strRequestHeader =  JSON.serialize(objRequestDetails.mapRequestHeaders);
        }
        objLogger.strRequestEndpoint = String.isNotBlank(objRequestDetails.strRequestEndpoint) ? objRequestDetails.strRequestEndpoint : ksc_Constants.STRING_NA ;
        if(objRequestDetails.mapResponseHeaders!= null && !objRequestDetails.mapResponseHeaders.isEmpty()){
            objLogger.strResponseHeader = JSON.serialize(objRequestDetails.mapResponseHeaders);
        }
        objLogger.strMethodName = objRequestDetails.strRequestMethod;
        objLogger.strParserName = strClassName;

        if( String.isNotBlank(objRequestDetails.strResponseRawJSON)){
            if (objRequestDetails.strResponseRawJSON.length() < ksc_Constants.INT_ATTACHMENT_SIZE){
                objLogger.strResponseBody = objRequestDetails.strResponseRawJSON;
            }
            else {
                boolAttachment = true;
                objLogger.strResponseBody = ksc_Constants.STR_ATTACHMENT;
            }
        }
        Logger.info(JSON.serializePretty(objLogger));
        Logger.saveLog();
        if(boolAttachment){
            insertAttachment(objRequestDetails.strResponseRawJSON);
        }
    }

    /****************************************************
     * @Description - Method to Insert the Response as Attachment for bigger responses 
     * @param strRawJSON -  Contains Response
     * @return - void.       
    *****************************************************/

    @future
    private static void insertAttachment(String strRawJSON){
        String strUserName =  STRING_PERCENT+ Userinfo.getUserName() + STRING_PERCENT ;
       List<Profile> lstProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() WITH SECURITY_ENFORCED LIMIT 1];
        List<LogEntry__c> lstLogEntry = new List<LogEntry__c>() ;
        if(lstProfile!= null && lstProfile[0].Name.contains('Admin')){
            lstLogEntry = [Select id , LoggedByUsernameLink__c , Log__c, Log__r.Name
                           FROM LogEntry__c 
                           WHERE LoggedByUsernameLink__c LIKE :strUserName
                           AND LoggingLevel__c =: STRING_INFO WITH SECURITY_ENFORCED
                           ORDER by createddate DESC LIMIT 1 ];
            if(Test.isRunningTest()){
              lstLogEntry = [Select id , LoggedByUsernameLink__c , Log__c, Log__r.Name
                            FROM LogEntry__c WITH SECURITY_ENFORCED
                            LIMIT 1 ];            
            }
            if(lstLogEntry!= null && lstLogEntry.size()>0 &&
              Schema.sObjectType.ContentVersion.fields.ContentLocation.isCreateable() &&
              Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable() &&
              Schema.sObjectType.ContentVersion.fields.Title.isCreateable() &&
              Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable()
              ){
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.ContentLocation = STRING_S; 
                contentVersion.PathOnClient = STRING_SAMPLE;
                contentVersion.Title = ksc_Constants.STR_ATTACHMENT_HEADER + lstLogEntry[0].Log__r.Name;
                Blob body = blob.valueOf(strRawJSON);
                contentVersion.VersionData = body;
                insert contentVersion;
                
                ContentVersion objcontentVersion = [Select id, ContentDocumentId FROM ContentVersion where id=:contentVersion.id WITH SECURITY_ENFORCED];
                if(objcontentVersion != null && 
                    Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable() &&
                    Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable() &&
                    Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable() &&
                    Schema.sObjectType.ContentDocumentLink.fields.ShareType.isCreateable()){
                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                contentDocumentLink.ContentDocumentId = objcontentVersion.ContentDocumentId;
                contentDocumentLink.LinkedEntityId = lstLogEntry[0].id;
                contentDocumentLink.ShareType = 'I'; 
                insert contentDocumentLink;
                }
            }
        } 
    }

    /****************************************************
     * @Description - Wrapper Class for Deserialization of the UI Card Details
    *****************************************************/ 
    private class ksc_LoggerOutput{
        private  String strRequestEndpoint;
        private  String strMethodName;
        private  String strRequestHeader;
        private  String strRequestBody;
        private  String strResponseHeader;
        private  String strResponseBody;
        private  String strParserName;


        /****************************************************
         * @Description - Default Construtor 
        *****************************************************/  
        private ksc_LoggerOutput(){
            this.strRequestEndpoint = ksc_Constants.STRING_NA;
            this.strMethodName = ksc_Constants.STRING_NA;
            this.strRequestHeader = ksc_Constants.STRING_NA;
            this.strRequestBody = ksc_Constants.STRING_NA;
            this.strResponseHeader = ksc_Constants.STRING_NA;
            this.strResponseBody = ksc_Constants.STRING_NA;
            this.strParserName = ksc_Constants.STRING_NA;
        }
    }
  
}