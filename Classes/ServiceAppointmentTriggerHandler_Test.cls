/*------------------------------------------------------------
Author: Saurabh Kumar
Company: Salesforce
Description: Test Class for MS teams integration
Test Class: 
History
<04/03/2024>  <Saurabh Kumar>     <Initial Creation>
------------------------------------------------------------*/
@isTest
public without sharing class ServiceAppointmentTriggerHandler_Test {
 
    @testSetup static void setup() {
        Account accObj = new Account(Name ='TestAccount 007',Access_Code__c='123',Dialed_Phone_Number__c='18773580439',FEP_Timezone__c='America/New_York');
        insert accObj;   
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FEP Coaches']
            .Id,
            LastName = 'last',
            Email = 'puser000@pwc.com',
            Username = 'puser000@pwc.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
          );
          insert u;

        ServiceResource objServiceResource=new ServiceResource(Name='Test Resource',RelatedRecordId=u.Id,ResourceType='T',IsActive=True);
        insert objServiceResource;     
    }
    @isTest
    public static void requestTokenTest(){
        Id parentRecord = [SELECT Id,name from Account Limit 1].Id;
        TriggerHandler.bypass('ServiceAppointmentTriggerHandler');
        ServiceAppointment sAToInsert= new ServiceAppointment(SchedStartTime = System.DateTime.now(),SchedEndTime = System.DateTime.now().addMinutes(30),ParentRecordId=parentRecord );
        Test.setMock(HttpCalloutMock.class, new FEP_MSTeamsResponseMock('tokenInsertPositive'));
        insert sAToInsert;  
        Test.startTest();  

        System.enqueueJob(new ScheduleMeetingJob(new Set<Id>{sAToInsert.id},'Null'));
        Test.stopTest();
        List<FEP_SFMSTeamsAccessTokenDetails__c> accessTokens = [SELECT Id,Name, FEP_AccessTokenGenerationTime__c,FEP_AccessToken__c FROM FEP_SFMSTeamsAccessTokenDetails__c Order by createddate DESC LIMIT 1];

    }

    @isTest
    public static void insertSATestPositive(){
        Id parentRecord = [SELECT Id,name from Account Limit 1].Id;
        Contact contct = new Contact(LastName='Test',AccountId = parentRecord,Email='Test@test.com');
        insert contct;
        TriggerHandler.bypass('ServiceAppointmentTriggerHandler');
        FEP_SFMSTeamsAccessTokenDetails__c accessTokens = new FEP_SFMSTeamsAccessTokenDetails__c(FEP_AccessTokenGenerationTime__c=System.DateTime.now(),FEP_AccessToken__c='Test Token');
        insert accessTokens;
        ServiceAppointment sAToInsert= new ServiceAppointment(SchedStartTime = System.DateTime.now(),SchedEndTime = System.DateTime.now().addMinutes(30),ParentRecordId=parentRecord,ContactId= contct.Id );
        insert sAToInsert; 
        ServiceResource servResource = [SELECT ID,name FROM ServiceResource LIMIT 1][0];
        AssignedResource assgnResource = new AssignedResource(ServiceAppointmentId=sAToInsert.Id,ServiceResourceId=servResource.Id);
        insert assgnResource;
       
        Test.setMock(HttpCalloutMock.class, new FEP_MSTeamsResponseMock('SAInsert'));
        Test.startTest();  
        System.enqueueJob(new FEP_CreateUpdateMeetingJob(new Set<Id>{sAToInsert.id},'Insert'));
        Test.stopTest();
        ServiceAppointment sAInserted = [SELECT FEP_TeamsApiCallResult__c, Status,Video_Call_Link__c FROM ServiceAppointment LIMIT 1][0];
        Assert.areEqual('Scheduled',sAInserted.Status,'One Record Expected');
        Assert.areEqual('Success',sAInserted.FEP_TeamsApiCallResult__c,'Callout Success');      
    }

    @isTest
    public static void insertSATestNegative(){
        Id parentRecord = [SELECT Id,name from Account Limit 1].Id;
        Contact contct = new Contact(LastName='Test',AccountId = parentRecord,Email='Test@test.com');
        insert contct;
        TriggerHandler.bypass('ServiceAppointmentTriggerHandler');
        FEP_SFMSTeamsAccessTokenDetails__c accessTokens = new FEP_SFMSTeamsAccessTokenDetails__c(FEP_AccessTokenGenerationTime__c=System.DateTime.now(),FEP_AccessToken__c='Test Token');
        insert accessTokens;
        ServiceAppointment sAToInsert= new ServiceAppointment(SchedStartTime = System.DateTime.now(),SchedEndTime = System.DateTime.now().addMinutes(30),ParentRecordId=parentRecord,ContactId= contct.Id );
        insert sAToInsert; 
        ServiceResource servResource = [SELECT ID,name FROM ServiceResource LIMIT 1][0];
        AssignedResource assgnResource = new AssignedResource(ServiceAppointmentId=sAToInsert.Id,ServiceResourceId=servResource.Id);
        insert assgnResource;
       
        Test.setMock(HttpCalloutMock.class, new FEP_MSTeamsResponseMock('SAInsertFail'));
        Test.startTest();  
        System.enqueueJob(new FEP_CreateUpdateMeetingJob(new Set<Id>{sAToInsert.id},'Insert'));
        Test.stopTest();
        ServiceAppointment sAInserted = [SELECT FEP_TeamsApiCallResult__c, Status,FEP_TeamsApiErrorDetails__c FROM ServiceAppointment LIMIT 1][0];
        Assert.areEqual('Scheduled',sAInserted.Status,'One Record Expected');
        Assert.areEqual('Failed',sAInserted.FEP_TeamsApiCallResult__c,'Callout Fail');  
        Assert.areEqual('{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users/events/$entity","@odata.etag":"W/\\"ZlnW4RIAV06KYYwlrfNZvQAALfZeRQ==\\"","id":"AAMkAGI1AAAt9AHjAAA=","createdDateTime":"2017-04-15T03:00:50.7579581Z","lastModifiedDateTime":"2017-04-15T03:00:51.245372Z","changeKey":"ZlnW4RIAV06KYYwlrfNZvQAALfZeRQ==","categories":[],"originalStartTimeZone":"Pacific Standard Time","originalEndTimeZone":"Pacific Standard Time","iCalUId":"040000008200E00074C5B7101A82E00800000000DA2B357D94B5D201000000000000000010000000EC4597557F0CB34EA4CC2887EA7B17C3","reminderMinutesBeforeStart":15,"isReminderOn":true,"hasAttachments":false,"hideAttendees":false,"subject":"Let go brunch","bodyPreview":"Does noon work for you?","importance":"normal","sensitivity":"normal","isAllDay":false,"isCancelled":false,"isDraft":false,"isOrganizer":true,"responseRequested":true,"seriesMasterId":null,"transactionId":"7E163156-7762-4BEB-A1C6-729EA81755A7","showAs":"busy","type":"singleInstance","webLink":"https://outlook.office365.com/owa/?itemid=AAMkAGI1AAAt9AHjAAA%3D&exvsurl=1&path=/calendar/item","onlineMeetingUrl":null,"isOnlineMeeting":false,"onlineMeetingProvider":"unknown","onlineMeeting":null,"allowNewTimeProposals":true,"responseStatus":{"response":"organizer","time":"0001-01-01T00:00:00Z"},"body":{"contentType":"html","content":"<html><head></head><body><br>Does late morning work for you?</body></html>"},"start":{"dateTime":"2017-04-15T11:00:00.0000000","timeZone":"Pacific Standard Time"},"end":{"dateTime":"2017-04-15T12:00:00.0000000","timeZone":"Pacific Standard Time"},"location":{"displayName":"Harrys Bar","locationType":"default","uniqueId":"Harrys Bar","uniqueIdType":"private"},"locations":[{"displayName":"Harrys Bar","locationType":"default","uniqueIdType":"unknown"}],"recurrence":null,"attendees":[{"type":"required","status":{"response":"none","time":"0001-01-01T00:00:00Z"},"emailAddress":{"name":"Samantha Booth","address":"samanthab@contoso.com"}}],"organizer":{"emailAddress":{"name":"Dana Swope","address":"danas@contoso.com"}},"onlineMeeting": { "joinUrl": "https://teams.microsoft.com/l/meetup-join","conferenceId": "177513992","tollNumber": "+1 425 555 0123"}}',sAInserted.FEP_TeamsApiErrorDetails__c,'Error Updated');  
        
    }

    @isTest
    public static void rescheduleSATestPositive(){
        Id parentRecord = [SELECT Id,name from Account Limit 1].Id;
        Contact contct = new Contact(LastName='Test',AccountId = parentRecord,Email='Test@test.com');
        insert contct;
        TriggerHandler.bypass('ServiceAppointmentTriggerHandler');
        FEP_SFMSTeamsAccessTokenDetails__c accessTokens = new FEP_SFMSTeamsAccessTokenDetails__c(FEP_AccessTokenGenerationTime__c=System.DateTime.now(),FEP_AccessToken__c='Test Token');
        insert accessTokens;
        ServiceAppointment sAToInsert= new ServiceAppointment(SchedStartTime = System.DateTime.now(),SchedEndTime = System.DateTime.now().addMinutes(30),ParentRecordId=parentRecord,ContactId= contct.Id,FEP_TeamsApiResponseBody__c='{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users/events/$entity","@odata.etag":"W/\\"ZlnW4RIAV06KYYwlrfNZvQAALfZeRQ==\\"","id":"AAMkAGI1AAAt9AHjAAA=","createdDateTime":"2017-04-15T03:00:50.7579581Z","lastModifiedDateTime":"2017-04-15T03:00:51.245372Z","changeKey":"ZlnW4RIAV06KYYwlrfNZvQAALfZeRQ==","categories":[],"originalStartTimeZone":"Pacific Standard Time","originalEndTimeZone":"Pacific Standard Time","iCalUId":"040000008200E00074C5B7101A82E00800000000DA2B357D94B5D201000000000000000010000000EC4597557F0CB34EA4CC2887EA7B17C3","reminderMinutesBeforeStart":15,"isReminderOn":true,"hasAttachments":false,"hideAttendees":false,"subject":"Let go brunch","bodyPreview":"Does noon work for you?","importance":"normal","sensitivity":"normal","isAllDay":false,"isCancelled":false,"isDraft":false,"isOrganizer":true,"responseRequested":true,"seriesMasterId":null,"transactionId":"7E163156-7762-4BEB-A1C6-729EA81755A7","showAs":"busy","type":"singleInstance","webLink":"https://outlook.office365.com/owa/?itemid=AAMkAGI1AAAt9AHjAAA%3D&exvsurl=1&path=/calendar/item","onlineMeetingUrl":null,"isOnlineMeeting":false,"onlineMeetingProvider":"unknown","onlineMeeting":null,"allowNewTimeProposals":true,"responseStatus":{"response":"organizer","time":"0001-01-01T00:00:00Z"},"body":{"contentType":"html","content":"<html><head></head><body><br>Does late morning work for you?</body></html>"},"start":{"dateTime":"2017-04-15T11:00:00.0000000","timeZone":"Pacific Standard Time"},"end":{"dateTime":"2017-04-15T12:00:00.0000000","timeZone":"Pacific Standard Time"},"location":{"displayName":"Harrys Bar","locationType":"default","uniqueId":"Harrys Bar","uniqueIdType":"private"},"locations":[{"displayName":"Harrys Bar","locationType":"default","uniqueIdType":"unknown"}],"recurrence":null,"attendees":[{"type":"required","status":{"response":"none","time":"0001-01-01T00:00:00Z"},"emailAddress":{"name":"Samantha Booth","address":"samanthab@contoso.com"}}],"organizer":{"emailAddress":{"name":"Dana Swope","address":"danas@contoso.com"}},"onlineMeeting": { "joinUrl": "https://teams.microsoft.com/l/meetup-join","conferenceId": "177513992","tollNumber": "+1 425 555 0123"}}' );
        insert sAToInsert;    
        ServiceResource servResource = [SELECT ID,name FROM ServiceResource LIMIT 1][0];
        AssignedResource assgnResource = new AssignedResource(ServiceAppointmentId=sAToInsert.Id,ServiceResourceId=servResource.Id);
        insert assgnResource;
        Test.setMock(HttpCalloutMock.class, new FEP_MSTeamsResponseMock('SAReschedulePass'));
        Test.startTest();  
        System.enqueueJob(new FEP_CreateUpdateMeetingJob(new Set<Id>{sAToInsert.id},'Update'));
        Test.stopTest();
        ServiceAppointment sAInserted = [SELECT FEP_TeamsApiCallResult__c, Status,FEP_TeamsApiErrorDetails__c FROM ServiceAppointment LIMIT 1][0];
        Assert.areEqual('Scheduled',sAInserted.Status,'One Record Expected');
    }


    @isTest
    public static void cancelSATestPositive(){
        Id parentRecord = [SELECT Id,name from Account Limit 1].Id;
        Contact contct = new Contact(LastName='Test',AccountId = parentRecord,Email='Test@test.com');
        insert contct;
        TriggerHandler.bypass('ServiceAppointmentTriggerHandler');
        FEP_SFMSTeamsAccessTokenDetails__c accessTokens = new FEP_SFMSTeamsAccessTokenDetails__c(FEP_AccessTokenGenerationTime__c=System.DateTime.now(),FEP_AccessToken__c='Test Token');
        insert accessTokens;
        ServiceAppointment sAToInsert= new ServiceAppointment(SchedStartTime = System.DateTime.now(),SchedEndTime = System.DateTime.now().addMinutes(30),ParentRecordId=parentRecord,ContactId= contct.Id,Status='Canceled',FEP_TeamsApiCallResult__c='Success' );
        insert sAToInsert; 
       
        Test.setMock(HttpCalloutMock.class, new FEP_MSTeamsResponseMock('SACancelPass'));
        Test.startTest();  
        System.enqueueJob(new FEP_CreateUpdateMeetingJob(new Set<Id>{sAToInsert.id},'Update'));
        Test.stopTest();
        ServiceAppointment sAInserted = [SELECT FEP_TeamsApiCallResult__c, Status,FEP_TeamsApiErrorDetails__c FROM ServiceAppointment LIMIT 1][0];
        Assert.areEqual('Canceled',sAInserted.Status,'One Record Expected');
        Assert.areEqual('Success',sAInserted.FEP_TeamsApiCallResult__c,'Status Match');
    }

    @isTest
    public static void testTriggerHandlerInsert(){
        Id parentRecord = [SELECT Id,name from Account Limit 1].Id;
        Contact contct = new Contact(LastName='Test',AccountId = parentRecord,Email='Test@test.com');
        insert contct;
       // TriggerHandler.bypass('ServiceAppointmentTriggerHandler');
        FEP_SFMSTeamsAccessTokenDetails__c accessTokens = new FEP_SFMSTeamsAccessTokenDetails__c(FEP_AccessTokenGenerationTime__c=System.DateTime.now(),FEP_AccessToken__c='Test Token');
        insert accessTokens;
        ServiceAppointment sAToInsert= new ServiceAppointment(SchedStartTime = System.DateTime.now(),SchedEndTime = System.DateTime.now().addMinutes(30),ParentRecordId=parentRecord,ContactId= contct.Id );
        insert sAToInsert; 
        ServiceResource servResource = [SELECT ID,name FROM ServiceResource LIMIT 1][0];
        AssignedResource assgnResource = new AssignedResource(ServiceAppointmentId=sAToInsert.Id,ServiceResourceId=servResource.Id);
        insert assgnResource;
       
        Test.setMock(HttpCalloutMock.class, new FEP_MSTeamsResponseMock('SAInsert'));
        Test.startTest();  
        System.enqueueJob(new FEP_CreateUpdateMeetingJob(new Set<Id>{sAToInsert.id},'Insert'));
        Test.stopTest();
        ServiceAppointment sAInserted = [SELECT FEP_TeamsApiCallResult__c, Status,Video_Call_Link__c FROM ServiceAppointment LIMIT 1][0];
        Assert.areEqual('Scheduled',sAInserted.Status,'One Record Expected');
        Assert.areEqual('Success',sAInserted.FEP_TeamsApiCallResult__c,'Callout Success');      
    }

    @isTest
    public static void testTriggerHandlerUpdate(){
        Id parentRecord = [SELECT Id,name from Account Limit 1].Id;
        Contact contct = new Contact(LastName='Test',AccountId = parentRecord,Email='Test@test.com');
        insert contct;
       // TriggerHandler.bypass('ServiceAppointmentTriggerHandler');
        FEP_SFMSTeamsAccessTokenDetails__c accessTokens = new FEP_SFMSTeamsAccessTokenDetails__c(FEP_AccessTokenGenerationTime__c=System.DateTime.now(),FEP_AccessToken__c='Test Token');
        insert accessTokens;
        ServiceAppointment sAToInsert= new ServiceAppointment(SchedStartTime = System.DateTime.now(),SchedEndTime = System.DateTime.now().addMinutes(30),ParentRecordId=parentRecord,ContactId= contct.Id );
        insert sAToInsert; 
        ServiceResource servResource = [SELECT ID,name FROM ServiceResource LIMIT 1][0];
        AssignedResource assgnResource = new AssignedResource(ServiceAppointmentId=sAToInsert.Id,ServiceResourceId=servResource.Id);
        insert assgnResource;
       
        Test.setMock(HttpCalloutMock.class, new FEP_MSTeamsResponseMock('SAInsert'));
        Test.startTest();  
        System.enqueueJob(new FEP_CreateUpdateMeetingJob(new Set<Id>{sAToInsert.id},'Insert'));
        Test.stopTest();
        ServiceAppointment sAInserted = [SELECT FEP_TeamsApiCallResult__c, Status,Video_Call_Link__c FROM ServiceAppointment LIMIT 1][0];
        Assert.areEqual('Scheduled',sAInserted.Status,'One Record Expected');
        Assert.areEqual('Success',sAInserted.FEP_TeamsApiCallResult__c,'Callout Success');   
        sAInserted.Status='Canceled';
        update sAInserted;   
    }

    @isTest
    public static void testTriggerHandlerReschedule(){
        Id parentRecord = [SELECT Id,name from Account Limit 1].Id;
        Contact contct = new Contact(LastName='Test',AccountId = parentRecord,Email='Test@test.com');
        insert contct;
       // TriggerHandler.bypass('ServiceAppointmentTriggerHandler');
        FEP_SFMSTeamsAccessTokenDetails__c accessTokens = new FEP_SFMSTeamsAccessTokenDetails__c(FEP_AccessTokenGenerationTime__c=System.DateTime.now(),FEP_AccessToken__c='Test Token');
        insert accessTokens;
        ServiceAppointment sAToInsert= new ServiceAppointment(SchedStartTime = System.DateTime.now(),SchedEndTime = System.DateTime.now().addMinutes(30),ParentRecordId=parentRecord,ContactId= contct.Id,FEP_Timezone__c='America/New_York' );
        insert sAToInsert; 
        ServiceResource servResource = [SELECT ID,name FROM ServiceResource LIMIT 1][0];
        AssignedResource assgnResource = new AssignedResource(ServiceAppointmentId=sAToInsert.Id,ServiceResourceId=servResource.Id);
        insert assgnResource;
       
        Test.setMock(HttpCalloutMock.class, new FEP_MSTeamsResponseMock('SAInsert'));
        Test.startTest();  
        System.enqueueJob(new FEP_CreateUpdateMeetingJob(new Set<Id>{sAToInsert.id},'Insert'));
        Test.stopTest();
        ServiceAppointment sAInserted = [SELECT FEP_TeamsApiCallResult__c, Status,Video_Call_Link__c FROM ServiceAppointment LIMIT 1][0];
        Assert.areEqual('Scheduled',sAInserted.Status,'One Record Expected');
        Assert.areEqual('Success',sAInserted.FEP_TeamsApiCallResult__c,'Callout Success');   
        sAInserted.SchedStartTime=System.DateTime.now().addMinutes(30);
        sAInserted.SchedEndTime =System.DateTime.now().addMinutes(60);
        update sAInserted;   
    }
}