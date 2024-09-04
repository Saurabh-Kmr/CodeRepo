trigger UserTrigger on User(after update) {
  // This logic is not part of standard trigger FW because this must be executed each time user is updated
  // irrespective of if triggers are enabled/disabled as this clearing cache
  UserTriggerHandler.OBJ.handleUserUpdate(new TriggerDto.Context());
}
