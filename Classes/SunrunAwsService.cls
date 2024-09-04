public virtual class SunrunAwsService {
  private static HttpClient client = new HttpClient();
  private String serviceUrl;
  private Map<String, String> serviceHeaders;
  private String urlSettingsName;
  private String apiKeySettingsName;

  protected SunrunAwsService(String urlSettingsName, String apiKeySettingsName) {
    this.urlSettingsName = urlSettingsName;
    this.apiKeySettingsName = apiKeySettingsName;
  }

  protected Object post(String path, Object req, Type respClass) {
    String responseBody = postToString(path, req);
    return JSON.deserialize(responseBody, respClass);
  }

  protected String postToString(String path, Object req) {
    String requestBody = req instanceof String ? (String) req : JSON.serialize(req);
    return client.post(getServiceUrl() + Ut.firstNotBlank(path, ''), getServiceHeaders(), requestBody);
  }

  protected Object postLambdaApi(String path, Object req, Type respClass) {
    String response = postToString(path, req);
    if (response.containsIgnoreCase('errorType') && response.containsIgnoreCase('errorMessage')) {
      throw new ValException('Error processing lambda api [' + getServiceUrl() + ']. Error [' + response + ']');
    }
    return JSON.deserialize(response, respClass);
  }

  protected Object get(String path, Map<String, String> query, Type respClass) {
    String responseBody = client.get(getServiceUrl() + Ut.firstNotBlank(path, ''), query, getServiceHeaders());
    return JSON.deserialize(responseBody, respClass);
  }

  protected String getServiceUrl() {
    if (serviceUrl == null) {
      serviceUrl = Sf.settings.getString(urlSettingsName);
    }

    return serviceUrl;
  }

  protected Map<String, String> getServiceHeaders() {
    if (serviceHeaders == null) {
      serviceHeaders = new Map<String, String>();
      serviceHeaders.put('x-api-key', Sf.settings.getString(apiKeySettingsName));
      serviceHeaders.put('Content-Type', 'application/json');
    }

    return serviceHeaders;
  }

  class LambdaApiError {
    public String errorType;
    public String errorMessage;
  }
}
