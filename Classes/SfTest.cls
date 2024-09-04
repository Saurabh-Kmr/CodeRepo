@IsTest
private class SfTest {
  @IsTest
  static void testNewInstance() {
    String fo = 'force';
    String st = 'sales';
    Sf.setTestInstance(st, fo);
    try {
      Sf.createInstance('NonExisting');
      System.assert(false, 'Expecting exception as we are trying to create instance of non-existing class');
    } catch (Exception e) {
      //expected
    }
  }

  @IsTest
  public static void testGetServices() {
    System.assertNotEquals(null, Sf.settings);
    System.assertNotEquals(null, Sf.triggers);
    System.assertNotEquals(null, Sf.rule);
  }
}
