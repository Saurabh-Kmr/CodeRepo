/*------------------------------------------------------------
Author:        Saurabh Kumar
Company:       Salesforce
Description:   Controller Class to Create Case for non existing contact
Inputs:                      
Test Class:    FEP_CreateContactCase_Test
History
26/02/2024      Saurabh Kumar    New Class Created for PR972315-99
------------------------------------------------------------*/
public with sharing class FEP_CreateContactCase {
     
    public static final String EXCEPTION_MESSAGE = 'No eligible queue found';

     /*------------------------------------------------------------
    Author:        Saurabh Kumar
    Company:       Salesforce
    Description:   Function returns recordtype Id for name
    Inputs:        recordTypeName - record type name
                   sObjectName - Sobject for which to get recordtypeId
    Returns:       Id- returns true or false based operation status
                
    History
   26/02/2024      Saurabh    New Function Created for PR972315-99
    ------------------------------------------------------------*/
    @AuraEnabled(cacheable=true)
    public static String getRecordTypeIdAndQueueOwner(String recordTypeName,String sObjectName){
        try {
                String recordTypeId= Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
                List<Group> queues= [SELECT name,id from group where DeveloperName = 'FEP_PWCAdminQueue'  AND Type ='Queue'];
                String queueId;
                if(!queues.isEmpty()){
                    queueId = queues[0].Id;
                }
                else{
                    throw new ListException(EXCEPTION_MESSAGE);
                }
                return recordTypeId+','+queueId;
        
        }  
        catch (Exception e) {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

      /*------------------------------------------------------------
    Author:        Saurabh Kumar
    Company:       Salesforce
    Description:   Function returns user record
    Inputs:        userId - user Id of user
    Returns:       User- record of user
                
    History
   27/02/2024      Saurabh    New Function Created for PR972315-99
    ------------------------------------------------------------*/
    @AuraEnabled(cacheable=true)
    public static User getUserInfo(String userId){
        try {
              List<User> users = [SELECT FirstName,Lastname,MobilePhone,Email,ContactId,Account.Name,isportalenabled From User WHERE Id=:userId AND IsPortalEnabled= true];
              return !users.isEmpty()?users[0]:new User();
        
        }  
        catch (Exception e) {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}