/**
 * @description       : 
 * @author            : harry.ha@neuraflash.com
 * @group             : 
 * @last modified on  : 11-09-2021
 * @last modified by  : harry.ha@neuraflash.com
**/
@isTest
public class ServiceAppointmentInvocable_Test {
    @TestSetup
    static void makeData(){
        User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'FEP_Associate'].Id,
            Username = 'testUserPwc000@pwc.invalid.com' + System.currentTimeMillis(),
            LastName = 'TestUserLast',
            Email = 'testUser@pwc.invalid.com',
            CompanyName = 'PwC',
            Title = 'FEP Associate Coach',
            Alias = 'testufep',
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert testUser;
    }
    @isTest static void testCreateServiceAppointment() {
        OperatingHours testOperatingHrs = new OperatingHours(Name='Test Operating Hours', TimeZone='America/New_York');
        insert testOperatingHrs;
        ServiceTerritory testSvcTerritory = new ServiceTerritory(Name='Test Service Territory', OperatingHoursId =testOperatingHrs.Id, IsActive=true);
        insert testSvcTerritory;
        
        WorkType testWorkType = new WorkType(
            Name = 'Test Work Type',
            EstimatedDuration = 20,
            DurationType = 'Minutes'
        );
        insert testWorkType;
        Account testAccount = new Account(Name = 'PwC Test Company');
        insert testAccount;
        Contact testContact = new Contact(FirstName = 'TestFName', LastName = 'TestLName', AccountId = testAccount.Id);
        insert testContact;
        Lead tempLead = new Lead(FirstName='LeadFirst', LastName='LeadLast', Email='testcustomer@pwc.invalid.com', Phone='123-123-1234');
        ServiceResource testServiceResource = new ServiceResource(Name='TestServiceResource'
            , ResourceType ='T'
            , RelatedRecordId=[SELECT Id FROM User WHERE Alias = 'testufep' LIMIT 1].Id
            , IsActive=true);
        insert testServiceResource;
        String svcApptFields = '{\"AdditionalInformation\":\"\",\"AppointmentType\":\"Phone\",\"Comments\":\"\",\"ServiceTerritoryId\":\"'+testSvcTerritory.Id+'\",\"ServiceResourceId\":\"'+testServiceResource.Id+'\",\"WorkTypeGroupId\":\"0VS8G0000004C9nWAE\",\"SchedStartTime\":\"2021-10-08T13:30:00.000Z\",\"SchedEndTime\":\"2021-10-08T13:50:00.000Z\",\"Phone\":\"\",\"Email\":\"\",\"IsAnonymousBooking\":false,\"isSlotChanged\":false,\"Name__c\":\"Holly Hollister\",\"Company__c\":\"Hollister\",\"Description\":\"Hollister\",\"Subject\":\"Hollister\",\"Video_Call_Option__c\":\"Call Me\"}';
        List<ServiceAppointmentInvocable.ServiceAppointmentInvocableRequest> reqList = new List<ServiceAppointmentInvocable.ServiceAppointmentInvocableRequest>();
        ServiceAppointmentInvocable.ServiceAppointmentInvocableRequest req = new ServiceAppointmentInvocable.ServiceAppointmentInvocableRequest();
        req.InputContact = testContact;
        req.InputLead = tempLead;
        req.InputWorkType = [SELECT Id FROM WorkType WHERE Name = 'Test Work Type' LIMIT 1];
        req.InputSelectedTimezone = 'America/New_York';
        req.InputSvcApptFields = svcApptFields;
        reqList.add(req);
        Test.startTest();
        List<ServiceAppointmentInvocable.ServiceAppointmentInvocableResult> result = ServiceAppointmentInvocable.saveServiceAppointmentForContact(reqList);
        //System.assertEquals(1, Limits.getEmailInvocations(), 'An email should be sent with the creation of a service appointment.');
        Test.stopTest();
        System.assertEquals(true, result[0].isSuccess);
    }
}