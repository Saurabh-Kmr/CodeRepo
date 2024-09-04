/*********************************************************
*Class        :  ksc_LimitDetailsParserClass
*Author       :  Saurabh Kumar
*Description  :  Parser class for Limit Details response
*********************************************************/

public with sharing class ksc_LimitDetailsParserClass implements ksc_IIntegrationHandler{
    
    /****************************************************
     * @Description - Fetches a deserialised string with access token and returns a parsed request.     
     * @param strResponse -    String in serialzed format of ksc_IntegrationWrapperClass.
     * @return -  String, serialized Response .     
    *****************************************************/
    public static ksc_IntegrationWrapperClass generateParsedResponse(ksc_IntegrationWrapperClass intObjWrapper){
        
        try{
            if(intObjWrapper != null && String.isNotBlank(intObjWrapper.strResponseStatusCode) && intObjWrapper.strResponseStatusCode.equals(ksc_Constants.STRING_SUCCESSCODE) &&
               String.isNotBlank(intObjWrapper.strResponseRawJSON) ){
                   intObjWrapper.isCalloutSuccess = true;
                   ksc_LimitDetailsResponseWrapper responsewrapper = (ksc_LimitDetailsResponseWrapper)JSON.deserialize(intObjWrapper.strResponseRawJSON,ksc_LimitDetailsResponseWrapper.class);
                   
                   ksc_DataTableWrapper dataTableInstance1 = new ksc_DataTableWrapper();
                   dataTableInstance1 = ksc_UtilityClass.fetchDataTableWrapper('Limit Details API');
                   dataTableInstance1.rowData = json.serialize(responsewrapper.data.limitInfo);
                   intObjWrapper.strResponseBody = JSON.serialize(dataTableInstance1);
               }else{
                   intObjWrapper.isCalloutSuccess = false;
                   KSC_ErrorJSONWrapper errorResponseWrapper = (KSC_ErrorJSONWrapper)JSON.deserialize(intObjWrapper.strResponseRawJSON,KSC_ErrorJSONWrapper.class);
                   intObjWrapper.strErrorMessage =   JSON.serialize(errorResponseWrapper);  
               }
        }catch(Exception objExp){
            intObjWrapper.isCalloutSuccess = false;
            Logger.error(objExp.getMessage());
            Logger.saveLog();
        }
        return intObjWrapper;
    }

      /****************************************************
     * @Description - Fetches a deserialised string and returns a parsed request.     
     * @param strIntegrationRequestWrapper -    String in serialzed format of ksc_IntegrationWrapperClass.
     * @return -  String, serialized request .     
    *****************************************************/

    public static ksc_IntegrationWrapperClass generateRequestBody(ksc_IntegrationWrapperClass objRequestStructure){
        Map<String, String> mapAuthorizationHeaders = new  Map<String, String>();
        objRequestStructure.strRequestEndpoint = objRequestStructure.strRequestEndpoint+objRequestStructure.strRecordId;
        Blob b = Crypto.GenerateAESKey(128);
        String uuid = EncodingUtil.ConvertTohex(b).substring(0, 25);
        mapAuthorizationHeaders.put(ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_TRANSACTIONID).ksc_Headerkey__c,uuid);
        mapAuthorizationHeaders.put(ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_BANKID)?.ksc_Headerkey__c,ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_BANKID)?.ksc_HeaderValue__c);
        mapAuthorizationHeaders.put(ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_CHANNELID)?.ksc_Headerkey__c,ksc_IntegrationHeader__mdt.getinstance(ksc_Constants.HRD_CHANNELID)?.ksc_HeaderValue__c);
        mapAuthorizationHeaders= ksc_UtilityClass.populateAuthHeaders(ksc_Constants.HRD_CORRELATIONID,ksc_UtilityClass.generateCorrelationId(),mapAuthorizationHeaders);
        mapAuthorizationHeaders= ksc_UtilityClass.populateAuthHeaders(ksc_Constants.HRD_KOTAKSCRAPP,ksc_Constants.STRING_BLANK,mapAuthorizationHeaders);
        mapAuthorizationHeaders= ksc_UtilityClass.populateAuthHeaders(ksc_Constants.HRD_CLIENTID,ksc_Constants.STRING_CREDUSERNAME,mapAuthorizationHeaders);
        mapAuthorizationHeaders= ksc_UtilityClass.populateAuthHeaders(ksc_Constants.HRD_CLIENTSECRET,ksc_Constants.STRING_CREDPASSWORD,mapAuthorizationHeaders);
        objRequestStructure.mapRequestHeaders = mapAuthorizationHeaders;
        return objRequestStructure;
    }

    /****************************************************
     * @Description - fetches CRN for an asset     
     * @param assetID -    Id of asset for which crn is reuired
     * @return -  String .     
    *****************************************************/

    @AuraEnabled(cacheable = true)
    public static string getCRNFromAsset(ID assetID){
        string crn;
        try {
            Asset asset = [SELECT Id,Account.CRN__c FROM ASSET WHERE id =:assetID with SECURITY_ENFORCED];
            if(asset!=null){
                crn = asset.Account.CRN__c;
            }
            
        } catch(Exception objExp) {
                Logger.error(objExp.getMessage());
                Logger.saveLog();
        }
        return crn;
    }
}