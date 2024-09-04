@SuppressWarnings('PMD.ApexCRUDViolation,PMD.CognitiveComplexity,PMD.ApexSOQLInjection')
public without sharing class SettingsServiceImpl implements SettingsService {
  private static final Map<String, String> CACHE = new Map<String, String>();
  private static String env = null;
  private static final String PREFIX_ENCR = 'encrypted:';

  public void clearCache() {
    CACHE.clear();
  }

  public void setForTx(String key, String value) {
    CACHE.put(key.toLowerCase(), value);
  }

  public void clearForTx(String key) {
    CACHE.remove(key.toLowerCase());
  }

  private String getStringInternal(String key, String defaultValue) {
    try {
      // We don't refer to org Settings__mdt records during test
      if (Test.isRunningTest()) {
        return Ut.hasTestParam('SettingsValue' + key) ? (String) Ut.getTestParam('SettingsValue' + key) : defaultValue;
      }

      String env = getEnv();
      List<Settings__mdt> settings = Database.query('select ' + env + '__c, ' + env + '_Long__c FROM Settings__mdt WHERE DeveloperName = :key');
      return Ut.firstNotBlank(
        settings.isEmpty() ? null : Ut.firstNotBlank((String) settings.get(0).get(env + '_Long__c'), (String) settings.get(0).get(env + '__c')),
        defaultValue
      );
    } catch (Exception e) {
      throw new ValException('Error getting value for Setting ' + key + '. ' + e.getMessage(), e);
    }
  }

  public String getString(String key) {
    String value = getString(key, null);
    if (value == null) {
      throw new ValException('Setting is not specified for key "' + key + '"');
    }

    return value;
  }

  public String getString(String key, String defaultValue) {
    String lkey = key.toLowerCase();
    if (CACHE.containsKey(lkey)) {
      return CACHE.get(lkey);
    }

    String value = getStringInternal(key, defaultValue);

    if (!String.isBlank(value) && value.startsWith(PREFIX_ENCR)) {
      value = Ut.decrypt(getEncrKey(), Ut.removePrefix(value, PREFIX_ENCR));
    }

    CACHE.put(lkey, value);

    return value;
  }

  public Boolean isTrue(String key) {
    Boolean value = isTrue(key, null);

    if (value == null) {
      throw new ValException('Boolean setting is null for key "' + key + '"');
    }

    return value;
  }

  public Boolean isTrue(String key, Boolean defaultValue) {
    String stringValue = getString(key, null);

    Boolean value = defaultValue == null ? false : defaultValue;

    if (String.isNotBlank(stringValue)) {
      value = Boolean.valueOf(stringValue);
    }

    return value;
  }

  public Integer getInteger(String key) {
    Integer value = getInteger(key, null);
    if (value == null) {
      throw new ValException('Integer Setting is not specified for key "' + key + '"');
    }

    return value;
  }

  public Integer getInteger(String key, Integer defaultValue) {
    String stringValue = getString(key, null);
    Integer value = defaultValue;

    if (String.isNotBlank(stringValue)) {
      value = Integer.valueOf(stringValue);
    }

    return value;
  }

  public Decimal getDecimal(String key) {
    Decimal value = getDecimal(key, null);
    if (value == null) {
      throw new ValException('Decimal Setting is not specified for key "' + key + '"');
    }

    return value;
  }

  public Decimal getDecimal(String key, Decimal defaultValue) {
    String stringValue = getString(key, null);
    Decimal value = defaultValue;

    if (String.isNotBlank(stringValue)) {
      value = Decimal.valueOf(stringValue);
    }

    return value;
  }

  public Date getDate(String key) {
    Date value = getDate(key, null);
    if (value == null) {
      throw new ValException('Date Setting is not specified for key "' + key + '"');
    }

    return value;
  }

  public Date getDate(String key, Date defaultValue) {
    String stringValue = getString(key, null);
    Date value = defaultValue;

    if (String.isNotBlank(stringValue)) {
      value = Ut.parseIsoDate(stringValue);
    }

    return value;
  }

  public DateTime getDateTime(String key) {
    DateTime value = getDateTime(key, null);
    if (value == null) {
      throw new ValException('DateTime Setting is not specified for key "' + key + '"');
    }

    return value;
  }

  public DateTime getDateTime(String key, DateTime defaultValue) {
    String stringValue = getString(key, null);
    DateTime value = defaultValue;

    if (String.isNotBlank(stringValue)) {
      value = Ut.parseIsoDateTime(stringValue);
    }

    return value;
  }

  public List<String> getList(String key) {
    List<String> value = getList(key, null);
    if (value == null) {
      throw new ValException('List setting is not specified for key "' + key + '"');
    }

    return value;
  }

  public List<String> getList(String key, List<String> defaultValue) {
    List<String> listSetting = null;

    //List settings should be stored as follows.
    //value1,value2,value3 etc
    String stringValue = getString(key, null);

    try {
      if (String.isBlank(stringValue)) {
        listSetting = defaultValue;
      } else {
        listSetting = new List<String>();

        String[] values = stringValue.split(',');
        for (String value : values) {
          listSetting.add(value);
        }
      }
    } catch (Exception e) {
      throw new ValException('Exception while getting the String List setting for key ' + key + ' and decoding its value ' + stringValue);
    }

    return listSetting;
  }

  public Map<String, String> getMap(String key) {
    Map<String, String> value = getMap(key, null);
    if (value == null) {
      throw new ValException('Map setting is not specified for key "' + key + '"');
    }

    return value;
  }

  public Map<String, String> getMap(String key, Map<String, String> defaultValue) {
    Map<String, String> mapSetting = null;

    //Map settings should be stored as follows.
    //key1=value1,key2=value2,key3=
    String stringValue = getString(key, null);

    try {
      if (String.isBlank(stringValue)) {
        mapSetting = defaultValue;
      } else {
        mapSetting = new Map<String, String>();

        String[] pairs = stringValue.split(',');
        for (String pair : pairs) {
          String[] keyValues = pair.split('=');
          mapSetting.put(keyValues[0].trim(), keyValues[1].trim());
        }
      }
    } catch (Exception e) {
      throw new ValException('Exception while getting the Map setting for key ' + key + ' and decoding its value ' + stringValue);
    }

    return mapSetting;
  }

  private static final Map<String, String> ENV_MAP = new Map<String, String>{ 'prd' => 'prd', 'stage' => 'uat', 'uat' => 'uat', 'qa' => 'qa' };

  private static String getEnv() {
    if (String.isBlank(env)) {
      env = Test.isRunningTest() ? 'dev' : Ut.getEnv();
      env = Ut.firstNotBlank(ENV_MAP.get(env), 'dev');
    }
    return env;
  }
  private static String getEncrKey() {
    return getEncrKey(getEnv());
  }

  private static String getEncrKey(String env) {
    return Ut.checkNotBlank((String) Settings_Encryption__c.getInstance().get(env + '_Key__c'), 'Settings encryption key is not set for env ' + env);
  }

  public static String encrypt(String env, String clearText) {
    return PREFIX_ENCR + Ut.encrypt(getEncrKey(env), clearText);
  }
}
