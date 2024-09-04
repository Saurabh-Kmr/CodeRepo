@SuppressWarnings('PMD.ExcessiveParameterList,PMD.ApexCRUDViolation')
public without sharing class AppLogger {
  public static App_Log__c log(App_Log__c log) {
    return log(new List<App_Log__c>{ log }).get(0);
  }

  public static List<App_Log__c> log(List<App_Log__c> logs) {
    if (isEnabled(logs.get(0).Module__c, logs.get(0).Action__c)) {
      logs = processLogs(logs);
      insert logs;
    }

    return logs;
  }

  public static App_Log_Event__e logAsync(App_Log__c log) {
    if (isEnabled(log.Module__c, log.Action__c)) {
      App_Log_Event__e event = new App_Log_Event__e(Payload__c = Json.serialize(processLog(log)));
      EventBus.publish(event);
      return event;
    }

    return null;
  }

  public static List<App_Log__c> logEvents(List<App_Log_Event__e> events) {
    List<App_Log__c> logs = new List<App_Log__c>();

    for (App_Log_Event__e event : events) {
      logs.add((App_Log__c) Json.deserialize(event.Payload__c, App_Log__c.class));
    }

    return log(logs);
  }

  public static App_Log__c logError(String module, String action, String recordId, String message, Exception e) {
    return log(create('Error', module, action, recordId, message, e));
  }

  public static App_Log_Event__e logErrorAsync(String module, String action, String recordId, String message, Exception e) {
    return logAsync(create('Error', module, action, recordId, message, e));
  }

  private static App_Log__c processLog(App_Log__c log) {
    return processLogs(new List<App_Log__c>{ log }).get(0);
  }

  private static List<App_Log__c> processLogs(List<App_Log__c> logs) {
    for (App_Log__c log : logs) {
      log.Type__c = Ut.firstNotBlank(log.Type__c, UtDto.LOG_DEBUG);
      log.Message__c = Ut.truncateToText(Ut.trim(log.Message__c));
      log.Details__c = Ut.truncateToLongText(Ut.trim(log.Details__c));
    }

    return logs;
  }

  private static Boolean isEnabled(String module, String action) {
    return Sf.triggers.isFeatureEnabled('AppLogs') &&
      Sf.triggers.isFeatureEnabled('AppLogs.' + module) &&
      Sf.triggers.isFeatureEnabled('AppLogs.' + module + '.' + action);
  }

  private static App_Log__c create(String type, String module, String action, String recordId, String message, Exception e) {
    return new App_Log__c(
      Type__c = type,
      Module__c = module,
      Action__c = action,
      Record_Id__c = recordId,
      Message__c = Ut.firstNotBlank(message, e == null ? '' : e.getMessage()),
      Details__c = e == null ? null : Ut.getStackTrace(e)
    );
  }
}
