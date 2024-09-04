/*********************************************************
*Class        :  AddressHistoryParserClass
*Author       :  Rajashree chinchole
*Description  :  Parser class for Address History Details
*********************************************************/
public class ksc_AddressHistoryParserClass {
     public static String STRING_BLANK ='';
    public static String STRING_SUCCESSCODE ='200';

     /****************************************************
     * @Description - Fetches a deserialised string with access token and returns a parsed request.     
     * @param strResponse -    String in serialzed format of ksc_IntegrationWrapperClass.
     * @return -  String, serialized Response .     
    *****************************************************/

   /* public static String generateParsedResponse(String strResponse){
       
        string strParsedResponse = STRING_BLANK;
        ksc_IntegrationWrapperClass objResponseOutput = new ksc_IntegrationWrapperClass();
        List<ksc_SampleParserResponseWrapper> lstJSONResponse = new List<ksc_SampleParserResponseWrapper>();   
        try{
            if(!String.isBlank(strResponse)){
                objResponseOutput =(ksc_IntegrationWrapperClass)JSON.deserialize(strResponse, ksc_IntegrationWrapperClass.class);
            }

            if(objResponseOutput != null && String.isNotBlank(objResponseOutput.strResponseStatusCode) && objResponseOutput.strResponseStatusCode.equals(STRING_SUCCESSCODE) &&
            String.isNotBlank(objResponseOutput.strResponseBody) ){ 
                if(objResponseOutput != null && String.isNotBlank(objResponseOutput.strResponseStatusCode) && objResponseOutput.strResponseStatusCode.equals(STRING_SUCCESSCODE) &&
                    String.isNotBlank(objResponseOutput.strResponseBody) ){ 
                        lstJSONResponse =  ( List<ksc_SampleParserResponseWrapper>)JSON.deserialize(objResponseOutput.strResponseBody,  List<ksc_SampleParserResponseWrapper>.class); 
                        List<ksc_FieldConfigurationWrapper> lstFieldConfigWrapper = new List<ksc_FieldConfigurationWrapper>();
                        //lstFieldConfigWrapper = generateFieldConfigWrapper(lstJSONResponse);
                        objResponseOutput.strResponseBody = JSON.serialize(lstFieldConfigWrapper);
                }
            }    
            else{
                objResponseOutput.isCalloutSuccess = false;
                if(!String.isBlank(strResponse)){
                    Map<String,Object> mapParse = (Map<String,Object>)JSON.deserializeUntyped(strResponse);
                }
            }
            strParsedResponse = JSON.serializePretty(objResponseOutput); 
            system.debug('@@output  '+ JSON.serializePretty(objResponseOutput));
        }
        catch(Exception objExp){
            system.debug('Exception ' + objExp.getMessage());
        }
        return strParsedResponse;
    }*/

    /****************************************************
     * @Description - Fetches a deserialised string and returns a parsed request.     
     * @param strIntegrationRequestWrapper -    String in serialzed format of ksc_IntegrationWrapperClass.
     * @return -  String, serialized request .     
    *****************************************************/

  /*  public static String generateRequestBody(String strIntegrationRequestWrapper){
        Map<String, String> mapAuthorizationHeaders = new  Map<String, String>();
        ksc_IntegrationWrapperClass objRequestStructure =  (ksc_IntegrationWrapperClass)JSON.deserialize(strIntegrationRequestWrapper, ksc_IntegrationWrapperClass.class);
        String strRequest = STRING_BLANK;
        return strIntegrationRequestWrapper;
    }*/

    /****************************************************
     * @Description - Generates the list of field config wrapper .     
     * @param strIntegrationRequestWrapper -    String in serialzed format of ksc_IntegrationWrapperClass.
     * @return -  List, serialized request .     
    *****************************************************/
    /*
    Select id, ksc_IsActive__c, ksc_DataType__c, ksc_FieldApi__c, ksc_FieldName__c, ksc_FieldPositioning__c, '+
    ' ksc_GroupName__c, ksc_HasTooltip__c, ksc_OrderNumber__c, ksc_PicklistValues__c, '+
    ' ksc_ProfilesVisibility__c, ksc_ToolTipText__c, ksc_IsVisible__c, '+
    */
   @AuraEnabled
    public static List<ksc_FieldConfigurationWrapper> generateFieldConfigWrapper(){
        List<ksc_FieldConfigurationWrapper> lstFieldConfigWrapper = new  List<ksc_FieldConfigurationWrapper>();
        String strWhereClause = ' ksc_FieldPositioning__c ='+'\'' +'Column Header'+'\'' + ' AND ksc_IsActive__c = true ';
        String strOrderByClause = ' ksc_OrderNumber__c';
        String strLimitClause = ' 100';
        String strWhereClauseUser = ' Id ='+'\'' + UserInfo.getUserId() +'\'';
        List<ksc_FieldConfigurationRecord__c> lstFieldConfigRecords = ksc_UtilityClass.getFieldConfigRecords(strWhereClause,strOrderByClause,strLimitClause);
        List<User> lstUser = ksc_UtilityClass.getUserDetails(UserInfo.getUserId());//strWhereClauseUser, STRING_BLANK, STRING_BLANK );
        
        if(lstFieldConfigRecords != null && lstFieldConfigRecords.size()>0){
            for( ksc_FieldConfigurationRecord__c objRecord :lstFieldConfigRecords){
                ksc_FieldConfigurationWrapper objFieldConfigWrapper = new ksc_FieldConfigurationWrapper();
                List<String> lstProfileVisible = new List<String>();
                String strProfiles = (objRecord.ksc_ProfilesVisibility__c !=null) ? objRecord.ksc_ProfilesVisibility__c : STRING_BLANK ;
                if( !String.IsBlank(strProfiles) && 
                    !lstUser.isEmpty() ){
                    lstProfileVisible = strProfiles.split(';');
                }
                if(lstProfileVisible.contains(lstUser[0].Profile.name)){
                    objFieldConfigWrapper.fieldAPI = objRecord.ksc_FieldApi__c;
                    objFieldConfigWrapper.label = objRecord.ksc_FieldName__c;
                    if(objRecord.ksc_DataType__c == 'Text'){
                        objFieldConfigWrapper.isString = true;
                        objFieldConfigWrapper.fieldValue = 'Test';
                    }
                    else if(objRecord.ksc_DataType__c == 'Date'){
                        objFieldConfigWrapper.isDate = true;
                        objFieldConfigWrapper.fieldValue = '15/11/2022';
                    }

                    objFieldConfigWrapper.decCardSize = objRecord.ksc_ColumnWidth__c;
                    objFieldConfigWrapper.intOrder = Integer.valueOf(objRecord.ksc_OrderNumber__c);
                    objFieldConfigWrapper.strGroupName = objRecord.ksc_GroupName__c;
                    lstFieldConfigWrapper.add(objFieldConfigWrapper);
                }
            }
        }
        Map<String, String> mapAuthorizationHeaders = new  Map<String, String>();
        //ksc_IntegrationWrapperClass objRequestStructure =  (ksc_IntegrationWrapperClass)JSON.deserialize(strIntegrationRequestWrapper, ksc_IntegrationWrapperClass.class);
        return lstFieldConfigWrapper;
    }

    public ksc_AddressHistoryParserClass() {

    }

}