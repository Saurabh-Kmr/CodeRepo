/*------------------------------------------------------------
Author:        Mohit Jain
Company:       Salesforce
Description:   Controller Class to manage the logout link and company logo as well as survey URL from account
Inputs:                      
Test Class:    FEP_LogoutButtonController_Test
History
15/03/2024      Mohit Jain    New Class Created
------------------------------------------------------------*/
public  class FEP_LogoutButtonController {
  
    
    /*------------------------------------------------------------
    Author:        Mohit Jain
    Company:       Salesforce
    Description:   Function returns default value
    Inputs:        
    Returns:       String
               
    History
   15/03/2024      Mohit Jain    New Function 
    ------------------------------------------------------------*/ 
    @AuraEnabled(cacheable=true)
    public static string getUserDetails(String userId){
        User loggedInUser = [Select Name,ContactId,Contact.Name,Contact.Account.FEP_CommunityLogoURL__c,Contact.Account.FEP_SurveyURL__c from User where Id = :userId];
        List<TwoFactorMethodsInfo> info = [SELECT id,HasUserVerifiedMobileNumber,UserId from TwoFactorMethodsInfo where userId=:userId LIMIT 1];
        boolean isVerified = Test.isRunningTest()?false: info[0].HasUserVerifiedMobileNumber;
        userInfoWrapper formattedInfo = new userInfoWrapper();
        
        if(!String.isEmpty(loggedInUser.ContactId)){
            formattedInfo.fullName = loggedInUser.Name;
            formattedInfo.logoUrl = loggedInUser.Contact.Account.FEP_CommunityLogoURL__c;
            formattedInfo.surveyUrl = loggedInUser.Contact.Account.FEP_SurveyURL__c;
            formattedInfo.isverified = isVerified;
        }
        return JSON.serialize(formattedInfo);
    }


    public class userInfoWrapper{

        @AuraEnabled
        public string fullName;

        @AuraEnabled
        public string logoUrl;

        @AuraEnabled
        public string surveyUrl;
        @AuraEnabled
        public boolean isverified;
    }
}