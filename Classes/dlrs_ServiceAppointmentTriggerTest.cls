@isTest
public class dlrs_ServiceAppointmentTriggerTest {
  @isTest
  public static void dlrs_ServiceAppointmentTriggerTestMethod() {
    Account acc = new Account();
    acc.name = 'New Account Name' + datetime.now();
    acc.description = 'New Account Description' + datetime.now();
    insert acc;

    Contact con = new Contact();
    con.firstName = 'New Contact First';
    con.lastName = 'New Contact Last' + datetime.now();
    con.email = 'hello@example.com';
    con.phone = '4805551212';
    con.title = 'New Contact Title' + datetime.now();
    con.accountId = acc.id;
    insert con;

    Case ca = new Case();
    ca.accountId = acc.id;
    ca.ContactId = con.id;
    ca.status = 'New';
    ca.origin = 'Email';
    ca.subject = 'New Case Subject' + datetime.now();
    ca.description = 'New Case Description' + datetime.now();
    insert ca;

    WorkType wType = new WorkType();
    wType.name = 'testWorkType';
    wType.EstimatedDuration = 10;
    insert wType;

    WorkOrder wo = new WorkOrder();
    wo.subject = 'New Work Order Subject' + datetime.now();
    wo.description = 'New Work Order Description' + datetime.now();
    wo.caseId = ca.id;
    wo.accountId = acc.id;
    wo.contactId = con.id;
    wo.workTypeId = wType.id;
    insert wo;

    ServiceAppointment sa = new ServiceAppointment();
    sa.parentRecordId = wo.id;
    sa.earliestStartTime = datetime.now();
    sa.dueDate = datetime.now() + 30;

    insert sa;
  }
}
