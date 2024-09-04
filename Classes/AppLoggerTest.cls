@SuppressWarnings('PMD.AvoidHardcodingId')
@isTest
public class AppLoggerTest {
  private static final String LONG_TEXT_300 = '012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789';
  private static final String LONG_TEXT_255 = '012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234';

  @IsTest
  public static void testLog() {
    AppLogger.log(
      new App_Log__c(Module__c = 'TestModule', Action__c = 'TestAction', Message__c = LONG_TEXT_300, Record_Id__c = '01232000000UOrPAAW')
    );
    App_Log__c log = [SELECT Module__c, Action__c, Message__c, Record_Id__c FROM App_Log__c];
    System.assertEquals('TestModule', log.Module__c);
    System.assertEquals('TestAction', log.Action__c);
    System.assertEquals('01232000000UOrPAAW', log.Record_Id__c);
    System.assertEquals(LONG_TEXT_255, log.Message__c);
  }

  @IsTest
  public static void testLogError() {
    AppLogger.logError('TestModule', 'TestAction', '01232000000UOrPAAW', 'Exception while doing something', new ValException('Hello World'));

    App_Log__c log = [SELECT Module__c, Action__c, Record_Id__c, Message__c, Details__c FROM App_Log__c];
    System.assertEquals('TestModule', log.Module__c);
    System.assertEquals('TestAction', log.Action__c);
    System.assertEquals('01232000000UOrPAAW', log.Record_Id__c);
    System.assertEquals('Exception while doing something', log.Message__c);
    System.assert(log.Details__c.contains('Hello World') && log.Details__c.contains('at Class.AppLoggerTest.testLogError')); // Testing to make sure stacktrace is there
  }

  @IsTest
  public static void testLogErrorAsync() {
    Test.startTest();
    AppLogger.logErrorAsync('TestModule', 'TestAction', '01232000000UOrPAAW', 'Exception while doing something', new ValException('Hello World'));

    // Upon stopTest it should publish event and hence should create the app log
    Test.stopTest();

    App_Log__c log = [SELECT Module__c, Action__c, Record_Id__c, Message__c, Details__c FROM App_Log__c];
    System.assertEquals('TestModule', log.Module__c);
    System.assertEquals('TestAction', log.Action__c);
    System.assertEquals('01232000000UOrPAAW', log.Record_Id__c);
    System.assertEquals('Exception while doing something', log.Message__c);
    System.assert(log.Details__c.contains('Hello World') && log.Details__c.contains('at Class.AppLoggerTest.testLogError')); // Testing to make sure stacktrace is there
  }
}
