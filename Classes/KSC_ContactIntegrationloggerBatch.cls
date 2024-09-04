/**
 * 
 * Class Name   :: KSC_ContactIntegrationloggerBatch
 * Author       :: Salesforce.com
 * Description  :: This class is used to reprocess the integration logger record to insert contacts of missing Account CRN
 * 
 */

global  class KSC_ContactIntegrationloggerBatch implements Database.Batchable<sObject>, Database.Stateful{
    public final String STATUS_COMPLETED = 'Completed'; 
    public List<Integration_Logger__c> loggerToinsert = new List<Integration_Logger__c>();

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        string category = KSC_ContactServiceHelper.INTEGRATION_CATEGORY;
        String query = 'SELECT Id,Name,Input_Json_String__c,Parent_Log__c FROM Integration_Logger__c WHERE Integration_Category__c=:category AND Status__c=\'New\' AND Integration_Type__c=\'InBound\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Integration_Logger__c> records){
        // process each batch of records
        List<Integration_Logger__c> loggerToupdate = new List<Integration_Logger__c>();

        for(Integration_Logger__c obj : records){
            obj.Status__c = STATUS_COMPLETED;
            loggerToupdate.add(obj);

            map<String,List<Object>>  createContactMapData = KSC_ContactServiceHelper.createConteactAndReturnResponse(obj.Input_Json_String__c);
            
            List<Object> crnMissingContacts = createContactMapData.get('missingContact');
            List<String> errorsWithMessage  = (List<String>)createContactMapData.get('errorContact');
            System.debug('errors with msgs =>'+errorsWithMessage);
            if(!crnMissingContacts.isEmpty()){
                loggerToinsert.add(New Integration_Logger__c(
                    Input_Json_String__c = JSON.serialize(crnMissingContacts),
                    Status__c = 'New',
                    Integration_Type__c = 'InBound',
                    Integration_Category__c = KSC_ContactServiceHelper.INTEGRATION_CATEGORY,
                    Parent_Log__c = obj.Id
                ));
            }
            if(!errorsWithMessage.isEmpty()){
                Logger.error(JSON.serialize(errorsWithMessage), obj.Id);
            }
        }
        Logger.saveLog();
        if(!loggerToupdate.isEmpty()){
            update loggerToupdate;
        }
        
    }    

    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
        if(!loggerToinsert.isEmpty()){
            insert loggerToinsert;
        }
    }    
}