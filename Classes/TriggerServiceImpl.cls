/**
 * Service implements the trigger based framework features, notably Trigger_Settings__c based
 * trigger exclusion
 */
public with sharing class TriggerServiceImpl implements TriggerService {
  private static final TriggerServiceSkipHandler SKIP_HANDLER = TriggerServiceSkipHandler.OBJ;

  public void handle(TriggerHandlerBase handler) {
    handle(handler, new TriggerDto.Context());
  }

  public void handle(TriggerHandlerBase handler, TriggerDto.Context info) {
    if (!isTriggerEnabled(info)) {
      return;
    }

    if (info.isBeforeInsert) {
      handler.beforeInsert(info);
    } else if (info.isAfterInsert) {
      handler.afterInsert(info);
    } else if (info.isBeforeUpdate) {
      handler.beforeUpdate(info);
    } else if (info.isAfterUpdate) {
      handler.afterUpdate(info);
    } else if (info.isBeforeDelete) {
      handler.beforeDelete(info);
    } else if (info.isAfterDelete) {
      handler.afterDelete(info);
    } else if (info.isAfterUndelete) {
      handler.afterUndelete(info);
    }
  }

  public Boolean isTriggerEnabled(TriggerDto.Context info) {
    if (!SKIP_HANDLER.isTriggerEnabled(info)) {
      System.debug(
        'Triggers are disabled for current user [' + UserInfo.getUserId() + '/' + UserInfo.getName() + '] due to Trigger_Setting__c configuration'
      );
      return false;
    }

    return true;
  }

  public Boolean isFeatureEnabled(String feature) {
    return SKIP_HANDLER.isFeatureEnabled(feature);
  }

  public void disableFeatureForTx(String feature) {
    SKIP_HANDLER.disableFeatureForTx(feature);
  }

  public void enableFeatureForTx(String feature) {
    SKIP_HANDLER.enableFeatureForTx(feature);
  }

  public void clearTxFeatureFlags(String feature) {
    SKIP_HANDLER.clearTxFeatureFlags(feature);
  }

  public void disableTriggerForTx(String sobjName) {
    SKIP_HANDLER.disableTriggerForTx(sobjName);
  }

  public void disableTriggerForTx(String sobjName, String access) {
    SKIP_HANDLER.disableTriggerForTx(sobjName, access);
  }

  public void enableTriggerForTx(String sobjName) {
    SKIP_HANDLER.enableTriggerForTx(sobjName);
  }

  public void enableTriggerForTx(String sobjName, String access) {
    SKIP_HANDLER.enableTriggerForTx(sobjName, access);
  }

  public void clearTxTriggerFlags(String sobjName) {
    SKIP_HANDLER.clearTxTriggerFlags(sobjName);
  }

  public void clearCache() {
    SKIP_HANDLER.clearCache();
  }
}
