@isTest
public class IcarusBatchSchedularTest {
  @isTest
  public static void testBatchSchedule() {
    Test.startTest();
    String schedmondaily = '0 00 05 ? * *';
    IcarusBatchSchedular icarusSchedular = new IcarusBatchSchedular();
    String jobId = System.schedule('IcarusBatch', schedmondaily, icarusSchedular);
    CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE id = :jobId
    ];
    System.assertEquals(schedmondaily, ct.CronExpression);
    Test.stopTest();
  }
  @isTest
  public static void testBatchScheduleWithBatchSize() {
    Test.startTest();
    String schedmondaily = '0 00 05 ? * *';
    IcarusBatchSchedular icarusSchedular = new IcarusBatchSchedular(1000);
    String jobId = System.schedule('IcarusBatch', schedmondaily, icarusSchedular);
    CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE id = :jobId
    ];
    System.assertEquals(schedmondaily, ct.CronExpression);
    Test.stopTest();
  }
}
