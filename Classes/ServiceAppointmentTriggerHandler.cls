/*------------------------------------------------------------
Author: Saurabh Kumar
Company: Salesforce
Description: Handler class for Service Appointment Trigger
Inputs: 
Test Class: ServiceAppointmentTriggerHandler_Test
History
<04/03/2024>  <Saurabh Kumar>     <Initial Creation>
------------------------------------------------------------*/
public class ServiceAppointmentTriggerHandler extends TriggerHandler {
    
    
    /*------------------------------------------------------------
    Author: Prabhat Sharma
    Company: Salesforce
    Description: Function to populate the calendar links on Service Appointment
    Inputs: 
    Returns: 
    History
    <04/05/2024>     <Prabhat Sharma>     <Initial Creation>
    ------------------------------------------------------------*/
    
    public override void beforeUpdate() {
        Map<Id,ServiceAppointment> oldMap = (Map<Id,ServiceAppointment>)Trigger.oldMap;

        for(ServiceAppointment sAObj : (List<ServiceAppointment>)Trigger.new){ 
            if(sAObj.SchedStartTime!=null && 
                sAObj.SchedEndTime!=null && 
                sAObj.FEP_Timezone__c!=null && 
                (sAObj.Phone!=null || (!String.isEmpty(sAObj.Video_Call_Link__c) && (oldMap.get(sAObj.Id).Video_Call_Link__c!=sAObj.Video_Call_Link__c)) || (sAObj.schedStartTime!=oldMap.get(sAObj.Id).schedStartTime))){
                
                DateTime startTime = sAObj.SchedStartTime;
                DateTime endTime = sAObj.SchedEndTime;
                AssignedResource assResource =[SELECT ServiceResource.Id,ServiceResource.Name, ServiceResource.RelatedRecord.Email FROM AssignedResource WHERE ServiceAppointmentId =:sAObj.Id ORDER BY createddate desc LIMIT 1];
                //Generate for Google Calendar
                String startDtString = formatDateTimeGoogleYahoo(startTime,sAObj.FEP_Timezone__c);
                String endDtString = formatDateTimeGoogleYahoo(endTime,sAObj.FEP_Timezone__c);
                String meetingLink='';
                if(String.isNotBlank(sAObj.Video_Call_Link__c)){
                    meetingLink=EncodingUtil.urlEncode(sAObj.Video_Call_Link__c, 'UTF-8');
                }

                sAObj.FEP_AddToCalendarGoogle__c = 'https://calendar.google.com/calendar/render?action=TEMPLATE&dates='+startDtString+'%2F'+endDtString+'&text=Your%20upcoming%20financial%20coaching%20appointment - '+sAObj.AppointmentNumber;

                //Append meeting link only if its an email appointment
                if(String.isNotBlank(meetingLink)&&sAObj.Video_Call_Option__c!='Call Me'){
                    sAObj.FEP_AddToCalendarGoogle__c+='&details=Please%20join%20the%20meeting%20using%20the%20link%20below.'+'<br><br><a href='+meetingLink+'>Join the meeting</a>'+'<br><br>If you need to reschedule or cancel, '+'<a href='+sAObj.FEP_ServiceAppointmentSiteLink__c+'>click here</a>.';
                }
                else{
                    sAObj.FEP_AddToCalendarGoogle__c+='&details=Your%20Financial%20Coach%20<strong>'+assResource.ServiceResource.Name+'</strong>%20will%20call%20you%20at%20<strong>'+sAObj.Phone.replace('+1 ','')+'</strong>%2E'+'<br><br>If you need to reschedule or cancel, '+'<a href='+sAObj.FEP_ServiceAppointmentSiteLink__c+'>click here</a>.';
                }


                String startDtYhString = formatDateTimeYahoo(startTime,sAObj.FEP_Timezone__c);
                String endDtYhString = formatDateTimeYahoo(endTime,sAObj.FEP_Timezone__c);
                //Generate for Yahoo Calendar
                sAObj.FEP_AddToCalendarYahoo__c = 'https://calendar.yahoo.com/?dur=&et='+endDtYhString+'&st='+startDtYhString+'+&v=60&title=Your%20upcoming%20financial%20coaching%20appointment - '+sAObj.AppointmentNumber;

                //Append meeting link only if its an email appointment
                if(String.isNotBlank(meetingLink)&&sAObj.Video_Call_Option__c!='Call Me'){
                    sAObj.FEP_AddToCalendarYahoo__c+='&desc=Please%20join%20the%20meeting%20using%20the%20link%20below%0A%0A'+meetingLink;
                }
                else{
                    sAObj.FEP_AddToCalendarYahoo__c+='&desc=Your%20Financial%20Coach%20'+assResource.ServiceResource.Name+'%20will%20call%20you%20at%20'+sAObj.Phone.replace('+1 ','')+'%0A%2E'+'If you need to reschedule or cancel, click here '+sAObj.FEP_ServiceAppointmentSiteLink__c;
                }

                //Generate for Outlook Calendar
                String startDtStr = formatDateTimeOutLook(startTime,sAObj.FEP_Timezone__c); 
                String endDtStr = formatDateTimeOutLook(endTime,sAObj.FEP_Timezone__c);
                String baseUrl = 'https://outlook.office365.com/calendar/0/action/compose?allday=false&';
                sAObj.FEP_AddToCalendarOutlook__c = baseUrl+'enddt='+endDtStr+'&path=%2Fcalendar%2Faction%2Fcompose&rru=addevent&startdt='+startDtStr+'&subject=Your%20upcoming%20financial%20coaching%20appointment%20-%20'+sAObj.AppointmentNumber;

                //Append meeting link only if its an email appointment
                if(String.isNotBlank(meetingLink)&&sAObj.Video_Call_Option__c!='Call Me'){
                    sAObj.FEP_AddToCalendarOutlook__c+='&body=Please%20join%20the%20meeting%20using%20the%20link%20below.%0A%0A'+'<br><br><a href='+meetingLink+'>Join the meeting</a>'+'<br><br>If you need to reschedule or cancel, '+'<a href='+sAObj.FEP_ServiceAppointmentSiteLink__c+'>click here</a>.';
                }
                else{
                    sAObj.FEP_AddToCalendarOutlook__c+='&body=Your%20Financial%20Coach%20'+'<strong>'+assResource.ServiceResource.Name+'</strong>%20will%20call%20you%20at%20<strong>'+sAObj.Phone.replace('+1 ','')+'</strong>%2E'+'<br><br>If you need to reschedule or cancel, '+'<a href='+sAObj.FEP_ServiceAppointmentSiteLink__c+'>click here</a>.';
                }
            }
        }
    }



    /*------------------------------------------------------------
    Author: Prabhat Sharma
    Company: Salesforce
    Description: Function to format the add to calendar links
    Inputs: 
    Returns: 
    History
    <04/05/2024>     <Prabhat Sharma>     <Initial Creation>
    ------------------------------------------------------------*/
    public String formatDateTimeGoogleYahoo(DateTime dtValue, String timeZone){
        //Final String to carry the dateTime in specific format
        String finalString;

        String strConvertedDate = dtValue.formatGMT('yyyy-MM-dd HH:mm:ss');
        //Format the Date in specified timezone
        List<String> dateTimeList = strConvertedDate.split(' ');
        String dateString = dateTimeList[0];
        dateString = dateString.replaceAll('-','');
        //Format the Time in specified timezone
        List<String> timeStringList = dateTimeList[1].split(':');
        String timeString = timeStringList[0]+timeStringList[1];
        //DateTime in required format
        finalString = dateString+'T'+timeString+'00Z';
        
        return finalString;
    }

    /*------------------------------------------------------------
    Author: Prabhat Sharma
    Company: Salesforce
    Description: Function to format the add to calendar links
    Inputs: 
    Returns: 
    History
    <04/05/2024>     <Prabhat Sharma>     <Initial Creation>
    ------------------------------------------------------------*/
    public String formatDateTimeYahoo(DateTime dtValue, String timeZone){
        //Final String to carry the dateTime in specific format
        String finalString;

        String strConvertedDate = dtValue.format('yyyy-MM-dd HH:mm:ss');
        //Format the Date in specified timezone
        List<String> dateTimeList = strConvertedDate.split(' ');
        String dateString = dateTimeList[0];
        dateString = dateString.replaceAll('-','');
        //Format the Time in specified timezone
        List<String> timeStringList = dateTimeList[1].split(':');
        String timeString = timeStringList[0]+timeStringList[1];
        //DateTime in required format
        finalString = dateString+'T'+timeString+'00Z';
        
        return finalString;
    }

    /*------------------------------------------------------------
    Author: Prabhat Sharma
    Company: Salesforce
    Description: Function to format the add to calendar links
    Inputs: 
    Returns: 
    History
    <04/05/2024>     <Prabhat Sharma>     <Initial Creation>
    ------------------------------------------------------------*/
    public String formatDateTimeOutLook(DateTime dtValue, String timeZone){
        //Final String to carry the dateTime in specific format
        String finalString;

        String strConvertedDate = dtValue.formatGMT('yyyy-MM-dd HH:mm:ss');
        //Format the Date in specified timezone
        List<String> dateTimeList = strConvertedDate.split(' ');
        String dateString = dateTimeList[0]; 
        //Format the Time in specified timezone
        List<String> timeStringList = dateTimeList[1].split(':');
        String timeString = timeStringList[0]+':'+timeStringList[1]+':'+'00+00:00';
        //DateTime in required format
        String tempString = dateString+'T'+timeString;
        
        finalString = EncodingUtil.urlEncode(tempString, 'UTF-8');

        return finalString;
    }


    /*------------------------------------------------------------
    Author: Saurabh Kumar
    Company: Salesforce
    Description: Function to execute after insert logic
    Inputs: 
    Returns: 
    History
    <04/03/2024>     <Saurabh Kumar>     <Initial Creation>
    ------------------------------------------------------------*/
    
    public override void afterInsert() {
        set<Id> sAIds = Trigger.newMap.Keyset();
        if(!sAIds.isEmpty()){
            System.enqueueJob(new ScheduleMeetingJob(sAIds,'Insert'));
        } 
    }
    
    /*------------------------------------------------------------
    Author: Saurabh Kumar
    Company: Salesforce
    Description: Function to execute after update logic
    Inputs: 
    Returns: 
    History
    <04/03/2024>     <Saurabh Kumar>     <Initial Creation>
    ------------------------------------------------------------*/
    public override void afterUpdate() {
      
        set<Id> sAIds = new Set<Id>();
        for(ServiceAppointment sAObj : (List<ServiceAppointment>)Trigger.new){
            ServiceAppointment oldSA = (ServiceAppointment)Trigger.oldMap.get(sAObj.ID);
            if((sAObj.Status!=oldSA.Status)||(sAObj.schedStartTime!=oldSA.schedStartTime)||(sAObj.schedEndTime!=oldSA.schedEndTime)){
                sAIds.add(sAObj.Id);
            }
        }
        if(!sAIds.isEmpty()){
            System.enqueueJob(new ScheduleMeetingJob(sAIds,'Update'));
        }
    }




}