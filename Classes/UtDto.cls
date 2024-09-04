public without sharing class UtDto {
  public static final Integer MAXLENGTH_TEXT = 255;
  public static final Integer MAXLENGTH_LONGTEXT = 131072;

  public static final String LOG_DEBUG = 'Debug';
  public static final String LOG_ERROR = 'Error';

  // We have an account record to represent Sunrun as a company. Since it is accessed quite a few times, we cache it and access it.
  public class SRAccount {
    @AuraEnabled
    public Id id;

    @AuraEnabled
    public String name;
  }
}
