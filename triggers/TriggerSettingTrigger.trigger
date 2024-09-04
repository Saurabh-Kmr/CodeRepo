trigger TriggerSettingTrigger on Trigger_Setting__c(before insert, before update, after insert, after update) {
  // This trigger is not using the Trigger Framework as this object is used with in that FW and we want this logic
  // to run always irrespective of if Triggers are disabled for an user.
  TriggerServiceSkipHandler.OBJ.handleTriggerSettingTrigger(new TriggerDto.Context());
}
