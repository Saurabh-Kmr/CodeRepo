@SuppressWarnings(
  'PMD.CognitiveComplexity, PMD.ExcessivePublicCount, PMD.ExcessiveParameterList,PMD.ApexBadCrypto,PMD.ApexSharingViolations,PMD.ExcessiveClassLength,PMD.NcssTypeCount'
)
public class Ut {
  private static final Map<String, Object> TEST_PARAMS = new Map<String, Object>();
  private static final Map<String, Object> GLOBAL_PARAMS = new Map<String, Object>();

  public static Schema.DescribeSObjectResult describeSobj(String sobjName) {
    try {
      return Schema.describeSObjects(new List<String>{ sobjName })[0];
    } catch (Exception e) {
      throw new ValException('Invalid Sobject [' + sobjName + ']', e);
    }
  }

  /**
   * Check if given sobject field is of type reference. It looks in the SobjectField.type property.
   */
  public static Boolean isFieldIdOrRefType(SObjectField field) {
    String fieldType = String.valueOf(field.getDescribe().getType());
    return fieldType == 'Reference' || fieldType == 'Id';
  }

  private static ChildRelationship getChildRel(DescribeSObjectResult sobj, String field) {
    for (ChildRelationship rel : sobj.getChildRelationships()) {
      if (rel.getRelationshipName() == field) {
        return rel;
      }
    }

    return null;
  }

  /**
   * Describes given field. It supports describing base fields, parent fields as well as child field references.
   */
  public static Schema.DescribeFieldResult describeField(String sobjName, String fieldName) {
    Schema.SObjectField fieldDesc = null;

    if (!fieldName.startsWith('.') && !fieldName.endsWith('.')) {
      List<String> parts = fieldName.split('\\.');
      if (parts.size() == 1) {
        DescribeSObjectResult describeResult = describeSobj(sobjName);
        fieldDesc = describeResult.Fields.getMap().get(fieldName);
      } else {
        DescribeSObjectResult currentSobjDesc = describeSobj(sobjName);

        for (String field : parts) {
          Map<String, SObjectField> sobjFieldsMap = currentSobjDesc.fields.getMap();

          // First check if field is base field
          fieldDesc = sobjFieldsMap.get(field);

          // Else check if field is custom relationship field
          if (fieldDesc == null && field.toLowerCase().endsWith('__r')) {
            fieldDesc = sobjFieldsMap.get(field.replace('__r', '__c'));
          }

          // else check if field is standard parent field
          if (fieldDesc == null) {
            fieldDesc = sobjFieldsMap.get(field + 'Id');
          }

          if (fieldDesc == null) {
            // check if field is child field.
            ChildRelationship childRel = getChildRel(currentSobjDesc, field);
            if (childRel != null) {
              currentSobjDesc = childRel.getChildSObject().getDescribe();
              continue;
            } else {
              break;
            }
          }

          if (isFieldIdOrRefType(fieldDesc) && !fieldDesc.getDescribe().referenceto.isEmpty()) {
            currentSobjDesc = fieldDesc.getDescribe().referenceto.get(0).getDescribe();
          }
        }
      }
    }

    if (fieldDesc == null) {
      throw new ValException('Invalid Sobject field [' + sobjName + '.' + fieldName + ']');
    }

    return fieldDesc.getDescribe();
  }

  public static String getSobjPrefix(String sobj) {
    return String.isBlank(sobj) ? null : describeSobj(sobj).getKeyPrefix();
  }

  public static String getSobjName(Sobject sobj) {
    return sobj == null ? null : sobj.getSObjectType().getDescribe().getName();
  }

  public static String getSobjName(Id sobjId) {
    return sobjId == null ? null : sobjId.getSobjectType().getDescribe().getName();
  }

  public static List<Id> getIdList(List<Sobject> sObjects) {
    return getIdList(sobjects, 'Id', true);
  }

  public static List<Id> getIdList(List<Sobject> sObjects, String field) {
    return getIdList(sObjects, field, true);
  }

  public static Set<Id> getIdSet(List<Sobject> sObjects) {
    return getIdSet(sobjects, 'Id');
  }

  public static Set<Id> getIdSet(List<Sobject> sObjects, String field) {
    return new Set<Id>(getIdList(sObjects, field, false));
  }

  public static List<Id> getIdList(List<Sobject> sObjects, String field, Boolean dedupe) {
    List<Id> idList = new List<Id>();
    Map<Id, Id> uniqueMap = new Map<Id, Id>();

    if (sObjects == null) {
      return idList;
    }

    for (SObject sobj : sObjects) {
      String id = getValueString(sobj, field);
      if (String.isBlank(id)) {
        continue;
      }

      Id value = (Id) id;

      if (dedupe && uniqueMap.get(value) != null) {
        continue;
      }

      idList.add(value);
      uniqueMap.put(value, value);
    }

    return idList;
  }

  public static Set<String> getStringSet(List<Sobject> sObjects, String field) {
    return new Set<String>(getStringList(sObjects, field, false));
  }

  public static List<String> getStringList(List<Sobject> sObjects, String field) {
    return getStringList(sObjects, field, true);
  }

  /**
   * Extracts the String values from specified sOBjects for specified field, creates a list of those values
   * and returns the list.
   *
   * If uniqe is true, only the unique String values are returned. String values are not case-converted or trimmed.
   */
  public static List<String> getStringList(List<Sobject> sObjects, String field, Boolean dedupe) {
    List<String> values = new List<String>();

    Map<String, String> uniqueMap = new Map<String, String>();

    if (sObjects == null || sObjects.isEmpty()) {
      return values;
    }

    for (SObject sobj : sObjects) {
      String value = getValueString(sobj, field);
      if (String.isBlank(value)) {
        continue;
      }

      if (dedupe && uniqueMap.get(value) != null) {
        continue;
      }

      values.add(value);
      uniqueMap.put(value, value);
    }

    return values;
  }

  public static List<String> toStringList(List<Object> values) {
    List<String> newValues = new List<String>();

    for (Object val : values) {
      newValues.add(toString(val));
    }

    return newValues;
  }

  public static List<String> getValuesString(List<Sobject> sobjs, String field) {
    return toStringList(getValues(sobjs, field));
  }

  public static List<Object> getValues(List<Sobject> sobjs, String field) {
    List<Object> values = new List<Object>();

    for (Sobject sobj : sobjs) {
      values.add(getValue(sobj, field));
    }

    return values;
  }

  public static List<Object> getValues(Sobject sobj, List<String> fields) {
    List<Object> values = new List<Object>();
    for (String field : fields) {
      values.add(getValue(sobj, field));
    }

    return values;
  }

  public static String getValueString(Sobject sobj, String field) {
    return toString(getValue(sobj, field));
  }

  public static Object getValue(Sobject sobj, String field) {
    if (sobj == null) {
      return null;
    }

    if (field.indexOf('.') < 0) {
      return sobj.get(field);
    }

    Sobject parent = sobj;
    String[] fields = field.split('\\.');
    for (Integer i = 0; i < fields.size() - 1; i++) {
      parent = parent.getSObject(fields[i]);
      if (parent == null) {
        return null;
      }
    }

    return parent.get(fields[fields.size() - 1]);
  }

  public static List<List<Object>> getValues(List<Sobject> sobjs, List<String> fields) {
    List<List<Object>> sobjValues = new List<List<Object>>();
    for (Sobject sobj : sobjs) {
      List<Object> values = new List<Object>();

      for (String field : fields) {
        values.add(getValue(sobj, field));
      }

      sobjValues.add(values);
    }

    return sobjValues;
  }

  public static SObject setValue(SObject sobj, String field, Object value) {
    if (sobj == null) {
      return sobj;
    }

    try {
      sobj.put(field, value);
      return sobj;
    } catch (Exception e) {
      throw new ValException('Error setting Sobject value. ' + e.getMessage() + '. [' + getSobjName(sobj) + '.' + field + ' = ' + value + ']', e);
    }
  }

  public static SObject setValue(SObject sobj, Map<String, Object> values) {
    if (sobj == null || values == null) {
      return sobj;
    }

    for (String field : values.keySet()) {
      setValue(sobj, field, values.get(field));
    }

    return sobj;
  }

  public static List<SObject> setValue(List<SObject> sobjs, String field, Object value) {
    return setValue(sobjs, new Map<String, Object>{ field => value });
  }

  public static List<SObject> setValue(List<SObject> sobjs, Map<String, Object> values) {
    if (sobjs == null || values == null) {
      return sobjs;
    }

    for (SObject sobj : sobjs) {
      setValue(sobj, values);
    }

    return sobjs;
  }

  public static String toString(Object value) {
    if (value == null) {
      return null;
    }

    if (value instanceof Date) {
      return formatIsoDate((Date) value);
    }

    if (value instanceof DateTime) {
      return formatIsoDateTime((DateTime) value);
    }

    return String.valueOf(value);
  }

  public static String formatIsoDate(Date dt) {
    if (dt == null) {
      return null;
    }

    DateTime dtt = DateTime.newInstanceGmt(dt, Time.newInstance(0, 0, 0, 0));
    return dtt.formatGmt('yyyy-MM-dd');
  }

  public static String formatIsoDateTime(DateTime dateTimeVal) {
    if (dateTimeVal == null) {
      return null;
    }
    return dateTimeVal.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
  }

  public static Object getOrgCache(String key) {
    return getOrgCache(key, null);
  }

  public static Object getOrgCache(String key, Object defaultValue) {
    Object value = Cache.Org.get(key);
    return value == null ? defaultValue : value;
  }

  public static String getCleanCacheKey(String key) {
    key = key.replaceAll('[^a-zA-Z0-9]', '');
    return key;
  }

  public static Boolean hasOrgCache(String key) {
    return Cache.Org.contains(key);
  }

  public static void setOrgCache(String key, Object value) {
    Cache.Org.put(key, value, 48 * 60 * 60);
  }

  public static void setOrgCache(String key, Object value, Integer ttlSecs) {
    Cache.Org.put(key, value, ttlSecs);
  }

  public static void clearOrgCache(String key) {
    Cache.Org.remove(key);
  }

  public static void clearOrgCacheByPrefix(String prefix) {
    for (String key : Cache.Org.getKeys()) {
      if (key.startsWith(prefix)) {
        Cache.Org.remove(key);
      }
    }
  }

  public static void clearAllOrgCache() {
    for (String key : Cache.Org.getKeys()) {
      Cache.Org.remove(key);
    }
  }

  public static void clearUserCache(Id userId) {
    clearOrgCache('UserPermsets' + userId);
    clearOrgCache('UserProfile' + userId);
    clearOrgCache('UserRole' + userId);
  }

  public static SObject firstOrNull(List<Sobject> sobjs) {
    return (sobjs == null || sobjs.isEmpty()) ? null : sobjs.get(0);
  }

  public static SObject find(List<SObject> sobjs, String field, Object value) {
    return firstOrNull(filter(sobjs, field, value));
  }

  public static List<SObject> filter(List<SObject> sobjs, String field, Object value) {
    return filter(sobjs, new Map<String, Object>{ field => value });
  }

  public static List<SObject> filter(List<SObject> sobjs, Map<String, Object> criteria) {
    if (sobjs == null) {
      sobjs = new List<SObject>();
    }

    if (criteria == null || criteria.isEmpty()) {
      return sobjs;
    }

    List<SObject> filtered = new List<SObject>();
    for (SObject sobj : sobjs) {
      if (isMatches(sobj, criteria)) {
        filtered.add(sobj);
      }
    }

    return filtered;
  }

  private static Boolean isMatches(SObject sobj, Map<String, Object> criteria) {
    for (String field : criteria.keySet()) {
      Object sobjValue = getValue(sobj, field);
      Object matchValue = criteria.get(field);

      if (!isMatches(sobjValue, matchValue)) {
        return false;
      }
    }

    return true;
  }

  private static Boolean isMatches(Object sobjValue, Object matchValue) {
    if (matchValue == null || matchValue == 'null') {
      return sobjValue == null;
    }

    if (matchValue == '!null') {
      return sobjValue != null;
    }

    if (matchValue.toString().startsWith('!')) {
      matchValue = matchValue.toString().substring(1);
      return sobjValue == null || sobjValue.toString() != matchValue;
    }

    if (matchValue.toString().startsWith('prefix:')) {
      return sobjValue.toString().startsWith(((String) matchValue).substringAfter('prefix:'));
    }

    return sobjValue == matchValue;
  }

  public static Object checkNotNull(Object value, String msg) {
    if (value == null) {
      throw new ValException(msg);
    }

    return value;
  }

  public static Object checkInputNotNull(Object value, String paramName) {
    if (value == null) {
      throw new ValException('Input value for [' + paramName + '] cannot be null');
    }

    return value;
  }

  public static String checkInputNotBlank(String value, String paramName) {
    if (String.isBlank(value)) {
      throw new ValException('Input value for [' + paramName + '] cannot be blank');
    }

    return value;
  }

  public static String checkNotBlank(String value, String msg) {
    if (String.isBlank(value)) {
      throw new ValException(msg);
    }

    return value;
  }

  public static Integer checkOne(Integer value, String msg) {
    if (value > 1) {
      throw new ValException(msg);
    }

    return value;
  }

  public static Boolean isTrue(Object obj) {
    if (obj == null) {
      return false;
    } else if (obj instanceof Boolean) {
      return (Boolean) obj;
    } else {
      return Boolean.valueOf(String.valueOf(obj));
    }
  }

  public static String emptyIfNull(String value) {
    return value == null ? '' : value;
  }

  public static String nullIfBlank(String value) {
    return String.isBlank(value) ? null : value;
  }

  public static String firstNotBlank(String v1, String v2) {
    return String.isNotBlank(v1) ? v1 : v2;
  }

  public static String firstNotBlank(String v1, String v2, String v3) {
    return String.isNotBlank(v1) ? v1 : String.isNotBlank(v2) ? v2 : v3;
  }

  public static String firstNotBlank(String v1, String v2, String v3, String v4) {
    return String.isNotBlank(v1) ? v1 : String.isNotBlank(v2) ? v2 : String.isNotBlank(v3) ? v3 : v4;
  }

  public static List<String> splitToSize(String text, Integer size) {
    List<String> ret = new List<String>();

    if (String.isNotBlank(text)) {
      for (Integer start = 0; start < text.length(); start += size) {
        ret.add(text.substring(start, Math.min(text.length(), start + size)));
      }
    }

    return ret;
  }

  public static String joinCsv(Set<Object> values) {
    return joinCsv(new List<Object>(values));
  }

  public static String joinCsv(List<String> values) {
    return join((List<Object>) values, ',', true);
  }

  public static String joinCsv(List<Object> values) {
    return join(values, ',', true);
  }

  public static String join(List<Object> strings, String separator) {
    return join(strings, separator, true);
  }

  public static String join(List<Object> values, String separator, Boolean skipBlanks) {
    if (values == null) {
      return '';
    }

    if (separator == null) {
      separator = ', ';
    }

    String joinedString = '';
    for (Object value : values) {
      if (skipBlanks && (value == null || (value instanceof String && String.isBlank((String) value)))) {
        continue;
      }

      if (value != null) {
        if (!String.isBlank(joinedString)) {
          joinedString += separator;
        }

        joinedString += value;
      }
    }

    return joinedString;
  }

  /**
   * Parses the ISO date formatted string to date object. Date must be formatted
   * as YYYY-MM-DD. For ex., 2015-07-15
   */
  public static Date parseIsoDate(String isoDate) {
    if (String.isBlank(isoDate)) {
      return null;
    }

    String[] splits = isoDate.split('-');
    return Date.newInstance(Integer.valueOf(splits[0]), Integer.valueOf(splits[1]), Integer.valueOf(splits[2]));
  }

  public static DateTime parseIsoDateTime(String dateTimeString) {
    return String.isBlank(dateTimeString) ? null : (DateTime) json.deserialize('"' + dateTimeString + '"', DateTime.class);
  }

  public static String truncateToName(String value) {
    return truncate(value, 80);
  }

  public static String truncateToText(String value) {
    return truncate(value, UtDto.MAXLENGTH_TEXT);
  }

  public static String truncateToLongText(String value) {
    return truncate(value, UtDto.MAXLENGTH_LONGTEXT);
  }

  public static String truncate(String value, Integer size) {
    if (value == null) {
      return null;
    }

    value = value.trim();

    if (value.length() <= size) {
      return value;
    }

    return value.substring(0, size);
  }

  public static String truncateStart(String value, Integer size) {
    if (value == null) {
      return null;
    }

    value = value.trim();

    if (value.length() <= size) {
      return value;
    }

    return value.substring(value.length() - size);
  }

  public static String trim(String value) {
    return value == null ? null : value.trim();
  }

  /**
   * Returns the root exception of this exception chain.
   */
  public static Exception getRootException(Exception e) {
    if (e == null || e.getCause() == null) {
      return e;
    }

    return getRootException(e.getCause());
  }

  public static String getStackTrace(Exception e) {
    if (e == null) {
      return null;
    }

    String eString = e.getTypeName() + ': ' + e.getMessage() + '\n    at ' + e.getStackTraceString();
    if (e.getCause() != null) {
      eString += '\n' + getStackTrace(e.getCause());
    }

    return eString;
  }

  public static Map<String, List<Sobject>> groupBy(List<Sobject> sobjs, String keyField) {
    return groupBy(sobjs, new List<String>{ keyField });
  }

  public static Map<String, List<Sobject>> groupBy(List<Sobject> sobjs, List<String> keyFields) {
    Map<String, List<Sobject>> info = new Map<String, List<Sobject>>();
    for (Sobject sobj : initList(sobjs)) {
      String key = getKey(getValues(sobj, keyFields));
      if (!info.containsKey(key)) {
        info.put(key, new List<Sobject>());
      }

      info.get(key).add(sobj);
    }

    return info;
  }

  public static List<Sobject> initList(List<Sobject> sobjs) {
    return sobjs == null ? new List<Sobject>() : sobjs;
  }

  public static String getKey(List<Object> values) {
    return join(values, '-');
  }

  public static String getKey(String val1, String val2) {
    return firstNotBlank(val1, '') + (String.isBlank(val2) ? '' : '-' + val2);
  }

  public static List<String> listOf(String val) {
    return new List<String>{ val };
  }

  public static List<String> listOf(String val1, String val2) {
    return new List<String>{ val1, val2 };
  }

  public static List<String> listOf(String val1, String val2, String val3) {
    return new List<String>{ val1, val2, val3 };
  }

  public static List<String> listOf(String val1, String val2, String val3, String val4) {
    return new List<String>{ val1, val2, val3, val4 };
  }

  public static List<String> listOf(String val1, String val2, String val3, String val4, String val5) {
    return new List<String>{ val1, val2, val3, val4, val5 };
  }

  public static Set<String> setOf(String val) {
    return new Set<String>{ val };
  }

  public static Set<String> setOf(String val1, String val2) {
    return new Set<String>{ val1, val2 };
  }

  public static Set<String> setOf(String val1, String val2, String val3) {
    return new Set<String>{ val1, val2, val3 };
  }

  public static Set<String> setOf(String val1, String val2, String val3, String val4) {
    return new Set<String>{ val1, val2, val3, val4 };
  }

  public static Set<String> setOf(String val1, String val2, String val3, String val4, String val5) {
    return new Set<String>{ val1, val2, val3, val4, val5 };
  }

  public static Map<String, Object> mapOf(String k1, Object v1) {
    return new Map<String, Object>{ k1 => v1 };
  }

  public static Map<String, Object> mapOf(String k1, Object v1, String k2, Object v2) {
    return new Map<String, Object>{ k1 => v1, k2 => v2 };
  }

  public static Map<String, Object> mapOf(String k1, Object v1, String k2, Object v2, String k3, Object v3) {
    return new Map<String, Object>{ k1 => v1, k2 => v2, k3 => v3 };
  }

  public static Boolean hasTestParam(String key) {
    return Test.isRunningTest() && TEST_PARAMS.containsKey(key);
  }

  public static Object getTestParam(String key) {
    return TEST_PARAMS.get(key);
  }

  public static String getTestParamString(String key) {
    return String.valueOf(TEST_PARAMS.get(key));
  }

  public static Boolean isTestParamTrue(String key) {
    return isTrue(TEST_PARAMS.get(key));
  }

  public static void setTestParam(String key, Object value) {
    TEST_PARAMS.put(key, value);
  }

  public static void setTestParamNow(Datetime value) {
    TEST_PARAMS.put('Ut-now', value);
  }

  public static void removeTestParam(String key) {
    TEST_PARAMS.remove(key);
  }

  public static void setGlobalParam(String key, Object value) {
    GLOBAL_PARAMS.put(key, value);
  }

  public static Boolean hasGlobalParam(String key) {
    return GLOBAL_PARAMS.containsKey(key);
  }

  public static Object getGlobalParam(String key) {
    return GLOBAL_PARAMS.get(key);
  }

  public static String getGlobalParamString(String key) {
    return String.valueOf(GLOBAL_PARAMS.get(key));
  }

  public static Boolean isGlobalParamTrue(String key) {
    return isTrue(GLOBAL_PARAMS.get(key));
  }

  public static void removeGlobalParam(String key) {
    GLOBAL_PARAMS.remove(key);
  }

  public static Datetime now() {
    if (hasTestParam('Ut-now')) {
      return (DateTime) getTestParam('Ut-now');
    }

    return Datetime.now();
  }

  public static String urlEncode(String value) {
    return String.isBlank(value) ? value : EncodingUtil.urlEncode(value, 'UTF-8');
  }

  public static List<String> sort(Set<String> values) {
    return sort(values == null ? null : new List<String>(values));
  }

  public static List<String> sort(List<String> values) {
    if (values == null) {
      values = new List<String>();
    }
    values.sort();
    return values;
  }

  public static UtDto.SRAccount getSRAccount() {
    UtDto.SRAccount act = (UtDto.SRAccount) getOrgCache('SunrunAccountInfo');
    if (act == null) {
      List<Account> acts = [SELECT id, name FROM Account WHERE name = 'Sunrun' LIMIT 1];
      if (acts.isEmpty()) {
        throw new ValException('Sunrun Account is not defined');
      }
      act = new UtDto.SRAccount();
      act.id = acts.get(0).Id;
      act.name = acts.get(0).Name;
      setOrgCache('SunrunAccountInfo', act);
    }

    return act;
  }

  public static String removePrefix(String input, String prefix) {
    if (input == null || prefix == null || !input.startsWithIgnoreCase(prefix)) {
      return input;
    }

    return input.subString(prefix.length());
  }

  public static String removeSuffix(String input, String suffix) {
    if (input == null || suffix == null || !input.toLowerCase().endsWith(suffix.toLowerCase()) || input.length() < suffix.length()) {
      return input;
    }

    return input.subString(0, input.length() - suffix.length());
  }

  /**
   * This class implements the MultiMap concepts from Guava library. This allows to maintain list of strings for given string key.
   * So it allows to implement Map<String, List<String>> construct without having do heavy listing.
   */
  public class MultiMap {
    private Boolean unique = false;
    private Map<String, List<String>> multimap = new Map<String, List<String>>();
    private Map<String, Set<String>> uniqueMultiMap = new Map<String, Set<String>>();

    public MultiMap() {
      this(false);
    }

    public MultiMap(Boolean unique) {
      this.unique = unique;
    }

    public void put(String key, String value) {
      if (unique) {
        Set<String> values = uniqueMultiMap.get(key);
        if (values == null) {
          values = new Set<String>();
          uniqueMultiMap.put(key, values);
        }
        values.add(value);
      } else {
        List<String> values = multiMap.get(key);
        if (values == null) {
          values = new List<String>();
          multimap.put(key, values);
        }
        values.add(value);
      }
    }

    public Set<String> keyset() {
      return unique ? uniqueMultimap.keySet() : multiMap.keySet();
    }

    public List<String> get(String key) {
      List<String> values = null;
      if (unique) {
        if (uniqueMultiMap.containsKey(key)) {
          values = new List<String>(uniqueMultimap.get(key));
        }
      } else {
        values = multimap.get(key);
      }

      return values;
    }
  }

  public static List<String> splitCsv(String value) {
    return split(value, listOf(','));
  }

  public static List<String> split(String input, List<String> delimiters) {
    List<String> output = new List<String>();

    if (String.isNotBlank(input)) {
      String[] parts = input.split('(' + String.join(delimiters, '|') + ')');

      for (String part : parts) {
        part = part.trim();

        if (String.isNotBlank(part)) {
          output.add(part);
        }
      }
    }

    return output;
  }

  public static Boolean isProd() {
    return getEnv() == 'prd';
  }

  public static Boolean isSandbox() {
    return getEnv() != 'prd';
  }

  public static String getEnv() {
    String type = System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName();
    return String.isBlank(type) ? 'prd' : type;
  }

  public static String encrypt(String key, String clearText) {
    return EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', Blob.valueOf(key), Blob.valueOf(clearText)));
  }

  public static String decrypt(String key, String cipherText) {
    return Crypto.decryptWithManagedIV('AES256', Blob.valueOf(key), EncodingUtil.base64Decode(cipherText)).toString();
  }

  public static List<Sobject> getChangedRecords(List<Sobject> oldSobjs, List<Sobject> newSobjs, List<String> fields) {
    return getChangedRecords(oldSobjs, newSobjs, fields, true);
  }

  public static List<Sobject> getChangedRecords(List<Sobject> oldSobjs, List<Sobject> newSobjs, List<String> fields, Boolean nullSameAsBlank) {
    if (oldSobjs == null || oldSobjs.isEmpty()) {
      return newSobjs;
    }

    List<Sobject> changed = new List<Sobject>();

    for (Integer index = 0; index < oldSobjs.size(); index++) {
      Sobject newSobj = newSobjs.get(index);

      if (isChanged(oldSobjs.get(index), newSobj, fields, nullSameAsBlank)) {
        changed.add(newSobj);
      }
    }

    return changed;
  }

  public static Boolean isChanged(Sobject oldSobj, Sobject newSobj, String field) {
    return isChanged(oldSobj, newSobj, new List<String>{ field }, true);
  }

  public static Boolean isChanged(Sobject oldSobj, Sobject newSobj, String[] fields, Boolean nullSameAsBlank) {
    for (String field : fields) {
      if (isChanged(getValue(oldSobj, field), getValue(newSobj, field), nullSameAsBlank)) {
        return true;
      }
    }

    return false;
  }

  public static Boolean isChangedTo(Sobject oldSobj, Sobject newSobj, String field, List<Object> values) {
    for (Object value : values) {
      if (isChangedTo(oldSobj, newSobj, field, value)) {
        return true;
      }
    }

    return false;
  }

  public static Boolean isChangedTo(Sobject oldSobj, Sobject newSobj, String field, Object value) {
    Object oldVal = getValue(oldSobj, field);
    Object newVal = getValue(newSobj, field);

    return isChanged(oldVal, newVal) && newVal == value;
  }

  public static Boolean isChanged(Object value1, Object value2) {
    return isChanged(value1, value2, true);
  }

  public static Boolean isChanged(Object value1, Object value2, boolean nullSameAsBlank) {
    if (nullSameAsBlank && value1 instanceof String) {
      value1 = nullIfBlank((String) value1);
    }

    if (nullSameAsBlank && value2 instanceof String) {
      value2 = nullIfBlank((String) value2);
    }

    boolean response = false;

    if (value1 == null && value2 == null) {
      response = false;
    } else if (value1 == null || value2 == null) {
      response = true;
    } else if (value1 instanceof String && value2 instanceof String) {
      response = !((String) value1).equals((String) value2);
    } else {
      response = !(value1 == value2);
    }

    return response;
  }

  public static List<String> dedupe(List<String> values) {
    return values == null ? new List<String>() : values.isEmpty() ? values : new List<String>(new Set<String>(values));
  }

  public static List<String> dedupeIc(List<String> values) {
    if (values == null) {
      return new List<String>();
    }

    if (values.size() <= 1) {
      return values;
    }

    List<String> newValues = new List<String>();
    Map<String, Boolean> valuesMap = new Map<String, Boolean>();
    for (String val : values) {
      String valIc = val.toLowerCase();
      if (!valuesMap.containsKey(valIc)) {
        valuesMap.put(valIc, true);
        newValues.add(val);
      }
    }

    return newValues;
  }

  public static String buildSoql(String sobjName, List<String> fields) {
    return buildSoql(sobjName, fields, null, null, null, null);
  }

  public static String buildSoql(String sobjName, List<String> fields, List<String> whereClauses) {
    return buildSoql(sobjName, fields, whereClauses, null, null, null);
  }

  public static String buildSoql(String sobjName, List<String> fields, List<String> whereClauses, String orderField) {
    return buildSoql(sobjName, fields, whereClauses, orderField, null, null);
  }

  public static String buildSoql(String sobjName, List<String> fields, List<String> whereClauses, String orderField, Integer pageSize, Integer page) {
    fields.add(0, 'Id');
    String soql = 'select ' + String.join(dedupeIc(fields), ',') + ' from ' + sobjName;

    if (whereClauses != null && !whereClauses.isEmpty()) {
      soql += ' where ' + join(whereClauses, ' and ');
    }

    if (orderField != null) {
      soql += ' order by ' + orderField;
    }

    if (pageSize != null) {
      soql += ' limit ' + pageSize;
    }

    if (page != null && pageSize != null) {
      soql += ' offset ' + ((page - 1) * pageSize);
    }

    System.debug('Built Soql for ' + sobjName + ' [' + soql + ']');

    return soql;
  }

  public static String getRandomNumberString(Integer length) {
    String value = '';
    while (value.length() < length) {
      String gen = '' + Math.abs(Crypto.getRandomLong());
      if (gen.startsWith('0')) {
        gen = gen.substring(1);
      }
      value += gen;
    }

    return value.substring(0, length);
  }

  public static String getRandomLongString() {
    return String.valueOf(Math.abs(Crypto.getRandomLong()));
  }

  public static String getRandomString(Integer length) {
    String randomString = getRandomLongString();
    while (true) {
      if (randomString.length() == length) {
        break;
      }

      if (randomString.length() < length) {
        randomString += getRandomLongString();
      }

      if (randomString.length() > length) {
        randomString = randomString.substring(0, length);
        break;
      }
    }

    return randomString;
  }

  public static Map<String, Schema.RecordTypeInfo> getRecordTypeInfoMap(String sobjName) {
    return Schema.getGlobalDescribe().get(sobjName).getDescribe().getRecordTypeInfosByName();
  }
}
