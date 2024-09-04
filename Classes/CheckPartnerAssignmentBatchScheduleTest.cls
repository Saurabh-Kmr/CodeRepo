@istest
public with sharing class CheckPartnerAssignmentBatchScheduleTest {
  public static testMethod void testschedule() {
    Test.StartTest();
    CheckPartnerAssignmentBatchSchedule testsche = new CheckPartnerAssignmentBatchSchedule();
    String sch = '0 0 0/1 1/1 * ? *';
    system.schedule('Test status Check', sch, testsche);
    Test.stopTest();
  }
}
