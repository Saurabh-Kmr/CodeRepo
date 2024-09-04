public with sharing class ksc_StatementDownloadParserClass implements ksc_IIntegrationHandler {

/****************************************************
* @Description -  Fetches and transforms the parsed request.
* @param objWrapper -  ksc_IntegrationWrapperClass .
* @return -  ksc_IntegrationWrapperClass .     
*****************************************************/
public static ksc_IntegrationWrapperClass generateParsedResponse(ksc_IntegrationWrapperClass intObjWrapper){
    try{
        if(intObjWrapper != null && String.isNotBlank(intObjWrapper.strResponseStatusCode) && intObjWrapper.strResponseStatusCode.equals(ksc_Constants.STRING_SUCCESSCODE) &&
           String.isNotBlank(intObjWrapper.strResponseRawJSON) ){
               intObjWrapper.isCalloutSuccess = true;
               
               ksc_StatementDownloadResponseWrapper responsewrapper = (ksc_StatementDownloadResponseWrapper)JSON.deserialize(intObjWrapper.strResponseRawJSON,ksc_StatementDownloadResponseWrapper.class);
               intObjWrapper.strResponseBody = JSON.serialize(responsewrapper?.data?.stmtDownld?.reqData);
           
           }else{
               intObjWrapper.isCalloutSuccess = false;
               KSC_ErrorJSONWrapper errorResponseWrapper = (KSC_ErrorJSONWrapper)JSON.deserialize(intObjWrapper.strResponseRawJSON,KSC_ErrorJSONWrapper.class);
               intObjWrapper.strErrorMessage =   JSON.serialize(errorResponseWrapper);  
           }
    }catch(Exception objExp){
        intObjWrapper.isCalloutSuccess = false;
    }
    return intObjWrapper;
    }

/****************************************************
* @Description - Fetches and updates request headers with access token and returns a structured headers for request.
* @param objRequestStructure -  ksc_IntegrationWrapperClass .
* @return -  ksc_IntegrationWrapperClass .      
*****************************************************/
public static ksc_IntegrationWrapperClass generateRequestBody(ksc_IntegrationWrapperClass objRequestStructure){
    Map<String, String> mapAuthorizationHeaders = new  Map<String, String>();
   // Asset assetRec = new Asset();
   // assetRec = [SELECT Id,Account.CRN__c FROM Asset WHERE Id = :objRequestStructure.strRecordId WITH SECURITY_ENFORCED LIMIT 1];
    objRequestStructure.strRequestEndpoint = objRequestStructure.strRequestEndpoint+objRequestStructure.strRecordId;
    
    Map<String,Object> lpw = (Map<String,Object>)JSON.deserializeUntyped(objRequestStructure.strLWCCardDetails);
    Blob b = Crypto.GenerateAESKey(128);
    String uuid = EncodingUtil.ConvertTohex(b);
    
    /* Auth Params */
    mapAuthorizationHeaders.put(ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_CORRELATIONID)?.ksc_Headerkey__c, ksc_UtilityClass.generateCorrelationId());
    mapAuthorizationHeaders.put(ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_CLIENTID)?.ksc_Headerkey__c, ksc_Constants.STRING_CREDUSERNAME);
    mapAuthorizationHeaders.put(ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_CLIENTSECRET)?.ksc_Headerkey__c, ksc_Constants.STRING_CREDPASSWORD);
    mapAuthorizationHeaders.put(ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_TRANSACTIONID)?.ksc_Headerkey__c,uuid);
    mapAuthorizationHeaders.put(ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_KOTAKSCRAPP)?.ksc_Headerkey__c, ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_KOTAKSCRAPP).ksc_HeaderValue__c);
    mapAuthorizationHeaders.put(ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_CARDNUMBER2)?.ksc_Headerkey__c, (String)lpw?.get('cardNumber'));
    mapAuthorizationHeaders.put(ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_STMTMON)?.ksc_Headerkey__c, (String)lpw?.get('stmtMonth'));
    mapAuthorizationHeaders.put(ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_STMTPATH)?.ksc_Headerkey__c, (String)lpw?.get('pathOfStmt'));
    mapAuthorizationHeaders.put(ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_PINCODE)?.ksc_Headerkey__c, (String)lpw?.get('pinCode'));
    mapAuthorizationHeaders.put(ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_TYPEPROD)?.ksc_Headerkey__c, (String)lpw?.get('typeOfProduct'));
    
    
    objRequestStructure.mapRequestHeaders = mapAuthorizationHeaders;
    return objRequestStructure;
}

@AuraEnabled
public static Boolean sendEmail(List<String> emailAddresses,String data){
    Boolean isSuccess;
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
    try {
        Blob body = EncodingUtil.base64Decode(data);
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName('test.pdf');
        attach.setInline(false);
        attach.Body = body;

        for(String emailAddress:emailAddresses){
            if(!String.isBlank(emailAddress)){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.saveAsActivity = false;
                mail.setTargetObjectId(emailAddress);
                mail.setSubject('Test Subject');
                mail.setPlainTextBody('This email body is empty');
                mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
                emailList.add(mail);
             }
        }
        if(!emailList.isEmpty()){
            Messaging.sendEmailResult[] sendEmailResults  = Messaging.SendEmail(emailList,false);
            for(Messaging.SendEmailResult sendEmailResult: sendEmailResults){
                
                isSuccess= true;
            }    
        } 
         
    } catch (Exception ex) {
        Logger.error(ex.getMessage());
        Logger.saveLog();
        isSuccess=false;
        throw new AuraHandledException(ex.getMessage());
    }
    return isSuccess;
}

}