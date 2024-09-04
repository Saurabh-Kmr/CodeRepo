public without sharing class Fep_ScheduleAppointmentController {
   
    
    @AuraEnabled
    public static TimeZoneWrapper getSelectedTimeZone(String userRecId){
        try {
            Decimal slotdurationValue;
            List<User> userList = new List<User>([SELECT Id,contact.Account.FEP_Timezone__c,contact.AccountId FROM User Where Id=:userRecId]);
            Map<String,String> tzMap = new Map<String,String>();
            Schema.DescribeFieldResult fieldDescription = Account.FEP_Timezone__c.getDescribe();
            List<Schema.PicklistEntry> entries = fieldDescription.getPicklistValues();

            for (Schema.PicklistEntry entry : entries) {
                if(entry.isActive()){
                    tzMap.put(entry.getValue(),entry.getLabel()); 
                }
            }
            if(userList[0].contact.Account.FEP_Timezone__c!=null){
                String tzValue = userList[0].contact.Account.FEP_Timezone__c;
                String tzLabel = tzMap.get(tzValue);
                slotdurationValue = getWorkType(userList[0].contact.AccountId).EstimatedDuration;
                TimeZoneWrapper tzWrp = new TimeZoneWrapper(tzLabel,tzValue);
                tzWrp.slotduration = JSON.serialize(slotdurationValue);
                return tzWrp;

            }
            return new TimeZoneWrapper('','');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<TimeZoneWrapper> getTimeZoneList(){
        List<TimeZoneWrapper> tzWrapperList = new List<TimeZoneWrapper>();
        Schema.DescribeFieldResult fieldDescription = Account.FEP_Timezone__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldDescription.getPicklistValues();
        for (Schema.PicklistEntry entry : entries) {
            if(entry.isActive()){
                TimeZoneWrapper tzWrap = new TimeZoneWrapper(entry.getLabel(),entry.getValue());
                tzWrapperList.add(tzWrap);
            }
        }
        return tzWrapperList;
    }

    @AuraEnabled(cacheable=true)
    public static String getContactRecord(String contactId){
        if(contactId == null){
            return null;
        }
        return Json.serialize([select id,name from contact where Id =: contactId LIMIT 1]);
    }

    @AuraEnabled(cacheable=true)
    public static String getAllAppointments(String contactId){
        Map<Id,ServiceAppointment> pastAppointments = new  Map<Id,ServiceAppointment>();
        List<AssignedResource> assignedResources = new  List<AssignedResource>();
        Map<Id,ServiceAppointmentData> coachData = new Map<Id,ServiceAppointmentData>();
        if(contactId != null){
            for(ServiceAppointment sa : [Select id,SchedStartTime,Assigned_Coach__r.Id,Assigned_Coach__r.Name from ServiceAppointment where contactId =: contactId AND status='Completed' AND SchedStartTime <= TODAY ORDER BY SchedStartTime desc LIMIT 2]){
                pastAppointments.put(sa.id,sa);
                ServiceAppointmentData newCoach = new ServiceAppointmentData();
                newCoach.serviceAppointmentId = sa.id;
                newCoach.lastAppointmentDate = changeDateTime(sa.SchedStartTime);
                coachData.put(sa.id,newCoach);
            }
        }
        assignedResources = getAssignedResource(pastAppointments.keySet());
        if(!assignedResources.isEmpty()){
            for(AssignedResource assResource : assignedResources){
                if(coachData.containsKey(assResource.ServiceAppointmentId)){
                    coachData.get(assResource.ServiceAppointmentId).coachName = assResource.ServiceResource.Name;
                    coachData.get(assResource.ServiceAppointmentId).coachId = assResource.ServiceResource.Id;
                }
            }
        }

        return Json.serialize(coachData.values());
    }

    public static List<AssignedResource> getAssignedResource(Set<Id> serviceAppointmentIds){
        if(serviceAppointmentIds == null){
            return new List<AssignedResource>();
        }
        return [select id,ServiceAppointmentId,ServiceResource.Name,ServiceResource.Id from AssignedResource where ServiceAppointmentId IN : serviceAppointmentIds];
    }
    
    public class  ServiceAppointmentData{
        @AuraEnabled public String serviceAppointmentId;
        @AuraEnabled public String coachId;
        @AuraEnabled public String coachName;
        @AuraEnabled public String lastAppointmentDate;
    }
    
    public static String changeDateTime(DateTime dateValue){
        String convertDate='';
        if(dateValue != null){
            convertDate =  dateValue.format('MMM') + ' ' + dateValue.day() + ', ' + dateValue.year();
        }
        return convertDate;
    }

    @AuraEnabled(cacheable=true)
    public static String getAvailableCoaches(){
        List<ServiceResource> allAvailableCoaches = [select id,name from ServiceResource where IsActive = true ];
        return Json.serialize(allAvailableCoaches);
    }

    /**
     * <---------------------------------INBOUD SCHEDULAR CODE------------------------------------>
     */
    @AuraEnabled
     public static String getAllAvailableTimeSlots(String selectedTime,String userId,String timeZone){
        try{
            
            String workTypeId;
            String serviceTerritoryId;
            DateTime selectedDateTime;
            DateTime formatSelectedDateTime;
            String rawTimeSlotData;
            List<Object> timeSlotDataList;
            Set<String> uniqueTimeSlots = new Set<String>();
            Map<String,Object> actualVsFormatTimeSlot = new Map<String,Object>();
            Map<String,Set<String>> timeSlotToCoachMap = new  Map<String,Set<String>>();
            TimeCoachData processedResult = new TimeCoachData();
            User userRecord = new User();
            WorkType workTypeRec;
            if(selectedTime != null){
               
                formatSelectedDateTime =  DateTime.valueOf(selectedTime +' '+ '00:00:00Z');
                userRecord = getUserRecord(userId);
                if(userRecord != null && userRecord.Contact != null && userRecord.Contact.AccountId != null){
                    workTypeRec = getWorkType(userRecord.Contact.AccountId);
                    workTypeId = workTypeRec.Id;
                }
                 serviceTerritoryId = getServiceTerritory();
                
                
                if(formatSelectedDateTime!= null && workTypeId != null && serviceTerritoryId != null){
                    
                    lxscheduler.WorkType workType = new lxscheduler.WorkTypeBuilder()
                        .setId(workTypeId)
                        .build();
                    lxscheduler.GetAppointmentCandidatesInput input = new lxscheduler.GetAppointmentCandidatesInputBuilder()
                        .setWorkType(workType)
                        .setTerritoryIds(new List<String>{serviceTerritoryId})
                        .setStartTime(formatSelectedDateTime.format('yyyy-MM-dd\'T\'HH:mm:ssZ',timeZone))
                        .setEndTime(formatSelectedDateTime.addDays(1).format('yyyy-MM-dd\'T\'HH:mm:ssZ',timeZone))
                        .setAccountId(null)
                        .setSchedulingPolicyId(null)
                        .setApiVersion(Double.valueOf('50.0'))
                        .build();

                    rawTimeSlotData = lxscheduler.SchedulerResources.getAppointmentCandidates(input);
                    if(rawTimeSlotData != null){
                        timeSlotDataList = (List<Object>) JSON.deserializeUntyped(rawTimeSlotData);
                        for(Object timeSlot : timeSlotDataList){
                            Map<String, Object> elementMap = (Map<String, Object>) timeSlot;
                            String startDateTime = correctDateTimeFormat((string)elementMap.get('startTime'));
                            String endDateTime = correctDateTimeFormat((String) elementMap.get('endTime'));
                            String coach =  (String)((List<Object>) elementMap.get('resources'))[0];
                            String formattedTimeSlots = createTimeSlots(startDateTime,endDateTime,timeZone);
                           
                            uniqueTimeSlots.add(formattedTimeSlots);
                            
                            if(!actualVsFormatTimeSlot.containsKey(formattedTimeSlots)){
                                actualVsFormatTimeSlot.put(formattedTimeSlots,timeSlot);
                            }
                           
                           
                             if(timeSlotToCoachMap.containsKey(formattedTimeSlots)){
                              
                                timeSlotToCoachMap.get(formattedTimeSlots).add(coach);
                            }else{
                              
                                timeSlotToCoachMap.put(formattedTimeSlots, new Set<String>{coach});
                            }
                            
                        }
                    }                                 
                }
            }
            processedResult.timeSlotData = JSON.serialize(uniqueTimeSlots);
            processedResult.coachData =  JSON.serialize(timeSlotToCoachMap);
            processedResult.actualVsFormatTimeSlot = JSON.serialize(actualVsFormatTimeSlot);
            return JSON.serialize(processedResult);
     }catch (Exception e) {
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

     public class TimeCoachData{
        String timeSlotData;
        String coachData;
        String actualVsFormatTimeSlot;
     }

     @AuraEnabled
     public static String getAvailableCoachData(List<String> coachIds){
        List<ServiceResource> allCoachesData = new  List<ServiceResource>();
        try {
            if(!coachIds.isEmpty()){
                if(coachIds != null ){
                    allCoachesData = [select id,name,Related_Work_Type__r.Name,RelatedRecord.mediumPhotoUrl from ServiceResource where Id IN:coachIds];
                }
            }
            return JSON.serialize(allCoachesData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
     }
     @AuraEnabled
     public static string getReviewScreenData(String selectedCoachId,String loggedInUserId){
        Id accountId;
        User userRecord;
        String workTypeName;
        ReviewScreenData reviewData = new ReviewScreenData();
        try {
            if(loggedInUserId != null){
                userRecord = getUserRecord(loggedInUserId);
                if(userRecord != null){
                    accountId = userRecord?.Contact?.AccountId;
                    reviewData.emailId = userRecord?.Email;
                    reviewData.contactId = userRecord?.contactId;
                }
                if(accountId != null){
                    reviewData.parentAccountId = accountId;
                }
                
            }
        return JSON.serialize(reviewData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
     }

     public static User getUserRecord(String loggedInUserId){
        return [select id,ContactId,Contact.AccountId,Email from user where Id=: loggedInUserId];
     }
     public class ReviewScreenData{
        String emailId;
        String workTypeName;
        String parentAccountId;
        String contactId;
     }
     

     @AuraEnabled
     public static String createServiceAppointments(String appStartTime,String appEndTime,String appCoachId,String appParentAccount,String appType,String appPhone,String appAdditionalInfo,String appContactId,
     String appointmentDateTimeText,String selectedTimeZoneValue,String appEmailId,String extNumber){
        try {
           
            ServiceAppointment newSA = new ServiceAppointment();
            AssignedResource res = new AssignedResource();
            Event event = new Event();

            if(appStartTime != null && appEndTime != null && appCoachId != null && appType != null){
                newSA.SchedStartTime = DateTime.valueOfGMT(correctDateTimeFormat(appStartTime));
                newSA.SchedEndTime = DateTime.valueOfGMT(correctDateTimeFormat(appEndTime));
                newSA.ArrivalWindowStartTime = DateTime.valueOfGMT(correctDateTimeFormat(appStartTime));
                newSA.ArrivalWindowEndTime = DateTime.valueOfGMT(correctDateTimeFormat(appEndTime));
                newSA.ParentRecordId = appParentAccount != null ? appParentAccount : '';
                newSA.Video_Call_Option__c = appType;
                newSA.Phone = appPhone;
                newSA.Description = appAdditionalInfo;
                newSA.ServiceTerritoryId = getServiceTerritory();
                newSA.ContactId = appContactId;
                newSA.workTypeId = getWorkType(appParentAccount).Id;
                newSA.FEP_AppointmentDateTimeText__c = appointmentDateTimeText;
                newSA.FEP_Timezone__c = selectedTimeZoneValue;
                newSA.Email = appEmailId;
                newSA.FEP_Ext__c = extNumber;
                if(newSA != null){
                    insert newSA;
                }
              

                if(newSA.id != null){
                    res.ServiceAppointmentId = newSA.id;
                    res.ServiceResourceId = appCoachId;
                    res.IsRequiredResource = true;
                    if(res != null){
                        insert res;
                    }
                
              
            }
            }
            return JSON.serialize(newSA);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
     }
     

     public static WorkType getWorkType(String accountId){
        return [select id,EstimatedDuration from WorkType  where FEP_RelatedAccount__c =: accountId LIMIT 1];
     }

     public static String getServiceTerritory(){
        return [select id from ServiceTerritory where IsActive = true LIMIT 1].Id;
     }



    public class TimeZoneWrapper{
        @AuraEnabled public string tzLabel;
        @AuraEnabled public string tzValue;
        @AuraEnabled public string slotduration;
        public TimeZoneWrapper(String tzLab, String tzVal){
            this.tzLabel = tzLab;
            this.tzValue = tzVal;
        }
    }
  
}