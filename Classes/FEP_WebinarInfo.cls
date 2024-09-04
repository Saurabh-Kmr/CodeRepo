/*------------------------------------------------------------
Author:        Mohit Jain
Company:       Salesforce
Description:   Controller Class to show list of Webinars associated with logged in user account
Inputs:                      
Test Class:    
History
21/03/2024      Mohit Jain    New Class Created for PR972315-59
------------------------------------------------------------*/




public without sharing class FEP_WebinarInfo {
    /*------------------------------------------------------------
       Author:        Mohit Jain
       Company:       Salesforce
       Description:   Function returns List of Webinars
       Inputs:        userRecordId - Logged in user record id
                      
       Returns:       String- Serialized data of appointments
                   
       History
      21/03/2024      Mohit Jain    New Class Function for PR972315-59
       ------------------------------------------------------------*/
   
   
       @AuraEnabled(cacheable = true)
       public static string getWebinarInfo(string userId){
   
           List<Campaign> campaignsList = new List<Campaign>();
           if(!String.isEmpty(userId)){
   
               User loggedInUser = [Select Id,Name,ContactId,Contact.AccountId,TimeZoneSidKey from User where id = :userId Limit 1];
               
   
               if(!String.isEmpty(loggedInUser.Contact.AccountId)){
   
                   campaignsList = [Select Name,StartDate,Start_Time__c,Attendee_URL__c from Campaign where IsActive = true AND Account_Name__c = :loggedInUser.Contact.AccountId AND StartDate  >=LAST_N_MONTHS:6 AND StartDate  <=NEXT_N_MONTHS:6 AND Type NOT IN('Email Blast','Fair','Local Webinar') AND Attendee_URL__c Like 'https%' order by StartDate DESC];
   
                  
   
                   return JSON.serialize(campaignsList);
               }
           }
   
           return JSON.serialize(campaignsList);
               
       }
       
   }