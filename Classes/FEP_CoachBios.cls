/*------------------------------------------------------------
Author:        Mohit Jain
Company:       Salesforce
Description:   Controller Class to show list of Coach on Coach Bios page
Inputs:                      
Test Class:    
History
14/03/2024      Mohit Jain    New Class Created for PR972315-16
------------------------------------------------------------*/


public without sharing class FEP_CoachBios {

    /*------------------------------------------------------------
    Author:        Mohit Jain
    Company:       Salesforce
    Description:   Function returns List of Service Resources(Coaches)
    Inputs:        
                   
    Returns:       String- Serialized data of active service resources
                
    History
   14/03/2024      Mohit Jain    New Class Function for PR972315-16
    ------------------------------------------------------------*/

    @AuraEnabled(cacheable=true)
    public static string getCoachList(){
       
        List<ServiceResource> listOfCoaches = [Select Id,Name,isActive,Description,RelatedRecord.mediumPhotoUrl,RelatedRecord.title,RelatedRecord.FEP_SchedulingSiteCoachBio__c,(Select ServiceTerritoryId,MemberNumber from ServiceTerritories  Limit 1 ) from ServiceResource where isActive = true AND RelatedRecord.isActive = true ORDER BY Name ASC];

        List<coachList> foramttedListOfCoach = new List<coachList>();


        for(ServiceResource sr : listOfCoaches){
            if (sr.ServiceTerritories[0].ServiceTerritoryId!=null) {
                coachList singleCoach = new coachList();

                singleCoach.serviceResourceId = sr.Id;
                singleCoach.coach_name = sr.Name;
    
              
                singleCoach.serviceTerritoryId = sr.ServiceTerritories[0].ServiceTerritoryId;
                
                singleCoach.mediumPhotoUrl = sr.RelatedRecord.MediumPhotoUrl;
                singleCoach.title = sr.RelatedRecord.title;
                singleCoach.aboutMe = sr.RelatedRecord.FEP_SchedulingSiteCoachBio__c;
                singleCoach.userId = sr.RelatedRecord.Id;
    
              
                foramttedListOfCoach.add(singleCoach);
            }
            
          
        }

        return JSON.serialize(foramttedListOfCoach);
    }

    public class coachList{


        @AuraEnabled
        public String serviceResourceId;

        @AuraEnabled
        public string coach_name;

        @AuraEnabled
        public string serviceTerritoryId;

        @AuraEnabled
        public string mediumPhotoUrl;

        @AuraEnabled
        public string title;

        @AuraEnabled
        public string aboutMe;

        
        @AuraEnabled
        public string userId;
    }

 /*------------------------------------------------------------
    Author:        Mohit Jain
    Company:       Salesforce
    Description:   Function returns List of Available Time Slots of Service Resources(Coaches)
    Inputs:        resourceId: Service Resource Id (Coach Id) for whom need to fetch time slots
                   territoryId: Territory Id of service resource
                   
    Returns:       String- Serialized data of Time slots of service resources
                
    History
   14/03/2024      Mohit Jain    New Class Function for PR972315-16
    ------------------------------------------------------------*/

    @AuraEnabled(cacheable=true)
    public static string getCoachAvailableTime(String resourceId, String territoryId){
        User userRecord = new User();
        String workTypeId;
        Decimal duration;
        WorkType workTypeRec;
        String timeZone;

        userRecord = getUserRecord(UserInfo.getUserId());

        if(userRecord != null && userRecord.Contact != null && userRecord.Contact.AccountId != null){
                  
            workTypeRec = getWorkType(userRecord.Contact.AccountId);
            workTypeId = workTypeRec.Id;
            duration = workTypeRec.EstimatedDuration;
            timeZone = userRecord.Contact.Account.FEP_Timezone__c;
        }

        lxscheduler.WorkType workType = new lxscheduler.WorkTypeBuilder()
        .setId(workTypeId)
        .build();

        System.debug(Integer.valueOf(System.Label.FEP_SchedulingSiteStartTime));
  
     lxscheduler.GetAppointmentSlotsInput input = new lxscheduler.GetAppointmentSlotsInputBuilder()
        .setWorkType(workType)
        .setStartTime(System.now().addDays(Integer.valueOf(System.Label.FEP_SchedulingSiteStartTime)).format('yyyy-MM-dd\'T\'HH:mm:ssZ'))
        .setEndTime(System.now().addDays(Integer.valueOf(System.Label.FEP_SchedulingSiteEndTime)).format('yyyy-MM-dd\'T\'HH:mm:ssZ'))
        .setTerritoryIds(new List<String>{territoryId})
        .setRequiredResourceIds(new List<String>{resourceId})
        .setApiVersion(Double.valueOf('50.0'))
        .build();
  
        String response = lxscheduler.SchedulerResources.getAppointmentSlots(input);
        system.debug(timeZone);
        List<FEP_GetAppointmentSlotWrapper> appointmentSlotList = (List<FEP_GetAppointmentSlotWrapper>) System.JSON.deserialize(response, List<FEP_GetAppointmentSlotWrapper>.class);
        if(appointmentSlotList.size()>0){
        DateTime gmtFormatTime =  DateTime.valueOfGmt(appointmentSlotList[0].startTime.replace('T',' ').removeEnd('+0000'));
        String scheduledTime = gmtFormatTime.format('EEE MMM dd yyyy h:mm a z',timeZone);
        return scheduledTime.replace('EDT','Eastern Time').replace('CDT','Central Time').replace('MDT','Mountain Time').replace('PDT','Pacific Time').replace('PDT','Pacific Time').replace('EST','Pacific Time').replace('CST','Pacific Time').replace('PST','Pacific Time').replace('MST','Mountain Time');
        }
        else{
            return 'No available appointments';
        }
    }

    public static User getUserRecord(String loggedInUserId){
        return [select id,ContactId,Contact.AccountId,Contact.Account.FEP_Timezone__c,Email from user where Id=: loggedInUserId];
    }
    
    public static WorkType getWorkType(String accountId){
        return [select id,EstimatedDuration from WorkType  where FEP_RelatedAccount__c =: accountId LIMIT 1];
    }
   
}