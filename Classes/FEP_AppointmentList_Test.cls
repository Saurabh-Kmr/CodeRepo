@isTest
public class FEP_AppointmentList_Test {

    static testMethod void appListTest(){
        
		Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FEP Standard Account').getRecordTypeId();
		acc.Name = 'Sample Test Account';
        insert acc;
        
        Contact conObj = new Contact();
        conObj.LastName = 'Sample Contact';
        conObj.AccountId = acc.Id;
        conObj.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('FEP Standard Contact').getRecordTypeId();
        insert conObj;
       	
        User newUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser@example1122334.com',
            Email = 'testuser@example112233.com',
            Alias = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FEP Coaches' LIMIT 1].Id,
            IsActive = true
        );

        // Insert the User record
        insert newUser;
        
        
        User newUser1 = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser@exampleXXX2334.com',
            Email = 'testuser@exampleCCXX33.com',
            Alias = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
			ContactId = conObj.Id,
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FEP Customer Community User - Custom' LIMIT 1].Id,
            IsActive = true
        );

        // Insert the User record
        insert newUser1;
        
        
        ServiceResource  resour = new ServiceResource();
        resour.Name = 'New Ser Res';
        resour.RelatedRecordId = newUser.Id; 
        resour.IsActive = true;
        insert resour;
        
        OperatingHours opr = new OperatingHours();
        opr.Name ='ABC Operating HOurs';
        opr.TimeZone ='America/New_York';
        insert opr;
        
        ServiceTerritory str = new ServiceTerritory();
        str.Name = 'Nee Stte';
        str.OperatingHoursId = opr.Id;
        str.IsActive = true;
        insert str;
        
        WorkType wtype = new WorkType();
        wtype.OperatingHoursId = opr.Id;
        wtype.Name = 'Test';
        wtype.EstimatedDuration = 30;
        wtype.DurationType = 'Hours';
        insert wtype;
        
        ServiceAppointment newSA = new ServiceAppointment();
        AssignedResource res = new AssignedResource();
        Event event = new Event();
        
        newSA.SchedStartTime = DateTime.now().addDays(5);
        newSA.SchedEndTime = DateTime.now().addDays(5).addMinutes(30);
        newSA.ArrivalWindowStartTime = newSA.SchedStartTime.addMinutes(-15);
        newSA.ArrivalWindowEndTime = newSA.SchedEndTime.addMinutes(15);
        newSA.ParentRecordId = acc.Id;
        newSA.Video_Call_Option__c = 'Call Me';
        newSA.Phone = '987-987-9999';
        newSA.Description = 'Test Desc';
        newSA.ServiceTerritoryId = str.Id;
        newSA.ContactId = conObj.Id;
        newSA.workTypeId = wtype.Id;
        newSA.FEP_AppointmentDateTimeText__c = 'Test';
        newSA.FEP_Timezone__c = 'America/New_York';
        newSA.Email = 'abc@gmail.com';
        newSA.FEP_Ext__c = '987'; 
        insert newSA;
        
        res.ServiceAppointmentId = newSA.id;
        res.ServiceResourceId = resour.Id;
        res.IsRequiredResource = true;
        insert res;
        
        FEP_AppointmentList.getAllAppointmentsForContact(conObj.Id);
		FEP_AppointmentList.getAppointmentList(newUser1.Id);
        FEP_AppointmentList.getAppointmentDetails(newSA.Id);
        FEP_AppointmentList.cancelAppointment(newSA.Id,'XYZ');
        
    }
    
    static testMethod void appListTest1(){
        
		Account acc = new Account();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FEP Standard Account').getRecordTypeId();
		acc.Name = 'Sample Test Account';
        acc.FEP_Timezone__c = 'America/Los_Angeles';
        insert acc;
        
        Contact conObj = new Contact();
        conObj.LastName = 'Sample Contact';
        conObj.AccountId = acc.Id;
        conObj.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('FEP Standard Contact').getRecordTypeId();
        insert conObj;
       	
        User newUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser@example1122334.com',
            Email = 'testuser@example112233.com',
            Alias = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FEP Coaches' LIMIT 1].Id,
            IsActive = true
        );

        // Insert the User record
        insert newUser;
        
        
        User newUser1 = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser@exampleXXX2334.com',
            Email = 'testuser@exampleCCXX33.com',
            Alias = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
			ContactId = conObj.Id,
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'FEP Customer Community User - Custom' LIMIT 1].Id,
            IsActive = true
        );

        // Insert the User record
        insert newUser1;
        
        
        ServiceResource  resour = new ServiceResource();
        resour.Name = 'New Ser Res';
        resour.RelatedRecordId = newUser.Id; 
        resour.IsActive = true;
        insert resour;
        
        OperatingHours opr = new OperatingHours();
        opr.Name ='ABC Operating HOurs';
        opr.TimeZone ='America/New_York';
        insert opr;
        
        ServiceTerritory str = new ServiceTerritory();
        str.Name = 'Nee Stte';
        str.OperatingHoursId = opr.Id;
        str.IsActive = true;
        insert str;
        
        WorkType wtype = new WorkType();
        wtype.OperatingHoursId = opr.Id;
        wtype.Name = 'Test';
        wtype.EstimatedDuration = 30;
        wtype.DurationType = 'Hours';
        wtype.FEP_RelatedAccount__c = acc.Id;
        insert wtype;
        
        ServiceAppointment newSA = new ServiceAppointment();
        AssignedResource res = new AssignedResource();
        Event event = new Event();
        
        newSA.SchedStartTime = DateTime.now().addDays(-5);
        newSA.SchedEndTime = DateTime.now().addDays(-5).addMinutes(30);
        newSA.ArrivalWindowStartTime = newSA.SchedStartTime.addMinutes(-15);
        newSA.ArrivalWindowEndTime = newSA.SchedEndTime.addMinutes(15);
        newSA.ParentRecordId = acc.Id;
        newSA.Video_Call_Option__c = 'Call Me';
        newSA.Phone = '987-987-9999';
        newSA.Description = 'Test Desc';
        newSA.ServiceTerritoryId = str.Id;
        newSA.ContactId = conObj.Id;
        newSA.workTypeId = wtype.Id;
        newSA.FEP_AppointmentDateTimeText__c = 'Test';
        newSA.FEP_Timezone__c = 'America/New_York';
        newSA.Email = 'abc@gmail.com';
        newSA.FEP_Ext__c = '987'; 
        newSA.Status='Completed';
        insert newSA;
        
        res.ServiceAppointmentId = newSA.id;
        res.ServiceResourceId = resour.Id;
        res.IsRequiredResource = true;
        insert res;
        
        set<Id> servId = new set<Id>();
        servId.add(newSA.Id);
        
        Fep_ScheduleAppointmentController.getSelectedTimeZone(newUser1.Id);
		Fep_ScheduleAppointmentController.getTimeZoneList();
        Fep_ScheduleAppointmentController.getContactRecord(conObj.Id);
        Fep_ScheduleAppointmentController.getAllAppointments(conObj.Id);
        
        Fep_ScheduleAppointmentController.getAssignedResource(servId);
        Fep_ScheduleAppointmentController.getAvailableCoaches();
        
        String str1 = '2021-10-08 13:50:00';
        
        Fep_ScheduleAppointmentController.getAllAvailableTimeSlots(str1,newUser1.Id,'America/New_York'); 
        
        String str2 = '2023-04-08 11:00:00';
        String str3 = '2023-04-08 11:30:00';
        Fep_ScheduleAppointmentController.createTimeSlots(str2,str3,'America/New_York'); 
        
        Fep_ScheduleAppointmentController.correctDateTimeFormat('2023-04-08T11:30:00');
        
        List<String> servCId = new List<String>();
        servCId.add(resour.Id);
        Fep_ScheduleAppointmentController.getAvailableCoachData(servCId); 
        Fep_ScheduleAppointmentController.getReviewScreenData(resour.Id,newUser1.Id); 
        
        
        
        String str4 = '2023-04-08T11:00:00';
        String str5 = '2023-04-08T11:30:00';
        Fep_ScheduleAppointmentController.createServiceAppointments(str4,str5,resour.Id,acc.Id,'Call Me','987-987-9999','Test123',conObj.Id,str5,'America/New_York','abc@gmail.com','9988'); 
        
        Fep_reScheduleAppointmentScreen.getAllAvailableTimeSlotsForCoach(str2,newUser1.Id,newSA.Id,resour.Id,'America/New_York');
        Fep_reScheduleAppointmentScreen.rescheduleServiceAppointments(newSA.Id,str4,str5,'Call Me','987-987-9999','Test123','Tes','America/New_York','9988');
        Fep_reScheduleAppointmentScreen.createTimeSlots(str2,str3,'America/New_York'); 
    }
}