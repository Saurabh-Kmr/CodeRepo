@IsTest
public class UserTriggerHandlerTest {
  @IsTest
  static void testUserTrigger() {
    update new User(Id = UserInfo.getUserId(), Disable_Vrules__c = true, Disable_Flows__c = true);
    Assert.areEqual(true, [SELECT Disable_Vrules__c, Disable_Flows__c FROM User WHERE id = :UserInfo.getUserId()].get(0).Disable_Vrules__c);
  }
}
