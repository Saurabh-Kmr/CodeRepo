@IsTest
public with sharing class TriggerServiceImplTest {
  private static TriggerServiceImpl service = new TriggerServiceImpl();

  public class TestTriggerHandler extends TriggerHandlerBase {
    public Map<String, Boolean> calls = new Map<String, Boolean>();

    public override void beforeInsert(TriggerDto.Context info) {
      calls.put('beforeInsert', true);
    }
    public override void afterInsert(TriggerDto.Context info) {
      calls.put('afterInsert', true);
    }
    public override void beforeUpdate(TriggerDto.Context info) {
      calls.put('beforeUpdate', true);
    }
    public override void afterUpdate(TriggerDto.Context info) {
      calls.put('afterUpdate', true);
    }
    public override void beforeDelete(TriggerDto.Context info) {
      calls.put('beforeDelete', true);
    }
    public override void afterDelete(TriggerDto.Context info) {
      calls.put('afterDelete', true);
    }
    public override void afterUndelete(TriggerDto.Context info) {
      calls.put('afterUndelete', true);
    }
  }

  public class TestTriggerHandler2 extends TriggerHandlerBase {
    public override void beforeInsert(TriggerDto.Context info) {
    }
  }

  @IsTest
  public static void testDelegation() {
    TestTriggerHandler handler = new TestTriggerHandler();
    TriggerDto.Context context = new TriggerDto.Context();

    context = new TriggerDto.Context('Account', TriggerOperation.BEFORE_INSERT);
    service.handle(handler, context);
    System.assertEquals(true, handler.calls.containsKey('beforeInsert'));

    context = new TriggerDto.Context('Account', TriggerOperation.AFTER_INSERT);
    service.handle(handler, context);
    System.assertEquals(true, handler.calls.containsKey('afterInsert'));

    context = new TriggerDto.Context('Account', TriggerOperation.BEFORE_UPDATE);
    service.handle(handler, context);
    System.assertEquals(true, handler.calls.containsKey('beforeUpdate'));

    context = new TriggerDto.Context('Account', TriggerOperation.AFTER_UPDATE);
    service.handle(handler, context);
    System.assertEquals(true, handler.calls.containsKey('afterUpdate'));

    context = new TriggerDto.Context('Account', TriggerOperation.BEFORE_DELETE);
    service.handle(handler, context);
    System.assertEquals(true, handler.calls.containsKey('beforeDelete'));

    context = new TriggerDto.Context('Account', TriggerOperation.AFTER_DELETE);
    service.handle(handler, context);
    System.assertEquals(true, handler.calls.containsKey('afterDelete'));

    context = new TriggerDto.Context('Account', TriggerOperation.AFTER_UNDELETE);
    service.handle(handler, context);
    System.assertEquals(true, handler.calls.containsKey('afterUndelete'));
  }

  @IsTest
  public static void testExclusionCallsCapture() {
    // TestUtils.disableTriggersAll();
    // insert new Account(Name = 'Test');
    // System.assert(!TriggerServiceImpl.getDisabledCalls().isEmpty());
    // System.assertEquals('project__c', TriggerServiceImpl.getDisabledCalls().get(0).sobjName.toLowerCase());
  }

  @IsTest
  public static void testDelegationDisabled() {
    TriggerServiceSkipHandler.OBJ.clearCache();
    insertGlobalSetting('Some_Object__c');

    TestTriggerHandler handler = new TestTriggerHandler();
    TriggerDto.Context context = new TriggerDto.Context();

    context = new TriggerDto.Context('Some_Object__c', TriggerOperation.BEFORE_INSERT);
    service.handle(handler, context);
    System.assertEquals(false, handler.calls.containsKey('beforeInsert'));
  }

  @IsTest
  public static void testNothingDisabledByDefault() {
    // By default nothing is disabled
    assertDisabled('Account', '');
    assertDisabled('Contact', '');
  }

  @IsTest
  public static void testDisabledAllGlobally() {
    insertGlobalSetting('Account,contact');

    assertDisabled('Account', 'cud');
    assertDisabled('account', 'cud');
    assertDisabled('Contact', 'cud');
    assertDisabled('contact', 'cud');
  }

  @IsTest
  public static void testDisabledForTx() {
    assertDisabled('Account', '');

    service.disableTriggerForTx('account');

    assertDisabled('Account', 'cud');

    service.disableTriggerForTx('account', 'c');

    assertDisabled('Account', 'c');

    service.enableTriggerForTx('Account');

    assertDisabled('Account', '');
  }

  @IsTest
  public static void testHierarchyOfSettings() {
    insertGlobalSetting('Account:C,Contact:D,Opportunity:u');
    insertUserSetting('Account:C,Contact,Opportunity:u');

    // User level settings takes precedence
    assertDisabled('Account', 'c');
    assertDisabled('Contact', 'cud');

    // Testing case insensitivity
    assertDisabled('contact', 'cud');
    assertDisabled('Opportunity', 'u');

    // Then user level all object settings takes affect if user level object specific setting not present
    service.clearCache();
    TestUtils.enableTriggersAll();

    insertGlobalSetting('Account:C,Contact:D,Opportunity:u');
    insertUserSetting('Account:C,Contact,all:d');

    assertDisabled('Account', 'c');
    assertDisabled('Contact', 'cud');
    assertDisabled('Opportunity', 'd');

    // Then global object specific settings takes precedence
    service.clearCache();
    TestUtils.enableTriggersAll();

    insertGlobalSetting('Account:C,Contact:D,Opportunity:u,all:c');
    insertUserSetting('Account:C,Contact');

    assertDisabled('Account', 'c');
    assertDisabled('Contact', 'cud');
  }

  @IsTest
  public static void testUserRecordInactive() {
    Trigger_Setting__c flag = new Trigger_Setting__c(
      Name = 'User: ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName(),
      User__c = UserInfo.getUserId(),
      Disable_Triggers__c = 'Account,Contact:c',
      Active__c = false
    );

    insert flag;

    assertDisabled('Account', '');
    assertDisabled('Contact', '');

    service.clearCache();
    flag.Active__c = true;
    update flag;

    assertDisabled('Account', 'cud');

    // For contact, only create is disabled but others are enabled
    assertDisabled('Contact', 'c');
  }

  private static TriggerDto.Context newInfo(String sobj, String oper) {
    TriggerDto.Context info = new TriggerDto.Context();

    info.sobjectName = sobj;
    info.isInsert = oper.contains('c');
    info.isUpdate = oper.contains('u');
    info.isDelete = oper.contains('d');

    return info;
  }

  private static void insertGlobalSetting(String access) {
    insertSetting('Global', null, access);
  }

  private static void insertUserSetting(String access) {
    insertSetting('User: ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName(), UserInfo.getUserId(), access);
  }

  private static void insertSetting(String name, Id userId, String access) {
    insert new Trigger_Setting__c(Name = name, User__c = userId, Disable_Triggers__c = access, Active__c = true);
  }

  private static void assertDisabled(String sobjName, String access) {
    access = access.toLowerCase();

    System.assertEquals(access.contains('c'), !service.isTriggerEnabled(newInfo(sobjName, 'c')));
    System.assertEquals(access.contains('u'), !service.isTriggerEnabled(newInfo(sobjName, 'u')));
    System.assertEquals(access.contains('d'), !service.isTriggerEnabled(newInfo(sobjName, 'd')));
  }

  @IsTest
  static void testFeatureFlagsRecord() {
    String feature = 'someFeatureName';
    Assert.areEqual(true, Sf.triggers.isFeatureEnabled(feature));

    Trigger_Setting__c flag = new Trigger_Setting__c(
      Name = 'User: ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName(),
      User__c = UserInfo.getUserId(),
      Disable_Features__c = feature,
      Active__c = true
    );

    insert flag;

    service.clearCache();
    Assert.areEqual(false, Sf.triggers.isFeatureEnabled(feature));

    flag.Active__c = false;
    update flag;
    service.clearCache();
    Assert.areEqual(true, Sf.triggers.isFeatureEnabled(feature));

    flag.Active__c = true;
    update flag;
    service.clearCache();
    Assert.areEqual(false, Sf.triggers.isFeatureEnabled(feature));

    delete flag;
    service.clearCache();
    Assert.areEqual(true, Sf.triggers.isFeatureEnabled(feature));
  }

  @IsTest
  static void testFeatureFlagTx() {
    String feature = 'someFeatureName';
    Assert.areEqual(true, Sf.triggers.isFeatureEnabled(feature));

    Sf.triggers.disableFeatureForTx(feature);
    Assert.areEqual(false, Sf.triggers.isFeatureEnabled(feature));

    Sf.triggers.enableFeatureForTx(feature);
    Assert.areEqual(true, Sf.triggers.isFeatureEnabled(feature));

    Sf.triggers.disableFeatureForTx(feature);
    Assert.areEqual(false, Sf.triggers.isFeatureEnabled(feature));

    Sf.triggers.clearTxFeatureFlags(feature);
    Assert.areEqual(true, Sf.triggers.isFeatureEnabled(feature));
  }

  @IsTest
  static void testTriggerFlagTx() {
    String sobj = 'account';
    TriggerDto.Context info = new TriggerDto.Context('Account', TriggerOperation.BEFORE_INSERT);
    Assert.areEqual(true, Sf.triggers.isTriggerEnabled(info));

    Sf.triggers.disableTriggerForTx(sobj);
    Assert.areEqual(false, Sf.triggers.isTriggerEnabled(info));

    Sf.triggers.enableTriggerForTx(sobj);
    Assert.areEqual(true, Sf.triggers.isTriggerEnabled(info));

    Sf.triggers.disableTriggerForTx(sobj);
    Assert.areEqual(false, Sf.triggers.isTriggerEnabled(info));

    Sf.triggers.clearTxTriggerFlags(sobj);
    Assert.areEqual(true, Sf.triggers.isTriggerEnabled(info));
  }
}
