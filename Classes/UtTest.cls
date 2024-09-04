@IsTest
@SuppressWarnings('PMD.ApexAssertionsShouldIncludeMessage,PMD.AvoidHardcodingId,PMD.EmptyCatchBlock')
public class UtTest {
  @IsTest
  public static void testDescribeSobj() {
    Schema.DescribeSObjectResult obj = Ut.describeSobj('Account');
    System.assertEquals('Account', obj.name);

    try {
      Ut.describeSobj('BlahBlah');
    } catch (Exception e) {
      Assert.areEqual('Invalid Sobject [BlahBlah]', e.getMessage());
    }
  }

  @IsTest
  public static void testDescribeField() {
    Schema.DescribeFieldResult fld = Ut.describeField('Account', 'Name');
    System.assertEquals('Name', fld.name);

    fld = Ut.describeField('Account', 'Parent.AccountNumber');
    System.assertEquals('AccountNumber', fld.name);

    fld = Ut.describeField('Account', 'Owner.Profile.Name');
    System.assertEquals('Name', fld.name);

    fld = Ut.describeField('Opportunity', 'OpportunityContactRoles.Contact.Email');
    System.assertEquals('Email', fld.name);

    try {
      Ut.describeField('Account', 'BlahBlahBlah');
    } catch (Exception e) {
      System.assertEquals('Invalid Sobject field [Account.BlahBlahBlah]', e.getMessage());
    }

    try {
      Ut.describeField('Account', '.Blah');
    } catch (Exception e) {
      System.assertEquals('Invalid Sobject field [Account..Blah]', e.getMessage());
    }

    try {
      Ut.describeField('Account', 'Blah.');
    } catch (Exception e) {
      System.assertEquals('Invalid Sobject field [Account.Blah.]', e.getMessage());
    }

    try {
      Ut.describeField('Account', 'Owner.Profile.NotAField');
    } catch (Exception e) {
      System.assertEquals('Invalid Sobject field [Account.Owner.Profile.NotAField]', e.getMessage());
    }
  }

  @IsTest
  public static void testGetSobjPrefix() {
    System.assertEquals('005', Ut.getSobjPrefix('User'));
  }

  @IsTest
  public static void testGetSobjName() {
    System.assertEquals('Account', Ut.getSobjName(new Account()));
    System.assertEquals('Account', Ut.getSobjName('0016Q00001iGbkwQAC'));
    System.assertEquals('Account', Ut.getSobjName(new Account()));
    System.assertEquals('Account', Ut.getSobjName('0016Q00001iGbkwQAC'));
  }

  @IsTest
  static void testGetListSet() {
    Assert.areEqual(new List<Id>(), Ut.getIdList(null));

    List<Account> acts = new List<Account>{
      new Account(id = '0016Q00001iGbkwQAC'),
      new Account(id = '0016Q00001iGbkxQAC'),
      new Account(id = '0016Q00001iGbkwQAC'),
      new Account()
    };

    Assert.areEqual(new List<Id>{ '0016Q00001iGbkwQAC', '0016Q00001iGbkxQAC' }, Ut.getIdList(acts));
    Assert.areEqual(new List<Id>{ '0016Q00001iGbkwQAC', '0016Q00001iGbkxQAC', '0016Q00001iGbkwQAC' }, Ut.getIdList(acts, 'Id', false));
    Assert.areEqual(new Set<Id>{ '0016Q00001iGbkwQAC', '0016Q00001iGbkxQAC' }, Ut.getIdSet(acts));

    Assert.areEqual(new Set<String>{ '0016Q00001iGbkwQAC', '0016Q00001iGbkxQAC' }, Ut.getStringSet(acts, 'Id'));
    Assert.areEqual(new List<String>{ '0016Q00001iGbkwQAC', '0016Q00001iGbkxQAC' }, Ut.getStringList(acts, 'Id'));
    Assert.areEqual(new List<String>(), Ut.getStringList(null, 'Id'));
  }

  @IsTest
  static void testGetValues() {
    List<Account> acts = new List<Account>{
      new Account(id = '0016Q00001iGbkxQAC', Name = 'CA'),
      new Account(id = '0016Q00001iGbkwQAC', Name = 'CA'),
      new Account(id = '0016Q00001iGbkwQAC', Name = 'NY')
    };

    Assert.areEqual(new List<String>{ 'CA', 'CA', 'NY' }, Ut.getValues(acts, 'Name'));
    Assert.areEqual(new List<String>{ 'CA', 'CA', 'NY' }, Ut.getValuesString(acts, 'Name'));

    Assert.areEqual(
      new List<Object>{
        new List<Object>{ '0016Q00001iGbkxQAC', 'CA' },
        new List<Object>{ '0016Q00001iGbkwQAC', 'CA' },
        new List<Object>{ '0016Q00001iGbkwQAC', 'NY' }
      },
      Ut.getValues(acts, new List<String>{ 'Id', 'Name' })
    );
  }

  @IsTest
  static void testGetValue() {
    Account act = (Account) Json.deserialize(
      '{"attributes": {"type":"Account"}, "Id": "0016Q00001iGbkxQAC", "Parent": {"attributes": {"type":"Account"}, "Name": "Boing"}}',
      Account.class
    );

    Assert.areEqual('0016Q00001iGbkxQAC', Ut.getValue(act, 'Id'));
    Assert.areEqual('Boing', Ut.getValue(act, 'Parent.Name'));
  }

  @IsTest
  static void testSetValue() {
    Ut.setValue((Sobject) null, 'Name', 'Foo');

    Account act = new Account();
    Ut.setValue(act, 'Name', 'Foo');
    Assert.areEqual('Foo', act.Name);

    Ut.setValue(new List<Account>{ act }, Ut.mapOf('Name', 'Foo2', 'AccountNumber', '123'));
    Ut.setValue(new List<Account>{ act }, 'Name', 'Foo3');
    Assert.areEqual('Foo3', act.Name);
    Assert.areEqual('123', act.AccountNumber);
  }

  @IsTest
  static void testToString() {
    Assert.areEqual(null, Ut.toString(null));
    Assert.areEqual('Abc', Ut.toString('Abc'));
    Assert.areEqual('10', Ut.toString(10));
    Assert.areEqual('true', Ut.toString(true));
    Assert.areEqual('2022-01-01', Ut.toString(Date.newInstance(2022, 1, 1)));
    Assert.areEqual('2022-01-01T00:00:00Z', Ut.toString(DateTime.newInstanceGmt(2022, 1, 1, 0, 0, 0)));
  }

  @IsTest
  static void testFormatIsoDate() {
    Assert.areEqual(null, Ut.formatIsoDate(null));
    Assert.areEqual('2022-01-01', Ut.formatIsoDate(Date.newInstance(2022, 1, 1)));
  }

  @IsTest
  static void testParseIsoDate() {
    Assert.areEqual(Date.newInstance(2022, 1, 1), Ut.parseIsoDate('2022-01-01'));
    Assert.areEqual(null, Ut.parseIsoDate(null));
  }

  @IsTest
  static void testParseIsoDateTime() {
    Assert.areEqual(DateTime.newInstanceGmt(2022, 1, 1, 0, 0, 0), Ut.parseIsoDateTime('2022-01-01T00:00:00Z'));
    Assert.areEqual(null, Ut.parseIsoDateTime(null));
  }

  @IsTest
  static void testGroupBy() {
    List<Account> acts = new List<Account>{
      new Account(id = '0016Q00001iGbkxQAC', Name = 'CA'),
      new Account(id = '0016Q00001iGbkwQAC', Name = 'CA'),
      new Account(id = '0016Q00001iGbkwQAC', Name = 'NY')
    };

    Map<String, List<Sobject>> grps = Ut.groupBy(acts, 'Name');
    Assert.areEqual(2, grps.get('CA').size());
    Assert.areEqual(1, grps.get('NY').size());
  }

  @IsTest
  static void testInitList() {
    Assert.areEqual(new List<Sobject>(), Ut.initList(null));
    Assert.areEqual(new List<Sobject>{ new Account(Name = 'Test') }, Ut.initList(new List<Sobject>{ new Account(Name = 'Test') }));
  }

  @IsTest
  static void getKey() {
    Assert.areEqual('foo-bar', Ut.getKey('foo', 'bar'));
    Assert.areEqual('foo-bar-bob', Ut.getKey(new List<Object>{ 'foo', 'bar', 'bob' }));
  }

  @IsTest
  public static void testGache() {
    String key = 'Test';
    System.assertEquals(null, Ut.getOrgCache(key));
    System.assertEquals('Not Exists', Ut.getOrgCache(key, 'Not Exists'));
    Ut.setOrgCache(key, 'Hello World');
    System.assertEquals('Hello World', Ut.getOrgCache(key));

    Ut.setOrgCache(key, 'Hello World2', 300);
    System.assertEquals('Hello World2', Ut.getOrgCache(key));

    Ut.clearOrgCache(key);
    System.assertEquals(null, Ut.getOrgCache(key));

    Ut.setOrgCache(key, 'Hello World2', 300);
    Ut.clearAllOrgCache();
    System.assertEquals(null, Ut.getOrgCache(key));

    Ut.setOrgCache('Key1a', 'Hello World2', 300);
    Ut.setOrgCache('Key1b', 'Hello World2', 300);
    Ut.setOrgCache('Key2a', 'Hello World2', 300);

    Ut.clearOrgCacheByPrefix('Key1');

    System.assertEquals(null, Ut.getOrgCache('Key1a'));
    System.assertEquals('Hello World2', Ut.getOrgCache('Key2a'));

    System.assertEquals('abc123', Ut.getCleanCacheKey('abc-123'));

    // This clears users cache
    Ut.clearUserCache(UserInfo.getUserId());
  }

  @IsTest
  static void testFirstOrNull() {
    Assert.areEqual(null, Ut.firstOrNull(null));
    Assert.areEqual(null, Ut.firstOrNull(new List<Account>()));
    Assert.areEqual(new Account(), Ut.firstOrNull(new List<Account>{ new Account() }));
  }

  @IsTest
  static void testFind() {
    List<Account> acts = new List<Account>{
      new Account(id = '0016Q00001iGbkxQAC', Name = 'CA'),
      new Account(id = '0016Q00001iGbkwQAC', Name = 'CA'),
      new Account(id = '0016Q00001iGbkwQAC', Name = 'NY')
    };
    Assert.areEqual('0016Q00001iGbkxQAC', Ut.find(acts, 'Id', '0016Q00001iGbkxQAC').Id);
    Assert.areEqual(null, Ut.find(acts, 'Id', '0016Q00001iGbkxZZZ'));
  }

  @IsTest
  public static void testFilter() {
    List<Account> acts = new List<Account>{
      new Account(Name = 'Boing', AnnualRevenue = 1000, AccountNumber = '1234', BillingCity = '123 Some St'),
      new Account(Name = 'Sunrun', AnnualRevenue = 2985, AccountNumber = 'abc235', BillingCity = null),
      new Account(Name = 'Microsoft', AnnualRevenue = 27525, AccountNumber = 'XYZ123', BillingCity = null)
    };

    // Null check
    System.assertEquals(0, Ut.filter(null, 'BillingCity', '123 Some St').size());

    // If criteria is empty, return list as is.
    System.assertEquals(1, Ut.filter(new List<SObject>{ new Account() }, null).size());

    // Matches
    System.assertEquals(1, Ut.filter(acts, 'BillingCity', '123 Some St').size());

    // != value
    System.assertEquals(2, Ut.filter(acts, 'Name', '!Sunrun').size());
    System.assertEquals(3, Ut.filter(acts, 'BillingCity', '!Sunrun').size());

    // != null
    System.assertEquals(3, Ut.filter(acts, 'Name', '!null').size());

    // = null
    System.assertEquals(2, Ut.filter(acts, 'BillingCity', null).size());
    System.assertEquals(2, Ut.filter(acts, 'BillingCity', 'null').size());
  }

  @IsTest
  public static void testCheckNotNull() {
    try {
      Ut.checkNotNull(null, 'input');
      System.assert(false, 'Expected exception');
    } catch (Exception e) {
      // ignore
    }

    Ut.checkNotNull('Hello', 'input');
  }

  @IsTest
  public static void testCheckInputNotNull() {
    try {
      Ut.checkInputNotNull(null, 'input');
      System.assert(false, 'Expected exception');
    } catch (Exception e) {
      // ignore
    }

    Ut.checkInputNotNull('Hello', 'input');
  }

  @IsTest
  public static void testCheckInputNotBlank() {
    try {
      Ut.checkInputNotBlank((String) null, 'input');
      System.assert(false, 'Expected exception');
    } catch (Exception e) {
      // ignore
    }

    try {
      Ut.checkInputNotBlank(' ', 'input');
      System.assert(false, 'Expected exception');
    } catch (Exception e) {
      // ignore
    }

    Ut.checkInputNotBlank('Hello', 'input');
  }

  @IsTest
  public static void testCheckNotBlank() {
    try {
      Ut.checkNotBlank('', 'input');
      System.assert(false, 'Expected exception');
    } catch (Exception e) {
      // ignore
    }

    Ut.checkNotBlank('Hello', 'input');
  }

  @IsTest
  public static void testCheckOne() {
    try {
      Ut.checkOne(2, 'Value cannot be greater than 1');
      System.assert(false, 'Expected exception');
    } catch (Exception e) {
      Assert.areEqual('Value cannot be greater than 1', e.getMessage());
    }

    Ut.checkOne(1, 'input');
  }

  @IsTest
  public static void testIsTrue() {
    System.assertEquals(true, Ut.isTrue('true'));
    System.assertEquals(false, Ut.isTrue('false'));
    System.assertEquals(false, Ut.isTrue(null));
  }

  @IsTest
  public static void testNullIfBlank() {
    System.assertEquals('abc', Ut.nullIfBlank('abc'));
    System.assertEquals(null, Ut.nullIfBlank(' '));
    System.assertEquals(null, Ut.nullIfBlank(''));
  }

  @IsTest
  public static void testEmptyIfNull() {
    System.assertEquals('', Ut.emptyIfNull(null));
    System.assertEquals('abc', Ut.emptyIfNull('abc'));
  }

  @IsTest
  public static void testFirstNotBlank() {
    System.assertEquals('abc', Ut.firstNotBlank(null, 'abc'));
    System.assertEquals('abc', Ut.firstNotBlank('  ', 'abc'));
    System.assertEquals('123', Ut.firstNotBlank('123', 'xyz'));
    System.assertEquals('boing', Ut.firstNotBlank('', '', 'boing'));
    System.assertEquals('Sunrun', Ut.firstNotBlank('', '', null, 'Sunrun'));
  }

  @IsTest
  public static void testSplitToSize() {
    System.assertEquals(new List<String>(), Ut.splitToSize(null, 10));
    System.assertEquals(new List<String>{ 'Hel', 'loW', 'orl', 'd' }, Ut.splitToSize('HelloWorld', 3));
    System.assertEquals(new List<String>{ 'Hello World' }, Ut.splitToSize('Hello World', 50));
    System.assertEquals(new List<String>{ 'Hello', ' Worl', 'd' }, Ut.splitToSize('Hello World', 5));
    System.assertEquals(new List<String>{ 'H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd' }, Ut.splitToSize('Hello World', 1));
  }

  @IsTest
  public static void testJoinCsv() {
    System.assertEquals('abc,xyz', Ut.joinCsv(new List<String>{ 'abc', null, 'xyz' }));
    System.assertEquals('abc,xyz', Ut.joinCsv(new Set<Object>{ 'abc', null, 'xyz' }));
  }

  @IsTest
  static void test_truncate() {
    Assert.areEqual(
      '01234567890123456789012345678901234567890123456789012345678901234567890123456789',
      Ut.truncateToName('012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789')
    );

    Assert.areEqual(
      '012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789',
      Ut.truncateToText('012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789')
    );

    Assert.areEqual(
      '012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789',
      Ut.truncateToLongText('012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789')
    );

    Assert.areEqual(null, Ut.truncate(null, 5));
    Assert.areEqual('Hello', Ut.truncate('Hello World', 5));
    Assert.areEqual('Hello Worl', Ut.truncate('Hello World', 10));
    Assert.areEqual('Hello World', Ut.truncate('Hello World', 11));
    Assert.areEqual('', Ut.truncate('Hello World', 0));

    Assert.areEqual(null, Ut.truncateStart(null, 5));
    Assert.areEqual('World', Ut.truncateStart('Hello World', 5));
    Assert.areEqual('ello World', Ut.truncateStart('Hello World', 10));
    Assert.areEqual('Hello World', Ut.truncateStart('Hello World', 11));
    Assert.areEqual('', Ut.truncateStart('Hello World', 0));
  }

  @IsTest
  static void testGetStackTrace() {
    ValException be = new ValException('test', new ValException('root cause'));
    System.assertNotEquals(null, Ut.getRootException(be));
    System.assertEquals(null, Ut.getRootException(null));
    System.assertNotEquals('', Ut.getStackTrace(be));
  }

  @IsTest
  static void testMapOf() {
    Assert.areEqual(new Map<String, String>{ 'Bob' => 'Alice' }, Ut.mapOf('Bob', 'Alice'));
    Assert.areEqual(new Map<String, String>{ 'Bob' => 'Alice', 'Foo' => 'Bar' }, Ut.mapOf('Bob', 'Alice', 'Foo', 'Bar'));
    Assert.areEqual(
      new Map<String, String>{ 'Bob' => 'Alice', 'Foo' => 'Bar', 'Hello' => 'World' },
      Ut.mapOf('Bob', 'Alice', 'Foo', 'Bar', 'Hello', 'World')
    );
  }

  @IsTest
  static void testListOf() {
    Assert.areEqual(new List<String>{ 'Bob' }, Ut.listOf('Bob'));
    Assert.areEqual(new List<String>{ 'Bob', 'Alice' }, Ut.listOf('Bob', 'Alice'));
    Assert.areEqual(new List<String>{ 'Bob', 'Alice', 'Foo' }, Ut.listOf('Bob', 'Alice', 'Foo'));
    Assert.areEqual(new List<String>{ 'Bob', 'Alice', 'Foo', 'Bar' }, Ut.listOf('Bob', 'Alice', 'Foo', 'Bar'));
    Assert.areEqual(new List<String>{ 'Bob', 'Alice', 'Foo', 'Bar', 'One' }, Ut.listOf('Bob', 'Alice', 'Foo', 'Bar', 'One'));
  }

  @IsTest
  static void testSetOf() {
    Assert.areEqual(new Set<String>{ 'Bob' }, Ut.setOf('Bob'));
    Assert.areEqual(new Set<String>{ 'Bob', 'Alice' }, Ut.setOf('Bob', 'Alice'));
    Assert.areEqual(new Set<String>{ 'Bob', 'Alice', 'Foo' }, Ut.setOf('Bob', 'Alice', 'Foo'));
    Assert.areEqual(new Set<String>{ 'Bob', 'Alice', 'Foo', 'Bar' }, Ut.setOf('Bob', 'Alice', 'Foo', 'Bar'));
    Assert.areEqual(new Set<String>{ 'Bob', 'Alice', 'Foo', 'Bar', 'One' }, Ut.setOf('Bob', 'Alice', 'Foo', 'Bar', 'One'));
  }

  @IsTest
  public static void testTestParams() {
    System.assertEquals(null, Ut.getTestParam('UnitTest'));
    System.assertEquals(null, Ut.getTestParamString('UnitTest'));

    Ut.setTestParam('UnitTest', 'Hello');
    System.assertEquals('Hello', Ut.getTestParam('UnitTest'));
    System.assertEquals('Hello', Ut.getTestParamString('UnitTest'));

    Ut.removeTestParam('UnitTest');
    System.assertEquals(null, Ut.getTestParam('UnitTest'));

    System.assertEquals(false, Ut.isTestParamTrue('UnitTest'));
    Ut.setTestParam('UnitTest', 'true');
    System.assertEquals(true, Ut.isTestParamTrue('UnitTest'));

    Ut.setTestParamNow(DateTime.newInstanceGmt(2022, 1, 1, 2, 3, 4));
    System.assertEquals(DateTime.newInstanceGmt(2022, 1, 1, 2, 3, 4), Ut.now());
  }

  @IsTest
  public static void testGlobalParams() {
    System.assertEquals(null, Ut.getGlobalParam('UnitTest'));
    System.assertEquals(null, Ut.getGlobalParamString('UnitTest'));

    Ut.setGlobalParam('UnitTest', 'Hello');
    System.assertEquals('Hello', Ut.getGlobalParam('UnitTest'));
    System.assertEquals('Hello', Ut.getGlobalParamString('UnitTest'));

    Ut.removeGlobalParam('UnitTest');
    System.assertEquals(null, Ut.getGlobalParam('UnitTest'));

    System.assertEquals(false, Ut.isGlobalParamTrue('UnitTest'));
    Ut.setGlobalParam('UnitTest', 'true');
    System.assertEquals(true, Ut.isGlobalParamTrue('UnitTest'));
  }

  @IsTest
  static void testUrlEncode() {
    Assert.areEqual(null, Ut.urlEncode(null));
    Assert.areEqual('bar+%26+alice', Ut.urlEncode('bar & alice'));
  }

  @IsTest
  static void testSort() {
    Set<String> vals = new Set<String>();
    vals.add('foo');
    vals.add('alice');

    Assert.areEqual(new List<String>{ 'alice', 'foo' }, Ut.sort(vals));
    Assert.areEqual(new List<String>(), Ut.sort((List<String>) null));
  }

  @IsTest
  static void testGetSRAccount() {
    try {
      Ut.getSRAccount();
    } catch (Exception e) {
      System.assertEquals('Sunrun Account is not defined', e.getMessage());
    }

    insert new Account(Name = 'Sunrun');
    System.assertNotEquals(null, Ut.getSRAccount().id);
  }

  @IsTest
  static void testMultiMap() {
    Ut.MultiMap mmap = new Ut.MultiMap();
    mmap.put('Classic', 'Foo');
    mmap.put('Classic', 'Bar');
    mmap.put('Classic', 'Bob');
    mmap.put('Classic', 'Alice');
    mmap.put('Classic', 'Alice');
    mmap.put('Cartoon', 'Fred');

    System.assertEquals(5, mmap.get('Classic').size());
    System.assertEquals(1, mmap.get('Cartoon').size());
    System.assertEquals(null, mmap.get('Classic1'));

    mmap = new Ut.MultiMap(true);
    mmap.put('Classic', 'Foo');
    mmap.put('Classic', 'Alice');
    mmap.put('Classic', 'Alice');
    System.assertEquals(2, mmap.get('Classic').size());
  }

  @IsTest
  public static void testRemovePrefix() {
    System.assertEquals('example.com', Ut.removePrefix('https://example.com', 'https://'));
    System.assertEquals('example.com', Ut.removePrefix('example.com', 'https://'));
    System.assertEquals('Test__c', Ut.removePrefix('.Test__c', '.'));
    System.assertEquals('Test__c', Ut.removePrefix('Test__c', '.'));
    System.assertEquals(null, Ut.removePrefix(null, 'https://'));
  }

  @IsTest
  public static void testRemoveSuffix() {
    System.assertEquals('https://example', Ut.removeSuffix('https://example.com', '.com'));
    System.assertEquals('example.org', Ut.removeSuffix('example.org', '.com'));
    System.assertEquals('Test__c', Ut.removeSuffix('Test__c.', '.'));
    System.assertEquals('Test__c', Ut.removeSuffix('Test__c', '.'));
    System.assertEquals(null, Ut.removeSuffix(null, 'https://'));
  }

  @IsTest
  private static void testSplitCsv() {
    // Test case 1: Empty input
    String input1 = '';
    List<String> expectedOutput1 = new List<String>();
    List<String> actualOutput1 = Ut.splitCsv(input1);
    System.assertEquals(expectedOutput1, actualOutput1);

    // Test case 2: Input with multiple values separated by commas and new lines
    String input2 = 'apple,orange,banana,grape,pear';
    List<String> expectedOutput2 = new List<String>{ 'apple', 'orange', 'banana', 'grape', 'pear' };
    List<String> actualOutput2 = Ut.splitCsv(input2);
    System.assertEquals(expectedOutput2, actualOutput2);

    // Test case 3: Input with extra spaces around values
    String input3 = ' apple , orange,banana , grape , pear ';
    List<String> expectedOutput3 = new List<String>{ 'apple', 'orange', 'banana', 'grape', 'pear' };
    List<String> actualOutput3 = Ut.splitCsv(input3);
    System.assertEquals(expectedOutput3, actualOutput3);
  }

  @IsTest
  static void testBuildSoql() {
    Assert.areEqual('select Id,Name from Account', Ut.buildSoql('Account', new List<String>{ 'Id', 'Name' }));
    Assert.areEqual(
      'select Id,Name from Account where Name = \'Boing\'',
      Ut.buildSoql('Account', new List<String>{ 'Id', 'Name' }, new List<String>{ 'Name = \'Boing\'' })
    );
    Assert.areEqual(
      'select Id,Name from Account where Name = \'Boing\' order by Name',
      Ut.buildSoql('Account', new List<String>{ 'Id', 'Name' }, new List<String>{ 'Name = \'Boing\'' }, 'Name')
    );
    Assert.areEqual(
      'select Id,Name from Account where Name = \'Boing\' order by Name limit 100 offset 100',
      Ut.buildSoql('Account', new List<String>{ 'Id', 'Name' }, new List<String>{ 'Name = \'Boing\'' }, 'Name', 100, 2)
    );
  }

  @IsTest
  static void testDedupe() {
    System.assertEquals(Ut.listOf('CA', 'NY', 'ca'), Ut.dedupe(new List<String>{ 'CA', 'NY', 'CA', 'ca', 'NY' }));
    System.assertEquals(Ut.listOf('CA', 'NY'), Ut.dedupeIc(new List<String>{ 'CA', 'NY', 'CA', 'ca', 'NY' }));
  }

  @IsTest
  public static void testIsChanged() {
    System.assertEquals(true, Ut.isChangedTo(new Account(Name = 'Test1'), new Account(Name = 'Test2'), 'Name', 'Test2'));
    System.assertEquals(false, Ut.isChangedTo(new Account(Name = 'Test2'), new Account(Name = 'Test2'), 'Name', 'Test2'));
    System.assertEquals(false, Ut.isChangedTo(new Account(Name = 'Test2'), new Account(Name = 'Test3'), 'Name', 'Test2'));
  }

  @IsTest
  static void testEncrypt() {
    String key = '01234567890123456789012345678901';
    System.assertEquals('Password', Ut.decrypt(key, Ut.encrypt(key, 'Password')));
  }

  @IsTest
  static void testEnv() {
    System.assertNotEquals(Ut.isSandbox(), Ut.isProd());
  }

  @IsTest
  static void testRandomString() {
    System.assertEquals(16, Ut.getRandomString(16).length());
    System.assertEquals(16, Ut.getRandomNumberString(16).length());
  }

  @IsTest
  static void testTrim() {
    System.assertEquals(null, Ut.trim(null));
    System.assertEquals('abc', Ut.trim(' abc '));
  }
}
