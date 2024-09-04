@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage,PMD.EmptyCatchBlock')
@IsTest
public class SettingsServiceImplTest {
  private static SettingsService settings = Sf.settings;
  private static SettingsServiceImpl impl = new SettingsServiceImpl();

  @IsTest
  public static void testGetString() {
    try {
      settings.getString('StringSetting');
      System.assert(false);
    } catch (ValException e) {
      // Expected
    }

    impl.clearCache();
    impl.setForTx('StringSetting', null);

    try {
      settings.getString('StringSetting');
      System.assert(false);
    } catch (ValException e) {
      // Expected
    }

    impl.clearCache();
    System.assertEquals('DefaultValue', settings.getString('StringSetting', 'DefaultValue'));

    impl.setForTx('StringSetting', 'StringValue');

    System.assertEquals('StringValue', settings.getString('StringSetting'));
    System.assertEquals('StringValue', settings.getString('StringSetting', 'DefaultValue'));
  }

  @IsTest
  public static void testIsTrue() {
    impl.setForTx('BooleanSetting', null);

    Assert.areEqual(false, settings.isTrue('BooleanSetting'));
    System.assertEquals(false, settings.isTrue('BooleanSetting', false));

    impl.setForTx('BooleanSetting', 'true');

    System.assertEquals(true, settings.isTrue('BooleanSetting'));
  }

  @IsTest
  public static void testGetInteger() {
    try {
      settings.getInteger('IntegerSetting');
      System.assert(false);
    } catch (ValException e) {
    }

    impl.setForTx('IntegerSetting', null);

    try {
      settings.getInteger('IntegerSetting');
      System.assert(false);
    } catch (ValException e) {
    }
    System.assertEquals(10, settings.getInteger('IntegerSetting', 10));

    impl.setForTx('IntegerSetting', '115');

    System.assertEquals(115, settings.getInteger('IntegerSetting'));
    System.assertEquals(115, settings.getInteger('IntegerSetting', 10));
  }

  @IsTest
  public static void testGetDecimal() {
    try {
      settings.getDecimal('DecimalSetting');
      System.assert(false);
    } catch (ValException e) {
    }

    impl.setForTx('DecimalSetting', null);

    try {
      settings.getDecimal('DecimalSetting');
      System.assert(false);
    } catch (ValException e) {
    }
    System.assertEquals(10.5, settings.getDecimal('DecimalSetting', 10.5));

    impl.setForTx('DecimalSetting', '115.6');

    System.assertEquals(115.6, settings.getDecimal('DecimalSetting'));
    System.assertEquals(115.6, settings.getDecimal('DecimalSetting', 10.5));
  }

  @IsTest
  public static void testGetDate() {
    try {
      settings.getDate('DateSetting');
      System.assert(false);
    } catch (ValException e) {
    }

    impl.setForTx('DateSetting', null);

    try {
      settings.getDate('DateSetting');
      System.assert(false);
    } catch (ValException e) {
    }
    System.assertEquals(Date.newInstance(2023, 1, 1), settings.getDate('DateSetting', Date.newInstance(2023, 1, 1)));

    impl.setForTx('DateSetting', '2023-02-01');

    System.assertEquals(Date.newInstance(2023, 2, 1), settings.getDate('DateSetting'));
    System.assertEquals(Date.newInstance(2023, 2, 1), settings.getDate('DateSetting', Date.newInstance(2023, 1, 1)));
  }

  @IsTest
  public static void testGetDateTime() {
    try {
      settings.getDateTime('DateTimeSetting');
      System.assert(false);
    } catch (ValException e) {
    }

    impl.setForTx('DateTimeSetting', null);

    try {
      settings.getDateTime('DateTimeSetting');
      System.assert(false);
    } catch (ValException e) {
    }
    System.assertEquals(
      DateTime.newInstanceGmt(2023, 1, 1, 0, 0, 0),
      settings.getDateTime('DateTimeSetting', DateTime.newInstanceGmt(2023, 1, 1, 0, 0, 0))
    );

    impl.setForTx('DateTimeSetting', '2023-02-01T00:00:00Z');

    System.assertEquals(DateTime.newInstanceGmt(2023, 2, 1, 0, 0, 0), settings.getDateTime('DateTimeSetting'));
    System.assertEquals(
      DateTime.newInstanceGmt(2023, 2, 1, 0, 0, 0),
      settings.getDateTime('DateTimeSetting', DateTime.newInstanceGmt(2023, 1, 1, 0, 0, 0))
    );
  }

  @IsTest
  public static void testGetList() {
    try {
      settings.getList('ListSetting');
      System.assert(false);
    } catch (ValException e) {
    }

    impl.setForTx('ListSetting', null);

    try {
      settings.getList('ListSetting');
      System.assert(false);
    } catch (ValException e) {
    }
    System.assertEquals(new List<String>{ 'Foo', 'Bar' }, settings.getList('ListSetting', new List<String>{ 'Foo', 'Bar' }));

    impl.setForTx('ListSetting', 'Bob,Alice');

    System.assertEquals(new List<String>{ 'Bob', 'Alice' }, settings.getList('ListSetting'));
    System.assertEquals(new List<String>{ 'Bob', 'Alice' }, settings.getList('ListSetting', new List<String>{ 'Foo', 'Bar' }));
  }

  @IsTest
  public static void testGetMap() {
    try {
      settings.getMap('MapSetting');
      System.assert(false);
    } catch (ValException e) {
    }

    impl.setForTx('MapSetting', null);

    try {
      settings.getMap('MapSetting');
      System.assert(false);
    } catch (ValException e) {
    }
    System.assertEquals(
      new Map<String, String>{ 'Name' => 'Foo', 'Email' => 'bar@email.com' },
      settings.getMap('MapSetting', new Map<String, String>{ 'Name' => 'Foo', 'Email' => 'bar@email.com' })
    );

    impl.setForTx('MapSetting', 'Name=Bob,Email=alice@email.com');

    System.assertEquals(new Map<String, String>{ 'Name' => 'Bob', 'Email' => 'alice@email.com' }, settings.getMap('MapSetting'));
    System.assertEquals(
      new Map<String, String>{ 'Name' => 'Bob', 'Email' => 'alice@email.com' },
      settings.getMap('MapSetting', new Map<String, String>{ 'Name' => 'Foo', 'Email' => 'bar@email.com' })
    );
  }

  @IsTest
  static void testEncryption() {
    Settings_Encryption__c inst = Settings_Encryption__c.getInstance();
    String key = Ut.getRandomString(32);
    inst.Dev_Key__c = key;
    insert inst;

    String pass = SettingsServiceImpl.encrypt('dev', 'password');
    Ut.setTestParam('SettingsValueEncrKey1', pass);

    // Settings should decrypt and return plain text
    System.assertEquals('password', Sf.settings.getString('EncrKey1'));
  }
}
