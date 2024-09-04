/**
 * Provides various Trigger related framework services, notably trigger exclusion and delegation
 */
public interface TriggerService {
  Boolean isFeatureEnabled(String feature);
  void disableFeatureForTx(String feature);
  void enableFeatureForTx(String feature);
  void clearTxFeatureFlags(String feature);

  Boolean isTriggerEnabled(TriggerDto.Context info);
  void disableTriggerForTx(String sobjName);
  void disableTriggerForTx(String sobjName, String access);
  void enableTriggerForTx(String sobjName);
  void enableTriggerForTx(String sobjName, String access);
  void clearTxTriggerFlags(String sobjName);

  void handle(TriggerHandlerBase handler);
}
