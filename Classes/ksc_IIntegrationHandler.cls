/*********************************************************
*Class        :  ksc_IIntegrationHandler
*Author       :  Shreya Mathur
*Description  : Interface for the Parser classes of the Integration Callout Framework 
*********************************************************/
public interface ksc_IIntegrationHandler {
 
    ksc_IntegrationWrapperClass generateParsedResponse(ksc_IntegrationWrapperClass objWrapperClass);
    ksc_IntegrationWrapperClass generateRequestBody(ksc_IntegrationWrapperClass objWrapperClass);
}