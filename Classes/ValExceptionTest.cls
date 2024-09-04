@isTest
public class ValExceptionTest {
  @isTest
  public static void testValEx() {
    Test.startTest();
    try {
      throw new ValException('Test Error code', 'Test Error Message');
    } catch (ValException ex) {
      System.assertEquals(ex.errorCode == 'Test Error code', true);
    }

    Test.stopTest();
  }
}
