/*------------------------------------------------------------
Author: Saurabh Kumar
Company: Salesforce
Description: Enqueable Class to request access token and send request 
to either MS teams API
Inputs: 
Test Class: ServiceAppointmentTriggerHandler_Test
History
<04/03/2024>  <Saurabh Kumar>     <Initial Creation>
------------------------------------------------------------*/
public without sharing class ScheduleMeetingJob implements Queueable, Database.AllowsCallouts {
    private Set<Id> reqIds;
    private String operation;
    private String accessToken;
    private String tenantId ;
    private String clientId;
    private String clientSecret;
    private String scope;
    private String authBaseURL;
    private String grantType;
    private String graphBaseURL;
    private String serviceAccount;
    
    /*------------------------------------------------------------
Author: Saurabh Kumar
Company: Salesforce
Description: Constructor to initialize variables
Inputs: 
Returns: 
History
<04/03/2024>     <Saurabh Kumar>     <Initial Creation>
------------------------------------------------------------*/
    
    public ScheduleMeetingJob(Set<Id> sAIds,String operation) {
        this.reqIds = sAIds;
        this.operation = operation;
        FEP_SFMS365TeamsIntegrationConfig__mdt config = FEP_SFMS365TeamsIntegrationConfig__mdt.getInstance('FEP_APIConfig');          
        this.tenantId = config.FEP_TenetID__c;
        this.clientId = config.FEP_ClientID__c;
        this.clientSecret = config.FEP_ClientSecret__c;
        this.scope= config.FEP_Scope__c;
        this.authBaseURL = config.FEP_AuthBaseURL__c;
        this.grantType = config.FEP_GrantType__c;
        this.graphBaseURL = config.FEP_GraphAPIBaseURL__c;
        this.serviceAccount = config.FEP_ServiceAccount__c;
        
    }
    
    
    /*------------------------------------------------------------
Author: Saurabh Kumar
Company: Salesforce
Description: Interface method to perform callout. This first checks
whether a eligible token is present otherwise makes callout to get new token.
This method then enques another queueable job to create teams meeting.
Inputs: 
Returns: 
History
<04/03/2024>     <Saurabh Kumar>     <Initial Creation>
------------------------------------------------------------*/
    
    public void execute(QueueableContext ctx) {
        try {
            List<FEP_SFMSTeamsAccessTokenDetails__c> accessTokens = [SELECT Id,Name, FEP_AccessTokenGenerationTime__c,FEP_AccessToken__c FROM FEP_SFMSTeamsAccessTokenDetails__c Order by createddate DESC LIMIT 1];
            if(accessTokens.isEmpty() ||  (DateTime.now().getTime()-accessTokens[0].FEP_AccessTokenGenerationTime__c.getTime())/(1000*60)>55.0){        
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndPoint(this.authBaseURL+this.tenantId+'/oauth2/v2.0/token');
                request.setMethod('POST');
                request.setBody('grant_type='+this.grantType+'&client_id='+this.clientId+'&client_secret='+this.clientSecret+'&scope='+this.scope);
                request.setHeader('Content-Type','application/x-www-form-urlencoded');
                HttpResponse response;
                if(!Test.isRunningTest()){  
                    response = http.send(request);
                }else{
                    response.setStatusCode(200);
                    response.setStatus('OK');
                    response.setBody('{"access_token":"ABCD3456789AKKKfghjkl9879879879879"}');
                }
                
                if(response.getStatusCode() ==200){
                    Map<String,Object> resultBody = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                    this.accessToken = String.valueOf(resultBody.get('access_token'));
                    FEP_SFMSTeamsAccessTokenDetails__c tokenData  = new FEP_SFMSTeamsAccessTokenDetails__c(FEP_AccessToken__c =String.valueOf(resultBody.get('access_token')),FEP_AccessTokenGenerationTime__c = DateTime.now());
                    insert tokenData;          
                }
                
            }
            if(this.operation =='Insert'){
                if(!Test.isRunningTest()){
                    System.enqueueJob(new FEP_CreateUpdateMeetingJob(this.reqIds,'Insert'));
                }
            }
            if(this.operation=='Update'){
                if(!Test.isRunningTest()){
                    System.enqueueJob(new FEP_CreateUpdateMeetingJob(this.reqIds,'Update'));
                }
            }
        } catch (Exception e) {
            system.debug('Exception>>'+e.getMessage()+e.getStackTraceString());
        }
    }
    
    
}