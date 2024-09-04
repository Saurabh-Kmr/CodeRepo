public with sharing class Fep_reScheduleAppointmentScreen {
    
    @AuraEnabled
    public static String getAllAvailableTimeSlotsForCoach(String selectedTime,String userId,String serviceAppointmentId,String coachId,String timeZone){
       try{
           String workTypeId;
           String serviceTerritoryId;
           String serviceResource;
           DateTime selectedDateTime;
           DateTime formatSelectedDateTime;
           String rawTimeSlotData;
           List<Object> timeSlotDataList;
           Set<String> uniqueTimeSlots = new Set<String>();
           Map<String,Object> actualVsFormatTimeSlot = new Map<String,Object>();
           Map<String,Set<String>> timeSlotToCoachMap = new  Map<String,Set<String>>();
           TimeCoachData processedResult = new TimeCoachData();
           User userRecord = new User();
           Decimal duration;
           WorkType workTypeRec;
           if(selectedTime != null && coachId != null){
             
               formatSelectedDateTime =  DateTime.valueOf(selectedTime +' '+ '00:00:00Z');
               userRecord = getUserRecord(userId);
           
                if(userRecord != null && userRecord.Contact != null && userRecord.Contact.AccountId != null){
                  
                    workTypeRec = getWorkType(userRecord.Contact.AccountId);
                    workTypeId = workTypeRec.Id;
                    duration = workTypeRec.EstimatedDuration;
               }
                serviceTerritoryId = getServiceTerritory();
               
                serviceResource = coachId;
              
               if(formatSelectedDateTime!= null && workTypeId != null && serviceTerritoryId != null){
                   
                   lxscheduler.WorkType workType = new lxscheduler.WorkTypeBuilder()
                       .setId(workTypeId)
                       .build();
                   lxscheduler.GetAppointmentSlotsInput input = new lxscheduler.GetAppointmentSlotsInputBuilder()
                       .setWorkType(workType)
                       .setTerritoryIds(new List<String>{serviceTerritoryId})
                       .setStartTime(formatSelectedDateTime.format('yyyy-MM-dd\'T\'HH:mm:ssZ',timeZone))
                       .setEndTime(formatSelectedDateTime.addDays(1).format('yyyy-MM-dd\'T\'HH:mm:ssZ',timeZone))
                       .setAccountId(null)
                       .setRequiredResourceIds(new List<String>{serviceResource})
                       .setSchedulingPolicyId(null)
                       .setApiVersion(Double.valueOf('50.0'))
                       .build();

                   rawTimeSlotData = lxscheduler.SchedulerResources.getAppointmentSlots(input);
                   
                   if(rawTimeSlotData != null){
                       timeSlotDataList = (List<Object>) JSON.deserializeUntyped(rawTimeSlotData);
                       for(Object timeSlot : timeSlotDataList){
                       
                           Map<String, Object> elementMap = (Map<String, Object>) timeSlot;
                           String startDateTime = correctDateTimeFormat((string)elementMap.get('startTime'));
                           String endDateTime = correctDateTimeFormat((String) elementMap.get('endTime'));
                           String formattedTimeSlots = createTimeSlots(startDateTime,endDateTime,timeZone);
                          
                           uniqueTimeSlots.add(formattedTimeSlots);
                           
                           if(!actualVsFormatTimeSlot.containsKey(formattedTimeSlots)){
                               actualVsFormatTimeSlot.put(formattedTimeSlots,timeSlot);
                           }
                          
                          
                          }
                   }                                 
               }
           }
           processedResult.timeSlotData = JSON.serialize(uniqueTimeSlots);
           processedResult.actualVsFormatTimeSlot = JSON.serialize(actualVsFormatTimeSlot);
           if(serviceAppointmentId != null){
                processedResult.serviceAppointmentRecord = JSON.serialize(getServiceAppRecord(serviceAppointmentId));
           }
           processedResult.userRecord = JSON.serialize(userRecord);
           processedResult.slotduration = JSON.serialize(duration);
           return JSON.serialize(processedResult);
    }catch (Exception e) {
       throw new AuraHandledException(e.getMessage());
       }
    }
   
    @AuraEnabled
    public static string rescheduleServiceAppointments(String serviceAppId,String startDate,String endDate,String appType,String appPhone,String appAdditionalInfo,String appointmentDateTimeText,String selectedTimeZoneValue,String extNumber){
        try {
            ServiceAppointment serviceAppRec = new ServiceAppointment();
            if(serviceAppId != null){
                serviceAppRec = getServiceAppRecord(serviceAppId);
                if(startDate != null && endDate != null){
                    serviceAppRec.SchedStartTime = DateTime.valueOfGMT(correctDateTimeFormat(startDate));
                    serviceAppRec.SchedEndTime = DateTime.valueOfGMT(correctDateTimeFormat(endDate));
                    serviceAppRec.ArrivalWindowStartTime = DateTime.valueOfGMT(correctDateTimeFormat(startDate));
                    serviceAppRec.ArrivalWindowEndTime = DateTime.valueOfGMT(correctDateTimeFormat(endDate));
                    serviceAppRec.FEP_AppointmentDateTimeText__c = appointmentDateTimeText;
                    serviceAppRec.FEP_Timezone__c =  selectedTimeZoneValue;
                    serviceAppRec.FEP_Ext__c = extNumber;
                }
                if(appType != null || appPhone != null){
                    serviceAppRec.Video_Call_Option__c = appType != null ? appType : serviceAppRec.Video_Call_Option__c;
                    serviceAppRec.Phone = appPhone != null ? appPhone : serviceAppRec.Phone;
                }
                serviceAppRec.Description = appAdditionalInfo;
              
                update serviceAppRec;
            }
            return JSON.serialize(serviceAppRec);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static String createTimeSlots(String startDate,String endDate,String timeZone){
        
        //convert string to date time
        DateTime startDt = DateTime.valueOfGMT(startDate);
        DateTime endDt = DateTime.valueOfGMT(endDate);

        //convert datetime to AM/PM in GMT format
        String formatStartDt =  startDt.format('yyyy-MM-dd hh:mm:ss a',timeZone);
        String formatEndDt =   endDt.format('yyyy-MM-dd hh:mm:ss a',timeZone);

        //process date in correct format
        List<String> splitDateTimeStart = formatStartDt.split(' ');
        List<String> splitTimeStart = splitDateTimeStart[1].split(':');

        List<String> splitDateTimeEnd = formatEndDt.split(' ');
        List<String> splitTimeEnd = splitDateTimeEnd[1].split(':');
        
        String changeTimeSlot = splitTimeStart[0] + ':' +splitTimeStart[1] + ' - ' + splitTimeEnd[0] + ':' + splitTimeEnd[1] + ' ' + splitDateTimeStart[2];

        return changeTimeSlot;
     }
    public static string correctDateTimeFormat(String dateTimeStr){
        return dateTimeStr.replace('T',' ');
     }

     public static WorkType getWorkType(String accountId){
        return [select id,EstimatedDuration from WorkType  where FEP_RelatedAccount__c =: accountId LIMIT 1];
     }

     public static String getServiceTerritory(){
        return [select id from ServiceTerritory where IsActive = true LIMIT 1].Id;
     }
     public static String getServiceResource(String userId){
        return [select id from ServiceResource where IsActive = true and RelatedRecordId =: userId LIMIT 1].Id;
     }
     public static ServiceAppointment getServiceAppRecord(String saId){
        return [select id,Subject,Video_Call_Option__c,Phone,AppointmentNumber,ParentRecord.Name,Contact.Name,Email,ContactId, ParentRecordId,FEP_AppointmentDateTimeText__c,FEP_Timezone__c from ServiceAppointment where id=:saId];
     }
     public static User getUserRecord(String loggedInUserId){
        return [select id,ContactId,Contact.AccountId,Email from user where Id=: loggedInUserId];
     }
     public class TimeCoachData{
        String timeSlotData;
        String coachData;
        String actualVsFormatTimeSlot;
        String serviceAppointmentRecord;
        String userRecord;
        String slotduration;
     }
     
}