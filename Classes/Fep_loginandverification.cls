/*------------------------------------------------------------
Author:        Keyur Jain
Company:       Salesforce
Description:   Controller Class to authenticate user to FEP site
Inputs:                      
Test Class:    Fep_loginandverification_Test
History
13/02/2024      Keyur Jain    New Class Created for PR972315-66
------------------------------------------------------------*/
public without sharing class Fep_loginandverification {
  public static final String REGISTER_MESSAGE = 'The email address you entered is not registered with us. ';
  public static final String REGISTER_MESSAGE_MOBILE = 'The specified phone number is not registered with us. Please provide a valid phone number. ';
  public static final String CONTACTUS_MESSAGE_EMAIL = 'The email address you entered is not registered with us. Please enter the email your employer uses for communications. If you are still having issues ';
  public static final String CONTACTUS_MESSAGE_SMS = 'The mobile phone is not registered with us. Please enter the mobile phone used during registration. If you are still having issues ';
  /*------------------------------------------------------------
    Author:        Keyur Jain
    Company:       Salesforce
    Description:   Function initiates passwordless login for User
    Inputs:        inputValue- Email Id or Phone Number used for authentication
                   verificationMode - Mode of authentication 
    Returns:       String- Returns user id and identifier for passwordless login 
               
    History
   13/02/2024      Keyur Jain    New Function Created for PR972315-66
    ------------------------------------------------------------*/
    @AuraEnabled(cacheable=true)
	public static String handleLoginAndVerification(String inputValue,String verificationMode){ 
    ID userId;
    LoginMetadata ls = new LoginMetadata();
    try{
        Auth.VerificationMethod identifier = verificationMode=='mobile'?Auth.VerificationMethod.SMS:Auth.VerificationMethod.EMAIL;  
       
        List<Contact> contacts = new List<Contact>();
        String identifierID;
       
        if(inputValue != null){
            contacts  = getUserId(inputValue,verificationMode); 
        }
        if(!contacts.isEmpty()){
          List<User> users = [SELECT Id,Email,IsPortalEnabled,IsActive,MobilePhone from User WHERE (email=:inputValue OR MobilePhone=:inputValue) AND IsActive= true AND ContactId=:contacts[0].Id  LIMIT 1] ;
            if(contacts[0].Active__c && !users.isEmpty()){ //&& !contacts[0].Users.isEmpty()){
            userId = users[0].Id;
            identifierID = Test.isRunningTest()?'Created':UserManagement.initPasswordlessLogin(users[0].Id,identifier);
            ls.userId =users[0].Id;
            ls.identifier = identifierID;
            ls.isSuccess = true;
            ls.message = 'existing';
          }
          else if(contacts[0].Active__c && users.isEmpty()){
            ls.userId='Please register yourself by clicking here ';
            ls.identifier ='SelfRegister';
            ls.isSuccess = false;
            ls.message = verificationMode=='mobile'?REGISTER_MESSAGE_MOBILE:REGISTER_MESSAGE;
          }
        }
        else{
          if(verificationMode!='mobile'){
            String accountDomain= inputValue.substringAfterLast('@');
            List<FEP_AllowedLoginsWithoutContacts__mdt> metaDatas = Test.isRunningTest() && accountDomain=='test2.com'? new List<FEP_AllowedLoginsWithoutContacts__mdt>{new FEP_AllowedLoginsWithoutContacts__mdt(DeveloperName ='Test',FEP_EmailDomain__c='test.com', FEP_AccessCode__c ='123') }: [SELECT FEP_EmailDomain__c,FEP_AccessCode__c FROM FEP_AllowedLoginsWithoutContacts__mdt WHERE FEP_EmailDomain__c =:accountDomain];
            if(!metaDatas.isEmpty()){
               List<Account> accnts = [SELECT ID,Name,FEP_Timezone__c FROM Account WHERE Access_Code__c =:metaDatas[0].FEP_AccessCode__c AND Type = 'Active'];
                if(!accnts.isEmpty()){
                  ls.userId='Please register yourself by clicking here ';
                  ls.identifier ='SelfRegister';
                  ls.isSuccess = false;
                  ls.message = verificationMode=='mobile'?REGISTER_MESSAGE_MOBILE:REGISTER_MESSAGE;
                }else{
                  ls.userId = 'please click here to contact us.';
                  ls.identifier='contact-us';
                  ls.isSuccess = false;
                  ls.message = verificationMode=='mobile'?CONTACTUS_MESSAGE_SMS:CONTACTUS_MESSAGE_EMAIL;
                }
              }
              else{
                ls.userId = 'please click here to contact us.';
                ls.identifier='contact-us';
                ls.isSuccess = false;
                ls.message = verificationMode=='mobile'?CONTACTUS_MESSAGE_SMS:CONTACTUS_MESSAGE_EMAIL;
              }
          }
          
        else{
        ls.userId = 'please click here to contact us.';
        ls.identifier='contact-us';
        ls.isSuccess = false;
        ls.message = verificationMode=='mobile'?CONTACTUS_MESSAGE_SMS:CONTACTUS_MESSAGE_EMAIL;
          }
        }
       
         return JSON.serialize(ls);
        }
         catch(Exception ex){
          system.debug(ex.getMessage());
          throw new AuraHandledException(ex.getMessage());
        }
	}
    
    /*------------------------------------------------------------
    Author:        Keyur Jain
    Company:       Salesforce
    Description:   Function Fetches the User ID based on Email
    Inputs:        inputValue- Email Id or Phone Number used for authentication
    Returns:       Id- Returns list of users.
               
    History
   13/02/2024      Keyur Jain    New Function Created for PR972315-66
    ------------------------------------------------------------*/
    public static List<Contact> getUserId(String inputValue,String method){
      String searchQuery = method=='mobile'? 'FIND \''+inputValue+'\' IN PHONE  FIELDS RETURNING  Contact(Id, Name,Active__c WHERE   Active__c =true ) LIMIT 1 ':'FIND \''+inputValue+'\' IN EMAIL  FIELDS RETURNING  Contact(Id, Name,Active__c WHERE  Active__c =true  ) LIMIT 1 ';
      List<List<Contact>> searchList = Search.query(searchQuery);
      if(!searchList[0].isEmpty()){
      List<Contact> contacts = [SELECT Id,Account.Type,Active__c FROM Contact WHERE Id=:searchList[0][0].Id AND Account.Type='Active' AND Active__c =true];
      return contacts;
      }
      return new List<Contact>();

      
    }

    /*------------------------------------------------------------
    Author:        Keyur Jain
    Company:       Salesforce
    Description:   Function verifies the authentication code sent to user
    Inputs:        userId- Id of user who initiated login
                   method- Method of Authentication Email/SMS
                   Identifier - Unique Salesforce generated Salesforce code
                   code- code entered by user for verification
                   startUrl - URL to which user is to redirected
    Returns:       String- URL to which user is redirected to after authentication
               
    History
   13/02/2024      Keyur Jain    New Function Created for PR972315-66
    ------------------------------------------------------------*/
    @AuraEnabled(cacheable=true)
    public static String handleVerification(String userId,String method,String identifier,String code,String startUrl){
      Auth.VerificationMethod verificationMode=method=='mobile'?Auth.VerificationMethod.SMS:Auth.VerificationMethod.EMAIL; 
        Auth.VerificationResult result = UserManagement.verifyPasswordlessLogin(userId, verificationMode, identifier, code, startUrl);
        return result.redirect.getUrl();
    }

    @AuraEnabled
    public static string verifyMobile(String code){
      try{
      String identifier =Test.isRunningTest()?'Created': UserManagement.verifyRegisterVerificationMethod(code, Auth.VerificationMethod.SMS);
      return identifier;
    }
    catch(Exception ex){
      system.debug(ex.getMessage());
      throw new AuraHandledException(ex.getMessage());
    }
    }

    @AuraEnabled
    public static string registerMobile(){
    LoginMetadata ls = new LoginMetadata();
    String identifier = Test.isRunningTest()?'Created':UserManagement.initRegisterVerificationMethod(Auth.VerificationMethod.SMS);
    ls.userId =userInfo.getUserId();
    ls.identifier =identifier;//identifierID;
    ls.isSuccess = true;
    ls.message = 'registermobile';
    return JSON.serialize(ls);
    }
    
    /*------------------------------------------------------------
    Author:        Saurabh Kumar
    Company:       Salesforce
    Description:   Function initiates passwordless login for User
    Inputs:        userId- User Id
                   verificationMode - Mode of authentication 
    Returns:       String- Returns user id and identifier for passwordless login 
               
    History
   13/02/2024      Keyur Jain     New Function Created for PR972315-66
   21/03/2024      Saurabh Kumar  Added resend code functionality
    ------------------------------------------------------------*/
    @AuraEnabled
	  public static String handleResend(Id userId,String verificationMode){ 
      try{
        Auth.VerificationMethod identifier = verificationMode=='mobile'?Auth.VerificationMethod.SMS:Auth.VerificationMethod.EMAIL;  
        String identifierID = Test.isRunningTest()?'Created':UserManagement.initPasswordlessLogin(userId,identifier);
        LoginMetadata ls = new LoginMetadata();
        ls.userId = userId;
        ls.identifier = identifierID;
        ls.isSuccess = true;
        return JSON.serialize(ls);
      }catch(Exception ex){
        system.debug(ex.getMessage());
         throw new AuraHandledException(ex.getMessage());
      }
      }

    // public static PageReference login(String identifier, String startUrl, Map<String, String> requestAttributes) {
    //     if (identifier != null && isValidEmail(identifier)) {
    //         // Search for user by email 
    //         List<User> users = [SELECT Id FROM User WHERE Email = :identifier AND IsActive = TRUE AND id='0056s000006LJL4AAO'];
    //         System.debug('Vrified USer'+users);
    //         if (!users.isEmpty() && users.size() == 1) {
    //             // User must have verified email before using this verification method. We cannot send messages to unverified emails. 
    //             // You can check if the user has email verified bit on and add the password verification method as fallback.
    //             List<TwoFactorMethodsInfo> verifiedInfo = [SELECT HasUserVerifiedEmailAddress FROM TwoFactorMethodsInfo WHERE UserId = :users[0].Id];
    //             System.debug('verifiedInfo'+verifiedInfo);
    //             if (!verifiedInfo.isEmpty() && verifiedInfo[0].HasUserVerifiedEmailAddress == true) {
    //                 // Use email verification method if the user's email is verified.
    //                 System.debug('verifiedInfo1');
    //                 return discoveryResult(users[0], Auth.VerificationMethod.EMAIL, startUrl, requestAttributes);
    //             } else {
    //                 // Use password verification method as fallback if the user's email is unverified.
    //                 return discoveryResult(users[0], Auth.VerificationMethod.PASSWORD, startUrl, requestAttributes);
    //             }
    //         } else {
    //             throw new Auth.LoginDiscoveryException('No unique user found. User count=' + users.size());
    //         }
    //     }
    //     if (identifier != null) {
    //         String formattedSms = getFormattedSms(identifier);
    //         if (formattedSms != null) {
    //             // Search for user by SMS 
    //             List<User> users = [SELECT Id FROM User WHERE MobilePhone = :formattedSms AND IsActive = TRUE];
    //             if (!users.isEmpty() && users.size() == 1) {
    //                 // User must have verified SMS before using this verification method. We cannot send messages to unverified mobile numbers. 
    //                 // You can check if the user has mobile verified bit on or add the password verification method as fallback.
    //                 List<TwoFactorMethodsInfo> verifiedInfo = [SELECT HasUserVerifiedMobileNumber FROM TwoFactorMethodsInfo WHERE UserId = :users[0].Id];
    //                 System.debug('verifiedInfo'+verifiedInfo);
    //                 if (!verifiedInfo.isEmpty() && verifiedInfo[0].HasUserVerifiedMobileNumber == true) {
    //                     // Use SMS verification method if the user's mobile number is verified.
    //                     return discoveryResult(users[0], Auth.VerificationMethod.SMS, startUrl, requestAttributes);
    //                 } else {
    //                     // Use password verification method as fallback if the user's mobile number is unverified.
    //                     return discoveryResult(users[0], Auth.VerificationMethod.PASSWORD, startUrl, requestAttributes);
    //                 }
    //             } else {
    //                 throw new Auth.LoginDiscoveryException('No unique user found. User count=' + users.size());
    //             }
    //         }
    //     }
    //     if (identifier != null) {
    //         // You can customize the code to find user via other attributes, such as SSN or Federation ID
    //     }
    //     throw new Auth.LoginDiscoveryException('Invalid Identifier');
    // }
    
    // private static boolean isValidEmail(String identifier) {
    //     String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
    //     // source: http://www.regular-expressions.info/email.html 
    //     Pattern EmailPattern = Pattern.compile(emailRegex);
    //     Matcher EmailMatcher = EmailPattern.matcher(identifier);
    //     if (EmailMatcher.matches()) { return true; }
    //     else { return false; }
    // }
    
    // private static String getFormattedSms(String identifier) {
    //     // Accept SMS input formats with 1 or 2 digits country code, 3 digits area code and 7 digits number
    //     // You can customize the SMS regex to allow different formats
    //     String smsRegex = '^(\\+?\\d{1,2}?[\\s-])?(\\(?\\d{3}\\)?[\\s-]?\\d{3}[\\s-]?\\d{4})$';
    //     Pattern smsPattern = Pattern.compile(smsRegex);
    //     Matcher smsMatcher = SmsPattern.matcher(identifier);
    //     if (smsMatcher.matches()) {
    //         try {
    //             // Format user input into the verified SMS format '+xx xxxxxxxxxx' before DB lookup
    //             // Append US country code +1 by default if no country code is provided
    //             String countryCode = smsMatcher.group(1) == null ? '+1' : smsMatcher.group(1);
    //             return System.UserManagement.formatPhoneNumber(countryCode, smsMatcher.group(2));
    //         } catch(System.InvalidParameterValueException e) {
    //             return null;
    //         }
    //     } else { return null; }
    // }
    
    // private static PageReference getSsoRedirect(User user, String startUrl, Map<String, String> requestAttributes) {
    //     // You can look up if the user should log in with SAML or an Auth Provider and return the URL to initialize SSO.
    //     return null;
    // }
    
    // private static PageReference discoveryResult(User user, Auth.VerificationMethod method, String startUrl, Map<String, String> requestAttributes) {
    //     //Only external users with an External Identity or community license can login using Site.passwordlessLogin
    //     //Use getSsoRedirect to enable internal user login for a community
    //     PageReference ssoRedirect = getSsoRedirect(user, startUrl, requestAttributes);
    //     if (ssoRedirect != null) {
    //         return ssoRedirect;
    //     } else {
    //         if (method != null) {
    //             List<Auth.VerificationMethod> methods = new List<Auth.VerificationMethod>();
    //             methods.add(method);
    //             System.debug('Passwordless'+user.Id);
    //             System.debug('Passwordless->methods'+methods);
    //             System.debug('Passwordless->startUrl'+startUrl);
    //             PageReference pwdlessRedirect = Site.passwordlessLogin(user.Id, methods, startUrl);
    //             System.debug('pwdlessRedirect'+pwdlessRedirect);
    //             if (pwdlessRedirect != null) {
    //                 return pwdlessRedirect;
    //             } else {
    //                 throw new Auth.LoginDiscoveryException('No Passwordless Login redirect URL returned for verification method: ' + method);
    //             }
    //         } else {
    //             throw new Auth.LoginDiscoveryException('No method found');
    //         }
    //     }
    // }
    public class LoginMetadata{
        public String identifier;
        public String userId;
        public Boolean isSuccess;
        public String message;
    }
}