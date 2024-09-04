/*------------------------------------------------------------
Author:        Saurabh Kumar
Company:       Salesforce
Description:   Controller Class to fetch required field data to display on site
Inputs:                      
Test Class:    FEP_GetClientContent_Test
History
15/03/2024      Saurabh Kumar    New Class Created
------------------------------------------------------------*/
public without sharing class FEP_GetClientContent {

    /*------------------------------------------------------------
    Author:        Saurabh Kumar
    Company:       Salesforce
    Description:   Function returns field content requested based on user
    Inputs:        userId- Id of logged in User
                   field - field API name for which data needs to be fetched
    Returns:       String- Content of required filed
               
    History
   15/03/2024      Saurabh Kumar    New Function 
    ------------------------------------------------------------*/ 
  @AuraEnabled(cacheable=true)
  public static string getContent(Id userId,String field){
      string result;
      try{
      string queryString = 'SELECT {0} FROM FEP_PersonalizedSiteContent__c WHERE FEP_RelatedAccount__c ={1} Order by createddate desc LIMIT 1';
      List<User> usrList = [SELECT Id,Contact.Account.Id FROM User WHERE Id =:userId];
      if(!usrList.isEmpty()&& usrList[0].Contact.Account.Id!=null){
          List<Object> parameters = new List<Object> {String.escapeSingleQuotes(field), '\''+usrList[0].Contact.Account.Id+'\'' };
          String dynamicQuery = String.format(queryString,parameters);
          List<Sobject> fieldData = Database.query(dynamicQuery);
          if(!fieldData.isEmpty()){
              result=(String)fieldData[0].get(String.escapeSingleQuotes(field));
          }
      }
      return result;
    }
    catch(Exception ex){
      throw new AuraHandledException(ex.getMessage());
    }
  }
}