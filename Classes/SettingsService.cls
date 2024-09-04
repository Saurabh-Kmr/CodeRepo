public interface SettingsService {
  void setForTx(String key, String value);
  void clearForTx(String key);

  String getString(String key);
  String getString(String key, String defaultValue);

  Boolean isTrue(String key);
  Boolean isTrue(String key, Boolean defaultValue);

  Integer getInteger(String key);
  Integer getInteger(String key, Integer defaultValue);

  Decimal getDecimal(String key);
  Decimal getDecimal(String key, Decimal defaultValue);

  Date getDate(String key);
  Date getDate(String key, Date defaultValue);

  DateTime getDateTime(String key);
  DateTime getDateTime(String key, DateTime defaultValue);

  List<String> getList(String key);
  List<String> getList(String key, List<String> defaultValue);

  Map<String, String> getMap(String key);
  Map<String, String> getMap(String key, Map<String, String> defaultValue);
}
