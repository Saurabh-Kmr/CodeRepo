public with sharing class Sf {
  private static final Map<String, Object> TEST_INSTANCES = new Map<String, Object>();

  @TestVisible
  private static Object createInstance(String cls) {
    if (Test.isRunningTest() && TEST_INSTANCES.containsKey(cls)) {
      Object value = TEST_INSTANCES.get(cls);
      if (value instanceof String) {
        cls = (String) value;
      } else {
        return value;
      }
    }
    Type typ = Type.forName(cls);
    Object instance = typ != null ? typ.newInstance() : null;
    if (instance == null) {
      throw new ValException(
        'Couldn\'t successfully instantiate an object for class ' +
          cls +
          '. Please check if Class name is correct, is compilable and current user has access.'
      );
    }
    return instance;
  }

  public static void setTestInstance(String implCls, Object testCls) {
    TEST_INSTANCES.put(implCls, testCls);
  }

  public static TriggerService triggers {
    get {
      return triggers = triggers != null ? triggers : (TriggerService) createInstance('TriggerServiceImpl');
    }
    private set;
  }

  public static SettingsService settings {
    get {
      return settings = settings != null ? settings : (SettingsService) createInstance('SettingsServiceImpl');
    }
    private set;
  }

  public static RuleService rule {
    get {
      return rule = rule != null ? rule : (RuleService) createInstance('RuleServiceImpl');
    }
    private set;
  }
}
