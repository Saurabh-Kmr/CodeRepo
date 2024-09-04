trigger AppLogEventTrigger on App_Log_Event__e(after insert) {
  System.debug('Inserting app log events: ' + Trigger.new);
  AppLogger.logEvents(Trigger.new);
}
