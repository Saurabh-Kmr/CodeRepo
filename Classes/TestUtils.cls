@IsTest
public without sharing class TestUtils {
  /**
   * Disables all triggers for current user.
   */
  public static void disableTriggersAll() {
    disableTriggers('all');
  }

  public static void enableTriggersAll() {
    delete [SELECT id FROM Trigger_Setting__c];
    TriggerServiceSkipHandler.OBJ.clearCache();
  }

  public static void disableTriggers(String sobjAndAccess) {
    enableTriggersAll();

    insert new Trigger_Setting__c(
      Name = 'User: ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName(),
      User__c = UserInfo.getUserId(),
      Active__c = true,
      Disable_Triggers__c = sobjAndAccess
    );
  }
}
