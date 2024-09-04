@SuppressWarnings('PMD.CognitiveComplexity, PMD.ApexCRUDViolation, PMD.ExcessivePublicCount')
public without sharing class TriggerServiceSkipHandler {
  public static final TriggerServiceSkipHandler OBJ = new TriggerServiceSkipHandler();

  private static final List<TriggerDto.Context> DISABLED_TRIGGERS = new List<TriggerDto.Context>();
  private static List<Trigger_Setting__c> soqlResult;
  private static final Map<String, Boolean> TX_FEATURE_FLAGS = new Map<String, Boolean>();
  private static final Map<String, SkipTriggerInfo> TX_TRIGGER_FLAGS = new Map<String, SkipTriggerInfo>();
  private static final String SCOPE_GLOBAL = 'Global';
  private static final String TARGET_ALL = 'all';
  private static final Integer CACHE_TTL = 172800; // sfdc max 2 days in seconds

  public void clearCache() {
    Ut.clearOrgCacheByPrefix(getCacheKey(''));
    soqlResult = null;
    TX_FEATURE_FLAGS.clear();
    TX_TRIGGER_FLAGS.clear();
  }

  public void disableFeatureForTx(String feature) {
    TX_FEATURE_FLAGS.put(cleanupFeatureName(feature), false);
  }

  public void enableFeatureForTx(String feature) {
    TX_FEATURE_FLAGS.put(cleanupFeatureName(feature), true);
  }

  public void clearTxFeatureFlags(String feature) {
    TX_FEATURE_FLAGS.remove(cleanupFeatureName(feature));
  }

  public Boolean isFeatureEnabled(String feature) {
    return isFeatureEnabled(UserInfo.getUserId(), feature);
  }

  public Boolean isFeatureEnabled(Id userId, String feature) {
    String lfeature = cleanupFeatureName(feature);

    if (TX_FEATURE_FLAGS.containsKey(lfeature)) {
      Boolean result = TX_FEATURE_FLAGS.get(lfeature);
      if (!result) {
        System.debug('Feature [' + feature + '] is disabled based on [Tx flags]');
      }
      return result;
    }

    SkipInfo flags = getUserFlags(userId);
    if (flags.isVirtual) {
      // If it is virtual means, there is no entry exists and we created in memory. In such cases, everything
      // is enabled
      return true;
    }

    // If there is no value in either enabled or disabled, then feature is enabled.
    if (flags.enabledFeatures.isEmpty() && flags.disabledFeatures.isEmpty()) {
      return true;
    }

    // Otherwise feature must be enabled and not disabled
    Boolean enabled = false;
    Boolean disabled = false;
    if (flags.enabledFeatures.containsKey(lfeature) || flags.enabledFeatures.containsKey(TARGET_ALL)) {
      enabled = true;
    }

    if (flags.disabledFeatures.containsKey(lfeature) || flags.disabledFeatures.containsKey(TARGET_ALL)) {
      disabled = true;
    }

    Boolean result = enabled && !disabled;
    if (!result) {
      System.debug('Feature [' + feature + '] is disabled for user [' + userId + '] based on [' + flags.source + ']');
    }

    return result;
  }

  public static List<TriggerDto.Context> getDisabledTriggers() {
    return DISABLED_TRIGGERS;
  }

  public void disableTriggerForTx(String sobjName) {
    disableTriggerForTx(sobjName, 'cud');
  }

  public void disableTriggerForTx(String sobjName, String access) {
    clearTxTriggerFlags(sobjName);

    TX_TRIGGER_FLAGS.put(sobjName.toLowerCase(), parseTriggers('Tx Level', sobjName + ':' + access).get(sobjName.toLowerCase()));
  }

  public void enableTriggerForTx(String sobjName, String access) {
    clearTxTriggerFlags(sobjName);

    SkipTriggerInfo flags = parseTriggers('Tx Level', sobjName + ':' + access).get(sobjName.toLowerCase());
    flags.enabled = true;

    TX_TRIGGER_FLAGS.put(sobjName.toLowerCase(), flags);
  }

  public void enableTriggerForTx(String sobjName) {
    enableTriggerForTx(sobjName, 'cud');
  }

  public void clearTxTriggerFlags(String sobjName) {
    TX_TRIGGER_FLAGS.remove(sobjName.toLowerCase());
  }

  public Boolean isTriggerEnabled(TriggerDto.Context info) {
    Ut.checkInputNotBlank(info.sobjectName, 'sobjectName');

    SkipTriggerInfo settings = getObjectFlags(info);

    // By default triggers are enabled.
    Boolean matched = false;

    if (settings != null) {
      if (info.isInsert || info.isBeforeInsert || info.isBeforeUpdate) {
        matched = settings.c;
      } else if (info.isUpdate || info.isBeforeUpdate || info.isAfterUpdate) {
        matched = settings.u;
      } else if (info.isDelete || info.isBeforeDelete || info.isAfterDelete) {
        matched = settings.d;
      }
    }

    Boolean enabled = matched ? settings.enabled : true;
    if (!enabled) {
      String trg = 'Trigger [' + info.sobjectName + ' ' + info.operation + ']';
      System.debug(
        trg + ' is disabled for current user [' + UserInfo.getUserId() + '/' + UserInfo.getName() + '] based on [' + settings.source + ']'
      );

      if (Test.isRunningTest()) {
        DISABLED_TRIGGERS.add(info);
      }

      return false;
    }

    return true;
  }

  private SkipTriggerInfo getObjectFlags(TriggerDto.Context info) {
    // Settings takes effect in this order.
    // 1. User Object Specific Setting
    // 2. User All Objects Setting
    // 3. Global Object Specific Setting
    // 4. Global All Objects Setting
    String sobjectName = info.sobjectName.toLowerCase();

    // first tx level
    SkipTriggerInfo triggerFlags = TX_TRIGGER_FLAGS.get(sobjectName);
    if (triggerFlags != null) {
      return triggerFlags;
    }

    // then user object specific
    SkipInfo flags = getUserFlags();

    triggerFlags = flags.disabledTriggers.get(sobjectName);
    if (triggerFlags != null) {
      return triggerFlags;
    }

    // then all object
    triggerFlags = flags.disabledTriggers.get(TARGET_ALL);
    if (triggerFlags != null) {
      return triggerFlags;
    }

    return null;
  }

  private SkipInfo getUserFlags() {
    return getUserFlags(UserInfo.getUserId());
  }

  private SkipInfo getUserFlags(Id userId) {
    String cacheKey = getUserCacheKey(userId);
    SkipInfo userFlags = getCache(cacheKey);

    if (userFlags == null) {
      System.debug('Refreshing user [' + userId + '] Trigger Settings');

      userFlags = queryAndCreateSkipInfo('User__c', userId);
      userFlags.userId = userId;
      setCache(cacheKey, userFlags);
    }

    if (userFlags.isVirtual) {
      userFlags = getGlobalFlags();
    }

    return userFlags;
  }

  private SkipInfo getGlobalFlags() {
    String cacheKey = getUserCacheKey(SCOPE_GLOBAL);

    if (!Ut.hasOrgCache(cacheKey)) {
      System.debug('Refreshing Global Trigger Settings');

      SkipInfo fflags = queryAndCreateSkipInfo('Name', SCOPE_GLOBAL);
      fflags.isGlobal = true;

      // All triggers cannot be disabled globally as this can cause havoc.
      fflags.disabledTriggers.remove(TARGET_ALL);

      setCache(cacheKey, fflags);
    }

    return getCache(cacheKey);
  }

  private SkipInfo createFlags(Trigger_Setting__c ff) {
    SkipInfo cache = new SkipInfo();
    if (ff != null) {
      cache.featureFlagId = ff.Id;
      cache.featureFlagName = ff.Name;
      cache.source = 'Trigger Setting: ' + ff.Id + '/' + ff.Name;
      cache.enabledFeatures = new Map<String, String>();
      cache.disabledFeatures = parseFeatures(ff.Disable_Features__c);
      cache.disabledTriggers = parseTriggers(cache.source, ff.Disable_Triggers__c);
      cache.isVirtual = false;
    } else {
      cache.isVirtual = true;
    }

    if (!cache.disabledFeatures.isEmpty() && cache.enabledFeatures.isEmpty()) {
      cache.enabledFeatures.put(TARGET_ALL, '');
    }

    return cache;
  }

  private Map<String, SkipTriggerInfo> parseTriggers(String source, String triggers) {
    Map<String, SkipTriggerInfo> triggerFlags = new Map<String, SkipTriggerInfo>();

    if (!String.isBlank(triggers)) {
      List<String> lines = triggers.split('\n');
      for (String line : lines) {
        List<String> parts = line.split(',');
        for (String part : parts) {
          SkipTriggerInfo objFlags = parseObjectTriggerFlags(source, part);
          triggerFlags.put(objFlags.sobjectName.toLowerCase(), objFlags);
        }
      }
    }

    return triggerFlags;
  }

  private Map<String, String> parseFeatures(String features) {
    Map<String, String> maps = new Map<String, String>();
    if (String.isNotBlank(features)) {
      List<String> lines = features.split('\n');
      for (String line : lines) {
        List<String> parts = line.split(',');
        for (String feature : parts) {
          if (String.isNotBlank(feature)) {
            maps.put(cleanupFeatureName(feature), '');
          }
        }
      }
    }

    return maps;
  }

  private String getCacheKey(String name) {
    return 'featureFlags' + name;
  }

  private SkipTriggerInfo parseObjectTriggerFlags(String source, String objTriggerInfo) {
    SkipTriggerInfo settings = new SkipTriggerInfo();
    settings.source = source;

    objTriggerInfo = objTriggerInfo.trim();

    if (!objTriggerInfo.contains(':')) {
      settings.c = true;
      settings.u = true;
      settings.d = true;
      settings.sobjectName = objTriggerInfo.toLowerCase();
      return settings;
    }

    List<String> parts = objTriggerInfo.split(':');
    settings.sobjectName = parts.get(0).toLowerCase();
    if (parts.size() > 1) {
      String crud = parts.get(1).trim().toLowerCase();
      settings.c = crud.contains('c');
      settings.u = crud.contains('u');
      settings.d = crud.contains('d');
    }

    return settings;
  }

  private SkipInfo queryAndCreateSkipInfo(String field, String value) {
    if (soqlResult == null) {
      System.debug('Executing soql to get all active Trigger Settings');

      soqlResult = [
        SELECT Id, Name, User__c, Disable_Features__c, Disable_Triggers__c, Active__c
        FROM Trigger_Setting__c
        WHERE Active__c = TRUE
      ];
    }

    return createFlags((Trigger_Setting__c) Ut.find(soqlResult, field, value));
  }

  private String getUserCacheKey(String userId) {
    return getCacheKey('UserTriggerSetting' + userId);
  }

  private String cleanupFeatureName(String feature) {
    return feature.toLowerCase().trim();
  }

  private SkipInfo getCache(String cacheKey) {
    try {
      return (SkipInfo) Ut.getOrgCache(cacheKey);
    } catch (Exception e) {
      System.debug('Exception while getting cache [' + cacheKey + '] so returning null. ' + e.getMessage());
      return null;
    }
  }

  private void setCache(String cacheKey, SkipInfo flags) {
    try {
      System.debug('Setting Trigger Settings cache [' + cacheKey + '] with value [' + flags + '] and ttl [' + CACHE_TTL + ' secs]');
      Ut.setOrgCache(cacheKey, flags, CACHE_TTL);
      getCache(cacheKey);
    } catch (Exception e) {
      System.debug('Exception while setting cache [' + cacheKey + '] so ignoring. ' + e.getMessage());
    }
  }

  public void handleTriggerSettingTrigger(TriggerDto.Context info) {
    // This trigger is not using the Trigger Framework as this object is used with in that FW and we want this logic
    // to run always irrespective of if Triggers are disabled for an user.
    if (Trigger.isBefore) {
      processBeforeTrigger(info);
    }

    if (Trigger.isAfter) {
      processAfterTrigger(info);
    }
  }

  private void processBeforeTrigger(TriggerDto.Context info) {
    Map<Id, User> usersMap = new Map<Id, User>([SELECT id, name FROM User WHERE id IN :Ut.getIdList(info.newList, 'User__c')]);

    for (Trigger_Setting__c rec : (List<Trigger_Setting__c>) info.newList) {
      // Set the name and Upsert Id
      if (rec.User__c == null && rec.name != SCOPE_GLOBAL) {
        rec.addError('User cannot be blank');
      } else {
        rec.Name = rec.User__c != null ? ('User: ' + usersMap.get(rec.User__c).Name) : SCOPE_GLOBAL;

        // This will help ensure the uniqueness of records
        rec.Upsert_Id__c = rec.User__c != null ? (String) rec.User__c : SCOPE_GLOBAL;
      }
    }
  }

  private void processAfterTrigger(TriggerDto.Context info) {
    List<Task> tasks = new List<Task>();

    // For each user being updated, clear the cache
    for (Trigger_Setting__c nrec : (List<Trigger_Setting__c>) info.newList) {
      Trigger_Setting__c orec = (Trigger_Setting__c) info.getOld(nrec.id);

      Ut.clearOrgCache(getUserCacheKey((nrec.User__c != null ? (String) nrec.User__c : SCOPE_GLOBAL)));

      if (orec != null) {
        if (orec.Disable_Features__c != nrec.Disable_Features__c) {
          tasks.add(
            new Task(
              subject = 'Updated Disable Features',
              whatId = nrec.id,
              status = 'Completed',
              Description = 'Old Value: ' + orec.Disable_Features__c
            )
          );
        }

        if (orec.Disable_Triggers__c != nrec.Disable_Triggers__c) {
          tasks.add(
            new Task(
              subject = 'Updated Disable Triggers',
              whatId = nrec.id,
              status = 'Completed',
              Description = 'Old Value: ' + orec.Disable_Triggers__c
            )
          );
        }
      }
    }

    insert tasks;
  }

  private class SkipInfo {
    public String userId;
    public Boolean isGlobal = false;
    public String featureFlagId;
    public String featureFlagName;
    public String source;
    public Boolean isVirtual = false;
    public Map<String, String> disabledFeatures = new Map<String, String>();
    public Map<String, String> enabledFeatures = new Map<String, String>();
    public Map<String, SkipTriggerInfo> disabledTriggers = new Map<String, SkipTriggerInfo>();
  }

  private class SkipTriggerInfo {
    public String source;
    public String sobjectName;
    public Boolean enabled = false;
    public Boolean c = false;
    public Boolean u = false;
    public Boolean d = false;
  }
}
