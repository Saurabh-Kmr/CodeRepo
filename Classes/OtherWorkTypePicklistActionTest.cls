@isTest
private class OtherWorkTypePicklistActionTest {
  @isTest
  static void getOtherWorkTypeTest() {
    List<String> category = new List<String>();
    String categoryItem = 'Troubleshoot,System';
    category.add(categoryItem);
    Test.startTest();
    List<List<PicklistWrapper>> pickListWrapperList = OtherWorkTypePicklistAction.getOtherWorkType(category);
    Test.stopTest();
  }
}
