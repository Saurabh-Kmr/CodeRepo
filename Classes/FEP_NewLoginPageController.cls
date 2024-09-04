/*------------------------------------------------------------
Author:        Saurabh Kumar
Company:       Salesforce
Description:   Controller Class to authenticate new user to FEP site
Inputs:                      
Test Class:    FEP_NewLoginPageController_Test
History
13/02/2024      Saurabh Kumar    New Class Created for PR972315-28
------------------------------------------------------------*/

public without sharing class FEP_NewLoginPageController {


  /*------------------------------------------------------------
    Author:        Saurabh Kumar
    Company:       Salesforce
    Description:   Function to return fields present in Fieldset
    Inputs:        sObjectName- API Name of Object whose field set 
                                is to be retrieved
                   fSName - Field Set to be retrieved
    Returns:       String- Comma separated String of fields present
                    in field set 
               
    History
   13/02/2024      Saurabh Kumar    New Function Created for PR972315-28
    ------------------------------------------------------------*/

  @AuraEnabled(cacheable=true)
  public static String loginCreationFields(String sobjectName, String fSName) {
     List<Schema.FieldSetMember> opFSMs = new List<Schema.FieldSetMember>();
        if(!String.isBlank(fSName) && !String.isBlank(sobjectName)){
            Map<String, Schema.SObjectType> describeMapGlobal = Schema.getGlobalDescribe(); 
            Schema.SObjectType typeObj = describeMapGlobal.get(sobjectName);
            Schema.DescribeSObjectResult describeSobjectRes = typeObj.getDescribe();
            Schema.FieldSet fieldSetObj = describeSobjectRes.FieldSets.getMap().get(fSName); 
            opFSMs = fieldSetObj.getFields();
        }
     return JSON.serialize(opFSMs);
    }

    /*------------------------------------------------------------
    Author:        Saurabh Kumar
    Company:       Salesforce
    Description:   Function to Check if Contact exist and either create User
                    or dispaly message
    Inputs:        firstName- First Name entered by User on UI
                   lastName- Last Name entered by User on UI
                   phone- Phone entered by User on UI
                   email- Email entered by User on UI
                   veriMethod- Verification method entered by User on UI
    Returns:       string- Returns result of self registration process.
               
    History
   13/02/2024      Saurabh Kumar    New Function Created for PR972315-28
    ------------------------------------------------------------*/

    @AuraEnabled
    public static string verifyContactExists(String firstName,String lastName,String phone,String email , String veriMethod, Boolean isGeneral,String companyName){
        registerResult selfRegisterResult = new registerResult();
        selfRegisterResult.url= '/error';
        selfRegisterResult.method = veriMethod;
        selfRegisterResult.operation = 'SelfRegister';
        selfRegisterResult.isSuccess = False;

        Auth.VerificationMethod identifier = veriMethod=='mobile'?Auth.VerificationMethod.SMS:Auth.VerificationMethod.EMAIL;
        List<Contact> contacts = [SELECT id,AccountId,Account.FEP_Timezone__c,Company_Provided_Email__c,Active__c FROM Contact where Company_Provided_Email__c=:email  AND Active__c=true AND Account.Type='Active' LIMIT 1];
        if(!contacts.isEmpty() && contacts[0]!=null && contacts[0].Active__c){
            List<User> users =[SELECT id,Email,ContactId,IsActive,IsPortalEnabled FROM User where ContactId=:contacts[0].id];
            if(!users.isEmpty() && users[0]!=null){
                
                selfRegisterResult.url='/login';
              //  result= AutocreatedDiscLoginHandler1707892471157.handleLoginAndVerification(identifier,'/',new Map<String,string>());
            }
            else if(users.isEmpty() ){
                Id profileId;
                List<Profile> communityProfile =[SELECT Id,Name FROM Profile WHERE Name =:System.label.fep_CustomerPortalPlusProfileId];
                profileId = !communityProfile.isEmpty()?communityProfile[0].Id:null;
                List<Auth.VerificationMethod> methods = new List<Auth.VerificationMethod>();
                methods.add(identifier);
                Map<SObjectField, String> registrationAttributes =  new Map<SObjectField, String> ();
                Schema.DescribeFieldResult firstNameFieldResult = User.FirstName.getDescribe();
                Schema.sObjectField firstNameField = firstNameFieldResult.getSObjectField();
                registrationAttributes.put(firstNameField,firstName);
                Schema.DescribeFieldResult lastNameFieldResult = User.LastName.getDescribe();
                Schema.sObjectField lastNameField = lastNameFieldResult.getSObjectField();
                registrationAttributes.put(lastNameField,lastName);
                Schema.DescribeFieldResult mobileFieldResult = User.MobilePhone.getDescribe();
                Schema.sObjectField mobileField = mobileFieldResult.getSObjectField();
                registrationAttributes.put(mobileField,phone);
                Schema.DescribeFieldResult emailFieldResult = User.Email.getDescribe();
                Schema.sObjectField emailField = emailFieldResult.getSObjectField();
                registrationAttributes.put(emailField,email);
                Schema.DescribeFieldResult contactFieldResult = User.ContactId.getDescribe();
                Schema.sObjectField contactField = contactFieldResult.getSObjectField();
                registrationAttributes.put(contactField,contacts[0].id);
                Schema.DescribeFieldResult timeZoneFieldResult = User.TimeZoneSidKey.getDescribe();
                Schema.sObjectField timeZoneField = timeZoneFieldResult.getSObjectField();
                registrationAttributes.put(timeZoneField,contacts[0].Account.FEP_Timezone__c);
                //Id userId = new AutocreatedConfigSelfReg1707895433051().createUser(contacts[0].AccountId,System.label.fep_CustomerPortalPlusProfileId,registrationAttributes,null);
              //  system.debug('network'+Network.getNetworkId());
              //  result= UserManagement.createSelfRegisterUser(identifier, user)
                //Boolean sent=System.UserManagement.sendAsyncEmailConfirmation(userId,'00X6s0000038MwSEAU',Network.getNetworkId(),'/');
                //verifyRegisterVerificationMethod
                
                selfRegisterResult.url= AutocreatedConfigSelfReg1707895433051.createSelfRegisterUser(contacts[0].AccountId,profileId,registrationAttributes,null,identifier);
                selfRegisterResult.method = veriMethod;
                selfRegisterResult.operation = 'SelfRegister';
                selfRegisterResult.isSuccess = True;
                return JSON.serialize(selfRegisterResult);
            }
        }
     /*   else if(!contacts.isEmpty() && contacts[0]!=null && !contacts[0].Active__c){
            selfRegisterResult.url= '/impacted-employees';
            selfRegisterResult.method = veriMethod;
            selfRegisterResult.operation = 'SelfRegister';
            selfRegisterResult.isSuccess = False;
        }*/
       
        else{
            String accountDomain= email.substringAfterLast('@');
            List<FEP_AllowedLoginsWithoutContacts__mdt> metaDatas = Test.isRunningTest() && accountDomain!='test2.com'? new List<FEP_AllowedLoginsWithoutContacts__mdt>{new FEP_AllowedLoginsWithoutContacts__mdt(DeveloperName ='Test',FEP_EmailDomain__c='test.com', FEP_AccessCode__c ='123') }: [SELECT FEP_EmailDomain__c,FEP_AccessCode__c FROM FEP_AllowedLoginsWithoutContacts__mdt WHERE FEP_EmailDomain__c =:accountDomain];
            if(!metaDatas.isEmpty()){
               List<Account> accnts = [SELECT ID,Name,FEP_Timezone__c FROM Account WHERE Access_Code__c =:metaDatas[0].FEP_AccessCode__c AND Type = 'Active'];
                if(!accnts.isEmpty()){
                    Contact contToCreate = new Contact(FirstName = firstName, LastName = lastName,AccountId=accnts[0].Id,  Phone=phone,MobilePhone = phone,Email =email,Company_Provided_Email__c= email,Active__c= True);
                    String recordTypeId= Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('FEP_StandardContact').getRecordTypeId();
                    contToCreate.RecordTypeId = recordTypeId;
                    insert contToCreate;
                    Id profileId;
                    List<Profile> communityProfile =[SELECT Id,Name FROM Profile WHERE Name =:System.label.fep_CustomerPortalPlusProfileId];
                    profileId = !communityProfile.isEmpty()?communityProfile[0].Id:null;
                    List<Auth.VerificationMethod> methods = new List<Auth.VerificationMethod>();
                    methods.add(identifier);
                    Map<SObjectField, String> registrationAttributes =  new Map<SObjectField, String> ();
                    Schema.DescribeFieldResult firstNameFieldResult = User.FirstName.getDescribe();
                    Schema.sObjectField firstNameField = firstNameFieldResult.getSObjectField();
                    registrationAttributes.put(firstNameField,firstName);
                    Schema.DescribeFieldResult lastNameFieldResult = User.LastName.getDescribe();
                    Schema.sObjectField lastNameField = lastNameFieldResult.getSObjectField();
                    registrationAttributes.put(lastNameField,lastName);
                    Schema.DescribeFieldResult mobileFieldResult = User.MobilePhone.getDescribe();
                    Schema.sObjectField mobileField = mobileFieldResult.getSObjectField();
                    registrationAttributes.put(mobileField,phone);
                    Schema.DescribeFieldResult emailFieldResult = User.Email.getDescribe();
                    Schema.sObjectField emailField = emailFieldResult.getSObjectField();
                    registrationAttributes.put(emailField,email);
                    Schema.DescribeFieldResult contactFieldResult = User.ContactId.getDescribe();
                    Schema.sObjectField contactField = contactFieldResult.getSObjectField();
                    registrationAttributes.put(contactField,contToCreate.id);
                    Schema.DescribeFieldResult timeZoneFieldResult = User.TimeZoneSidKey.getDescribe();
                    Schema.sObjectField timeZoneField = timeZoneFieldResult.getSObjectField();
                    registrationAttributes.put(timeZoneField,accnts[0].FEP_Timezone__c);
                    selfRegisterResult.url= AutocreatedConfigSelfReg1707895433051.createSelfRegisterUser(accnts[0].Id,profileId,registrationAttributes,null,identifier);
                    selfRegisterResult.method = veriMethod;
                    selfRegisterResult.operation = 'SelfRegister';
                    selfRegisterResult.isSuccess = True;
                    return JSON.serialize(selfRegisterResult);
                }
                else{
                    selfRegisterResult.url= null;
                    selfRegisterResult.method = veriMethod;
                    selfRegisterResult.operation = 'SelfRegister';
                    selfRegisterResult.isSuccess = False;
                    return JSON.serialize(selfRegisterResult);
                }
            }
            else if(isGeneral){
                List<Account> accnts = [SELECT ID,Name,FEP_Timezone__c FROM Account WHERE Name ='General Account' AND Type = 'Active'];
                if(!accnts.isEmpty()){
                    Contact contToCreate = new Contact(FirstName = firstName, LastName = lastName,AccountId=accnts[0].Id,  Phone=phone,MobilePhone = phone,Email =email,Company_Provided_Email__c= email,Active__c = True,Company__c =companyName);
                    String recordTypeId= Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('FEP_StandardContact').getRecordTypeId();
                    contToCreate.RecordTypeId = recordTypeId;
                    insert contToCreate;
                    Id profileId;
                    List<Profile> communityProfile =[SELECT Id,Name FROM Profile WHERE Name =:System.label.fep_CustomerPortalPlusProfileId];
                    profileId = !communityProfile.isEmpty()?communityProfile[0].Id:null;
                    List<Auth.VerificationMethod> methods = new List<Auth.VerificationMethod>();
                    methods.add(identifier);
                    Map<SObjectField, String> registrationAttributes =  new Map<SObjectField, String> ();
                    Schema.DescribeFieldResult firstNameFieldResult = User.FirstName.getDescribe();
                    Schema.sObjectField firstNameField = firstNameFieldResult.getSObjectField();
                    registrationAttributes.put(firstNameField,firstName);
                    Schema.DescribeFieldResult lastNameFieldResult = User.LastName.getDescribe();
                    Schema.sObjectField lastNameField = lastNameFieldResult.getSObjectField();
                    registrationAttributes.put(lastNameField,lastName);
                    Schema.DescribeFieldResult mobileFieldResult = User.MobilePhone.getDescribe();
                    Schema.sObjectField mobileField = mobileFieldResult.getSObjectField();
                    registrationAttributes.put(mobileField,phone);
                    Schema.DescribeFieldResult emailFieldResult = User.Email.getDescribe();
                    Schema.sObjectField emailField = emailFieldResult.getSObjectField();
                    registrationAttributes.put(emailField,email);
                    Schema.DescribeFieldResult contactFieldResult = User.ContactId.getDescribe();
                    Schema.sObjectField contactField = contactFieldResult.getSObjectField();
                    registrationAttributes.put(contactField,contToCreate.id);
                    Schema.DescribeFieldResult timeZoneFieldResult = User.TimeZoneSidKey.getDescribe();
                    Schema.sObjectField timeZoneField = timeZoneFieldResult.getSObjectField();
                    registrationAttributes.put(timeZoneField,accnts[0].FEP_Timezone__c);
                    selfRegisterResult.url= AutocreatedConfigSelfReg1707895433051.createSelfRegisterUser(accnts[0].Id,profileId,registrationAttributes,null,identifier);
                    selfRegisterResult.method = veriMethod;
                    selfRegisterResult.operation = 'SelfRegister';
                    selfRegisterResult.isSuccess = True;
                    return JSON.serialize(selfRegisterResult);
                }
            }
            else{
                    selfRegisterResult.url= null;
                    selfRegisterResult.method = veriMethod;
                    selfRegisterResult.operation = 'SelfRegister';
                    selfRegisterResult.isSuccess = False;
                    return JSON.serialize(selfRegisterResult);
            }
        } 
        return JSON.serialize(selfRegisterResult);
    }

    /*------------------------------------------------------------
    Author:        Saurabh Kumar
    Company:       Salesforce
    Description:   Function to Check if verification code entered by registering 
                   user is correct
    Inputs:        method- Method of Authentication Email/SMS
                   Identifier - Unique Salesforce generated Salesforce code
                   code- code entered by user for verification
                   startUrl - URL to which user is to redirected

    Returns:       String- URL to which user is redirected to after authentication
               
    History
   13/02/2024      Saurabh Kumar    New Function Created for PR972315-28
    ------------------------------------------------------------*/
    @AuraEnabled
    public static string verifySelfRegistration(String method,String identifier,String code,String startUrl){
        Auth.VerificationMethod veriMethod = method=='mobile'?Auth.VerificationMethod.SMS:Auth.VerificationMethod.EMAIL;
        Auth.VerificationResult res = System.UserManagement.verifySelfRegistration(veriMethod, identifier,code , startUrl);
        system.debug(res);
        if(res.success){
        return res.redirect.getUrl();
        }
        else{
            throw new AuraHandledException('Error logging in please enter valid verification code');
        }
    }

    public class registerResult{
        @AuraEnabled
        public String method;
        @AuraEnabled
        public string url;
        @AuraEnabled
        public string operation;
        @AuraEnabled
        public Boolean isSuccess;

    }

}