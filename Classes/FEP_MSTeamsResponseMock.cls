/*------------------------------------------------------------
Author: Saurabh Kumar
Company: Salesforce
Description: Mock response Class for MS teams integration
Test Class: 
History
<04/03/2024>  <Saurabh Kumar>     <Initial Creation>
------------------------------------------------------------*/
@isTest
 global class FEP_MSTeamsResponseMock implements HttpCalloutMock{
    Private String methodTested;
    global FEP_MSTeamsResponseMock(String methodTested) {
        this.methodTested = methodTested;
    }

    global HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        if(this.methodTested=='tokenInsertPositive'){
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"token_type":"Bearer","scope":"Mail.ReadUser.Read","expires_in":3736,"ext_expires_in":3736,"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik5HVEZ2ZEstZnl0aEV1Q...","refresh_token":"AwABAAAAvPM1KaPlrEqdFSBzjqfTGAMxZGUTdM0t4B4..."}');
        res.setStatusCode(200);   
        }
        if(this.methodTested=='SAInsert'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users/events/$entity","@odata.etag":"W/\\"ZlnW4RIAV06KYYwlrfNZvQAALfZeRQ==\\"","id":"AAMkAGI1AAAt9AHjAAA=","createdDateTime":"2017-04-15T03:00:50.7579581Z","lastModifiedDateTime":"2017-04-15T03:00:51.245372Z","changeKey":"ZlnW4RIAV06KYYwlrfNZvQAALfZeRQ==","categories":[],"originalStartTimeZone":"Pacific Standard Time","originalEndTimeZone":"Pacific Standard Time","iCalUId":"040000008200E00074C5B7101A82E00800000000DA2B357D94B5D201000000000000000010000000EC4597557F0CB34EA4CC2887EA7B17C3","reminderMinutesBeforeStart":15,"isReminderOn":true,"hasAttachments":false,"hideAttendees":false,"subject":"Let go brunch","bodyPreview":"Does noon work for you?","importance":"normal","sensitivity":"normal","isAllDay":false,"isCancelled":false,"isDraft":false,"isOrganizer":true,"responseRequested":true,"seriesMasterId":null,"transactionId":"7E163156-7762-4BEB-A1C6-729EA81755A7","showAs":"busy","type":"singleInstance","webLink":"https://outlook.office365.com/owa/?itemid=AAMkAGI1AAAt9AHjAAA%3D&exvsurl=1&path=/calendar/item","onlineMeetingUrl":null,"isOnlineMeeting":false,"onlineMeetingProvider":"unknown","onlineMeeting":null,"allowNewTimeProposals":true,"responseStatus":{"response":"organizer","time":"0001-01-01T00:00:00Z"},"body":{"contentType":"html","content":"<html><head></head><body><br>Does late morning work for you?</body></html>"},"start":{"dateTime":"2017-04-15T11:00:00.0000000","timeZone":"Pacific Standard Time"},"end":{"dateTime":"2017-04-15T12:00:00.0000000","timeZone":"Pacific Standard Time"},"location":{"displayName":"Harrys Bar","locationType":"default","uniqueId":"Harrys Bar","uniqueIdType":"private"},"locations":[{"displayName":"Harrys Bar","locationType":"default","uniqueIdType":"unknown"}],"recurrence":null,"attendees":[{"type":"required","status":{"response":"none","time":"0001-01-01T00:00:00Z"},"emailAddress":{"name":"Samantha Booth","address":"samanthab@contoso.com"}}],"organizer":{"emailAddress":{"name":"Dana Swope","address":"danas@contoso.com"}},"onlineMeeting": { "joinUrl": "https://teams.microsoft.com/l/meetup-join","conferenceId": "177513992","tollNumber": "+1 425 555 0123"}}');
            res.setStatusCode(201);   
        }
        if(this.methodTested=='SAInsertFail'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users/events/$entity","@odata.etag":"W/\\"ZlnW4RIAV06KYYwlrfNZvQAALfZeRQ==\\"","id":"AAMkAGI1AAAt9AHjAAA=","createdDateTime":"2017-04-15T03:00:50.7579581Z","lastModifiedDateTime":"2017-04-15T03:00:51.245372Z","changeKey":"ZlnW4RIAV06KYYwlrfNZvQAALfZeRQ==","categories":[],"originalStartTimeZone":"Pacific Standard Time","originalEndTimeZone":"Pacific Standard Time","iCalUId":"040000008200E00074C5B7101A82E00800000000DA2B357D94B5D201000000000000000010000000EC4597557F0CB34EA4CC2887EA7B17C3","reminderMinutesBeforeStart":15,"isReminderOn":true,"hasAttachments":false,"hideAttendees":false,"subject":"Let go brunch","bodyPreview":"Does noon work for you?","importance":"normal","sensitivity":"normal","isAllDay":false,"isCancelled":false,"isDraft":false,"isOrganizer":true,"responseRequested":true,"seriesMasterId":null,"transactionId":"7E163156-7762-4BEB-A1C6-729EA81755A7","showAs":"busy","type":"singleInstance","webLink":"https://outlook.office365.com/owa/?itemid=AAMkAGI1AAAt9AHjAAA%3D&exvsurl=1&path=/calendar/item","onlineMeetingUrl":null,"isOnlineMeeting":false,"onlineMeetingProvider":"unknown","onlineMeeting":null,"allowNewTimeProposals":true,"responseStatus":{"response":"organizer","time":"0001-01-01T00:00:00Z"},"body":{"contentType":"html","content":"<html><head></head><body><br>Does late morning work for you?</body></html>"},"start":{"dateTime":"2017-04-15T11:00:00.0000000","timeZone":"Pacific Standard Time"},"end":{"dateTime":"2017-04-15T12:00:00.0000000","timeZone":"Pacific Standard Time"},"location":{"displayName":"Harrys Bar","locationType":"default","uniqueId":"Harrys Bar","uniqueIdType":"private"},"locations":[{"displayName":"Harrys Bar","locationType":"default","uniqueIdType":"unknown"}],"recurrence":null,"attendees":[{"type":"required","status":{"response":"none","time":"0001-01-01T00:00:00Z"},"emailAddress":{"name":"Samantha Booth","address":"samanthab@contoso.com"}}],"organizer":{"emailAddress":{"name":"Dana Swope","address":"danas@contoso.com"}},"onlineMeeting": { "joinUrl": "https://teams.microsoft.com/l/meetup-join","conferenceId": "177513992","tollNumber": "+1 425 555 0123"}}');
            res.setStatusCode(400);   
        }
        if(this.methodTested=='SACancelPass'){
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(202);   
        }
        if(this.methodTested=='SAReschedulePass'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"@odata.context":"https://graph.microsoft.com/v1.0/$metadata#users/events/$entity","@odata.etag":"W/\\"ZlnW4RIAV06KYYwlrfNZvQAALfZeRQ==\\"","id":"AAMkAGI1AAAt9AHjAAA=","createdDateTime":"2017-04-15T03:00:50.7579581Z","lastModifiedDateTime":"2017-04-15T03:00:51.245372Z","changeKey":"ZlnW4RIAV06KYYwlrfNZvQAALfZeRQ==","categories":[],"originalStartTimeZone":"Pacific Standard Time","originalEndTimeZone":"Pacific Standard Time","iCalUId":"040000008200E00074C5B7101A82E00800000000DA2B357D94B5D201000000000000000010000000EC4597557F0CB34EA4CC2887EA7B17C3","reminderMinutesBeforeStart":15,"isReminderOn":true,"hasAttachments":false,"hideAttendees":false,"subject":"Let go brunch","bodyPreview":"Does noon work for you?","importance":"normal","sensitivity":"normal","isAllDay":false,"isCancelled":false,"isDraft":false,"isOrganizer":true,"responseRequested":true,"seriesMasterId":null,"transactionId":"7E163156-7762-4BEB-A1C6-729EA81755A7","showAs":"busy","type":"singleInstance","webLink":"https://outlook.office365.com/owa/?itemid=AAMkAGI1AAAt9AHjAAA%3D&exvsurl=1&path=/calendar/item","onlineMeetingUrl":null,"isOnlineMeeting":false,"onlineMeetingProvider":"unknown","onlineMeeting":null,"allowNewTimeProposals":true,"responseStatus":{"response":"organizer","time":"0001-01-01T00:00:00Z"},"body":{"contentType":"html","content":"<html><head></head><body><br>Does late morning work for you?</body></html>"},"start":{"dateTime":"2017-04-15T11:00:00.0000000","timeZone":"Pacific Standard Time"},"end":{"dateTime":"2017-04-15T12:00:00.0000000","timeZone":"Pacific Standard Time"},"location":{"displayName":"Harrys Bar","locationType":"default","uniqueId":"Harrys Bar","uniqueIdType":"private"},"locations":[{"displayName":"Harrys Bar","locationType":"default","uniqueIdType":"unknown"}],"recurrence":null,"attendees":[{"type":"required","status":{"response":"none","time":"0001-01-01T00:00:00Z"},"emailAddress":{"name":"Samantha Booth","address":"samanthab@contoso.com"}}],"organizer":{"emailAddress":{"name":"Dana Swope","address":"danas@contoso.com"}},"onlineMeeting": { "joinUrl": "https://teams.microsoft.com/l/meetup-join","conferenceId": "177513992","tollNumber": "+1 425 555 0123"}}');
            res.setStatusCode(200);   
        }
        return res;
    }
}