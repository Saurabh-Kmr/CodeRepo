/*------------------------------------------------------------
Author: Saurabh Kumar
Company: Salesforce
Description: Enqueable Class called by ScheduleMeetingJob class to callout
              MS teams API
Inputs: 
Test Class: ServiceAppointmentTriggerHandler_Test
History
<04/03/2024>  <Saurabh Kumar>     <Initial Creation>
------------------------------------------------------------*/
public without sharing class FEP_CreateUpdateMeetingJob implements Queueable, Database.AllowsCallouts {
    private Set<Id> reqIds;
    private String operation;
    private String accessToken;
    private String tenantId ;
    private String clientId;
    private String clientSecret;
    private String scope;
    private String authBaseURL;
    private String grantType;
    private String graphBaseURL;
    private String serviceAccount;

    /*------------------------------------------------------------
    Author: Saurabh Kumar
    Company: Salesforce
    Description: Constructor to initialize variables
    Inputs: 
    Returns: 
    History
    <04/03/2024>     <Saurabh Kumar>     <Initial Creation>
    ------------------------------------------------------------*/
    public FEP_CreateUpdateMeetingJob(Set<Id> sAIds,String operation) {
      this.reqIds = sAIds;
      this.operation = operation;
      FEP_SFMS365TeamsIntegrationConfig__mdt config = FEP_SFMS365TeamsIntegrationConfig__mdt.getInstance('FEP_APIConfig');          
      this.tenantId = config.FEP_TenetID__c;
      this.clientId = config.FEP_ClientID__c;
      this.clientSecret = config.FEP_ClientSecret__c;
      this.scope= config.FEP_Scope__c;
      this.authBaseURL = config.FEP_AuthBaseURL__c;
      this.grantType = config.FEP_GrantType__c;
      this.graphBaseURL = config.FEP_GraphAPIBaseURL__c;
      this.serviceAccount = config.FEP_ServiceAccount__c;
     
    }
  
    /*------------------------------------------------------------
    Author: Saurabh Kumar
    Company: Salesforce
    Description: This method sends request to MS teams API to create a new meeting link
    Inputs:  Access Token -  token for authentication
             sAppt - Servcie Appointment for which we need to create meetings
    Returns: 
    History
    <04/03/2024>     <Saurabh Kumar>     <Initial Creation>
    ------------------------------------------------------------*/
    private void createMeetingLinksforCoachAndClient(String accessToken,ServiceAppointment sAppt){ 
  
      String graphURL = this.graphBaseURL+this.tenantId+'/users/'+this.serviceAccount+'/calendar/events';//graph.microsoft.com/v1.0/d4093791-9818-48dc-8880-35d134b8c79d/users/{serviceaccount}/calendar/events';
      String createMeetingUrl = graphURL;
      String meetingData = '{"subject":"Lets go for lunch","body":{"contentType":"HTML","content":"Does noon work for you?"},"start":{"dateTime":"2024-03-01T12:00:00","timeZone":"Pacific Standard Time"},"end":{"dateTime":"2024-03-01T13:00:00","timeZone":"Pacific Standard Time"},"location":{"displayName":"Prabhats Home"},"attendees":[{"emailAddress":{"address":"prabhat.sharma@salesforce.com","name":"Prabhat Sharma"},"type":"required"},{"emailAddress":{"address":"kumar.saurabh@dev365.pwc.com","name":"Saurabh Kumar"},"type":"required"}],"allowNewTimeProposals":true,"isOnlineMeeting":true,"onlineMeetingProvider":"teamsForBusiness"}';
      Request meetRequest = new Request();
      meetRequest.subject = sAppt.Contact.Account.Name +' Scheduled Appointment ' +sAppt.AppointmentNumber;
      meetRequest.allowNewTimeProposals = false;
      if(sAppt.Video_Call_Option__c!='Call Me'){
        meetRequest.isOnlineMeeting = true;
        meetRequest.onlineMeetingProvider = 'teamsForBusiness';
      }
      meetRequest.isReminderOn=true;
      meetRequest.reminderMinutesBeforeStart = 1440;
      Body meetBody = new Body();
      string apptLink = URL.getOrgDomainURL().toExternalForm()+'/'+sAppt.id;
      meetBody.content = '<a href ='+apptLink+'>Appointment # ' +sAppt.AppointmentNumber+'</a> <br>Account Name: '+sAppt.Contact.Account.Name+'<br>Contact Name: ' +sAppt.Contact.Name;
      meetBody.contentType = 'HTML';
      meetRequest.body = meetBody;
  
     List<attendee> meetAttendees = new List<attendee>();
    /*  Attendee client = new Attendee();
      EmailAddress clientEmailAddress = new EmailAddress();
      clientEmailAddress.address = sAppt.Contact.Email;
      clientEmailAddress.name = sAppt.Contact.Name;
      client.emailAddress=clientEmailAddress;
      client.type = 'required';
      meetAttendees.add(client);*/
      
      Attendee resource = new Attendee();
      EmailAddress resourceEmailAddress = new EmailAddress();
      resourceEmailAddress.address = sAppt.ServiceResources[0].ServiceResource.RelatedRecord.Email;
      resourceEmailAddress.name = sAppt.ServiceResources[0].ServiceResource.RelatedRecord.Name;
      resource.emailAddress = resourceEmailAddress;
      resource.type = 'required';
      meetAttendees.add(resource);
      meetRequest.attendees = meetAttendees;
  
      Start appointmentStart = new Start();
      appointmentStart.dateTime_Z = sAppt.schedStartTime;
      appointmentStart.timeZone  = 'GMT';
      meetRequest.start = appointmentStart;
  
      Start appointmentEnd = new Start();
      appointmentEnd.dateTime_Z = sAppt.schedEndTime;
      appointmentEnd.timeZone  = 'GMT';
      meetRequest.endTime = appointmentEnd;
      
      meetingData = JSON.serialize(meetRequest);
      meetingData=meetingData.replaceAll('dateTime_Z', 'dateTime').replaceAll('endTime', 'end');
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      request.setEndPoint(createMeetingUrl);
      request.setMethod('POST');
      request.setHeader('Authorization', 'Bearer ' + accessToken);
      request.setHeader('Content-Type', 'application/json');
      request.setHeader('Accept', 'application/json');
      request.setBody(meetingData);
      HttpResponse response = http.send(request);
      if(response.getStatusCode() ==201){    
        Map<String,Object> resultBody = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
        sAppt.FEP_MSTeamsMeetingID__c = String.valueOf(resultBody.get('id'));
        if(sAppt.Video_Call_Option__c!='Call Me'){
        Map<String,Object> onlineMeeting= (Map<String,Object>)resultBody.get('onlineMeeting');
        String joinUrl= String.valueOf(onlineMeeting.get('joinUrl'));
        sAppt.Video_Call_Link__c = joinUrl;
      }
        sAppt.FEP_TeamsApiCallResult__c = 'Success'; 
        String formattedString = sAppt.SchedStartTime.format('yyyy-MM-dd HH:mm:ss a','GMT');
        DateTime gmtFormatTime =  Datetime.valueOfGMT(formattedString);
        String scheduledTime = gmtFormatTime.format('EEE MMM dd yyyy hh:mm a z',sAppt.Contact.Account.FEP_Timezone__c);
        sAppt.FEP_AppointmentDateTimeText__c = String.isBlank(sAppt.FEP_AppointmentDateTimeText__c) ?scheduledTime.replace('EDT','Eastern Time').replace('CDT','Central Time').replace('MDT','Mountain Time').replace('PDT','Pacific Time'):sAppt.FEP_AppointmentDateTimeText__c;
        sAppt.FEP_Timezone__c =  String.isBlank(sAppt.FEP_Timezone__c)?sAppt.Contact.Account.FEP_Timezone__c:sAppt.FEP_Timezone__c;
        sAppt.Assigned_Coach__c = sAppt.ServiceResources[0].ServiceResource.Id;
        Map<String,Object> body= (Map<String,Object>)resultBody.get('body');
        String content = (String)body.get('content');
        sAppt.FEP_TeamsApiResponseBody__c = response.getBody();
        sAppt.FEP_EmailBody__c = content.substringBetween('<body>', '</body>').replace('data-tid="meeting-code"' , ' ').replace(sAppt.AppointmentNumber,'').replace('video call','').replace('voice call','').replace(sAppt.Contact.Name,'').replace(sAppt.Contact.Account.Name,'').replace('Appointment # ','').replace('\r\n<br>\r\nAccount Name:','').replace('<br>\r\nContact Name:','');
        update sAppt;   
    }
    else{
      sAppt.FEP_TeamsApiCallResult__c = 'Failed'; 
      sAppt.FEP_TeamsApiErrorDetails__c = response.getBody();
      update sAppt;   
    }
}

 /*------------------------------------------------------------
    Author: Saurabh Kumar
    Company: Salesforce
    Description: This method sends request to MS teams API to cancel a meeting link
    Inputs:  Access Token -  token for authentication
             sAppt - Servcie Appointment for which we need to cancel meetings
    Returns: 
    History
    <04/03/2024>     <Saurabh Kumar>     <Initial Creation>
    ------------------------------------------------------------*/
private void cancelMeetingForCoachAndClient(String accessToken,ServiceAppointment sAppt){ 
  
    String graphURL = this.graphBaseURL+this.tenantId+'/users/'+this.serviceAccount+'/calendar/events/'+sAppt.FEP_MSTeamsMeetingID__c+'/cancel';//graph.microsoft.com/v1.0/d4093791-9818-48dc-8880-35d134b8c79d/users/{serviceaccount}/calendar/events';
    String createMeetingUrl = graphURL;
   
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndPoint(createMeetingUrl);
    request.setMethod('POST');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('Accept', 'application/json');
    
    Map<String,String> cancelComment = new Map<String,String>{'Comment'=>sAppt.CancellationReason};
    request.setBody(JSON.serialize(cancelComment));
    HttpResponse response = http.send(request);

   
    if(response.getStatusCode() ==202){    
      System.debug('Appointment Cancelled'+sAppt.id);
      System.debug(JSON.serializePretty(response.getBody()));
  }
  else{
    sAppt.FEP_TeamsApiCallResult__c='Failed';
    sAppt.FEP_TeamsApiErrorDetails__c = response.getBody();
    update sAppt;   
  }
}

/*------------------------------------------------------------
    Author: Saurabh Kumar
    Company: Salesforce
    Description: This method sends request to MS teams API to update a meeting link
    Inputs:  Access Token -  token for authentication
             sAppt - Servcie Appointment for which we need to update meetings
    Returns: 
    History
    <04/03/2024>     <Saurabh Kumar>     <Initial Creation>
    ------------------------------------------------------------*/
private void rescheduleMeetingForCoachAndClient(String accessToken,ServiceAppointment sAppt){ 
  
    String graphURL = this.graphBaseURL+this.tenantId+'/users/'+this.serviceAccount+'/calendar/events/'+sAppt.FEP_MSTeamsMeetingID__c;//graph.microsoft.com/v1.0/d4093791-9818-48dc-8880-35d134b8c79d/users/{serviceaccount}/calendar/events';
    String createMeetingUrl = graphURL;
    String content;
    Request meetRequest = new Request();
    meetRequest.subject = sAppt.Contact.Account.Name +' Rescheduled Appointment ' +sAppt.AppointmentNumber;
    meetRequest.allowNewTimeProposals = false;
    if(sAppt.Video_Call_Option__c=='Call Me'){
      meetRequest.isOnlineMeeting = false;
      string apptLink = URL.getOrgDomainURL().toExternalForm()+'/'+sAppt.id;
      content  = '<a href ='+apptLink+'>Appointment # ' +sAppt.AppointmentNumber+'</a> <br>Account Name: '+sAppt.Contact.Account.Name+'<br>Contact Name: ' +sAppt.Contact.Name;  
    }
    else{
    meetRequest.isOnlineMeeting = true;
    meetRequest.onlineMeetingProvider = 'teamsForBusiness';
    Map<String,Object> teamsAPIResponse = (Map<String,Object>)JSON.deserializeUntyped(sAppt.FEP_TeamsApiResponseBody__c);
    Map<String,Object> teamsAPIResponseBody= (Map<String,Object>)teamsAPIResponse.get('body');
    content = (String)teamsAPIResponseBody.get('content');
    //content = content.contains('Meeting Rescheduled ')?content:content.replace(sAppt.AppointmentNumber, 'Meeting Rescheduled '+sAppt.AppointmentNumber);
    //content = content.replace('voice call','video call');
    }
    meetRequest.isReminderOn=true;
    meetRequest.reminderMinutesBeforeStart = 1440;
   

    Body meetBody = new Body();
    meetBody.content = content;
    meetBody.contentType = 'HTML';
    meetRequest.body = meetBody;

    Start appointmentStart = new Start();
    appointmentStart.dateTime_Z = sAppt.schedStartTime;
    appointmentStart.timeZone  = 'GMT';
    meetRequest.start = appointmentStart;
  
    Start appointmentEnd = new Start();
    appointmentEnd.dateTime_Z = sAppt.schedEndTime;
    appointmentEnd.timeZone  = 'GMT'; 
    meetRequest.endTime = appointmentEnd;

   
    List<attendee> meetAttendees = new List<attendee>();
      /*Attendee client = new Attendee();
      EmailAddress clientEmailAddress = new EmailAddress();
      clientEmailAddress.address = sAppt.Contact.Email;
      clientEmailAddress.name = sAppt.Contact.Name;
      client.emailAddress=clientEmailAddress;
      client.type = 'required';
      meetAttendees.add(client);*/
      
      Attendee resource = new Attendee();
      EmailAddress resourceEmailAddress = new EmailAddress();
      resourceEmailAddress.address = sAppt.ServiceResources[0].ServiceResource.RelatedRecord.Email;
      resourceEmailAddress.name = sAppt.ServiceResources[0].ServiceResource.RelatedRecord.Name;
      resource.emailAddress = resourceEmailAddress;
      resource.type = 'required';
      meetAttendees.add(resource);
      meetRequest.attendees = meetAttendees;

    String meetingData = JSON.serialize(meetRequest);
    meetingData=meetingData.replaceAll('dateTime_Z', 'dateTime').replaceAll('endTime', 'end');
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndPoint(createMeetingUrl);
    request.setMethod('PATCH');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('Accept', 'application/json');
    request.setBody(meetingData);
    HttpResponse response = http.send(request);


    if(response.getStatusCode() ==200){   

      Map<String,Object> resultBody = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
      if(sAppt.Video_Call_Option__c!='Call Me'){
        Map<String,Object> onlineMeeting= (Map<String,Object>)resultBody.get('onlineMeeting');
        String joinUrl= String.valueOf(onlineMeeting.get('joinUrl'));
        sAppt.Video_Call_Link__c = joinUrl;
      }
        sAppt.FEP_TeamsApiCallResult__c = 'Success'; 
        String timeZone = String.isBlank(sAppt.FEP_Timezone__c)?sAppt.Contact.Account.FEP_Timezone__c:sAppt.FEP_Timezone__c;
        String formattedString = sAppt.SchedStartTime.format('yyyy-MM-dd HH:mm:ss a','GMT');
        DateTime gmtFormatTime =  Datetime.valueOfGMT(formattedString);
        String scheduledTime = gmtFormatTime.format('EEE MMM dd yyyy hh:mm a z',timeZone);
        sAppt.FEP_AppointmentDateTimeText__c = scheduledTime.replace('EDT','Eastern Time').replace('CDT','Central Time').replace('MDT','Mountain Time').replace('PDT','Pacific Time');
        Map<String,Object> body= (Map<String,Object>)resultBody.get('body');
        String patchContent = (String)body.get('content');
        sAppt.FEP_TeamsApiResponseBody__c = response.getBody();
        sAppt.FEP_EmailBody__c = patchContent.substringBetween('<body>', '</body>').replace('data-tid="meeting-code"' , '').replace(sAppt.AppointmentNumber, '').replace('Meeting Rescheduled ','').replace(sAppt.Contact.Name,'').replace(sAppt.Contact.Account.Name,'').replace('Appointment # ','').replace('\r\n<br>\r\nAccount Name:','').replace('<br>\r\nContact Name:','');
        update sAppt;    
      
  }
  else{
    sAppt.FEP_TeamsApiCallResult__c='Failed';
    sAppt.FEP_TeamsApiErrorDetails__c = response.getBody();
    update sAppt;   
  }
}
  
 /*------------------------------------------------------------
    Author: Saurabh Kumar
    Company: Salesforce
    Description: Interface method to perform callout. This method evaluates the 
                  MS teams API method to be called 
    Inputs: 
    Returns: 
    History
    <04/03/2024>     <Saurabh Kumar>     <Initial Creation>
    ------------------------------------------------------------*/
  
    public void execute(QueueableContext ctx) {
      try {
        List<FEP_SFMSTeamsAccessTokenDetails__c> accessTokens = [SELECT Id,Name, FEP_AccessTokenGenerationTime__c,FEP_AccessToken__c FROM FEP_SFMSTeamsAccessTokenDetails__c Order by createddate DESC LIMIT 1];
        this.accessToken = accessTokens[0].FEP_AccessToken__c;
          if(this.operation =='Insert'){
            for(ServiceAppointment sAppt:[SELECT id,AppointmentNumber,Subject,Email,Contact.Name,Contact.Email,Contact.Account.Name,Contact.Account.FEP_Timezone__c,SchedStartTime, SchedEndTime,Video_Call_Option__c,FEP_AppointmentDateTimeText__c,FEP_Timezone__c,(SELECT ServiceResource.RelatedRecord.Name, ServiceResource.RelatedRecord.Email FROM ServiceResources ORDER BY CreatedDate DESC LIMIT 1) from ServiceAppointment WHERE ID=:this.reqIds]){
              createMeetingLinksforCoachAndClient(this.accessToken,sAppt);
            }
          }
          if(this.operation =='Update'){
            for(ServiceAppointment sAppt:[SELECT id,AppointmentNumber,Subject,FEP_MSTeamsMeetingID__c,FEP_TeamsApiResponseBody__c ,FEP_AppointmentDateTimeText__c,FEP_Timezone__c,CancellationReason,Contact.Name,Contact.Email,Contact.Account.Name,Contact.Account.FEP_Timezone__c,Status,SchedStartTime, SchedEndTime,Video_Call_Option__c,(SELECT ServiceResource.Id,ServiceResource.RelatedRecord.Name, ServiceResource.RelatedRecord.Email FROM ServiceResources ORDER BY CreatedDate DESC LIMIT 1) from ServiceAppointment WHERE ID=:this.reqIds]){
                if(sAppt.Status=='Canceled'){
                cancelMeetingForCoachAndClient(this.accessToken,sAppt);
            }
                else {
                rescheduleMeetingForCoachAndClient(this.accessToken,sAppt);
            }
              }
          }
      } catch (Exception e) {
        system.debug('Exception>>'+e.getMessage()+e.getStackTraceString());
      }
    }
  
    private class Request{
    private String subject ;
      private Body body ;
      private Start start; 
      private Start endTime ; // in json: end
      private List<Attendee> attendees;
      private Boolean allowNewTimeProposals ;
      private Boolean isOnlineMeeting ;
      private String onlineMeetingProvider ;
      private Boolean isReminderOn;
      private Integer reminderMinutesBeforeStart;
    }
  
    private class Body{
      private String contentType;
      private String content;
    }
  
    private class Attendee{
      private EmailAddress emailAddress;
      private String type;
    }
  
    private class EmailAddress{
      private String address;
      private String name;
    }
  
    private class Start{
      private DateTime dateTime_Z;
      private String timeZone;
    }
  
  }