/**
 * HttpFramework class which allows you to connect to http services. See https://sunrun.jira.com/wiki/spaces/SunRun/pages/2761031811/Http+Client+Framework for more info.
 */
@SuppressWarnings('PMD.CognitiveComplexity,PMD.ExcessiveParameterList')
public class HttpClient {
  public static final HttpClient OBJ = new HttpClient();
  private Http http = new Http();
  private HttpDto.Options options;
  private static List<String> appLogDisabledUrls = Sf.settings.getList('HttpClientAppLogsDisabledUrls', new List<String>());
  private static Boolean appLogDisabled = Sf.settings.isTrue('HttpClientAppLogsDisabled', false);

  public HttpClient() {
    this(null);
  }

  public HttpClient(HttpDto.Options options) {
    this.options = options == null ? new HttpDto.Options() : options;
  }

  public String get(String url) {
    return get(url, null);
  }

  public String get(String url, Map<String, Object> params) {
    return get(url, params, null);
  }

  public String get(String url, Map<String, Object> params, Map<String, Object> headers) {
    return sendInternal('GET', url, params, headers, null);
  }

  public String post(String url, Object body) {
    return post(url, null, body);
  }

  public String post(String url, Map<String, Object> headers, Object body) {
    return sendInternal('POST', url, null, headers, body);
  }

  public String put(String url, Object body) {
    return put(url, null, body);
  }

  public String put(String url, Map<String, Object> headers, Object body) {
    return sendInternal('PUT', url, null, headers, body);
  }

  public String patch(String url, Object body) {
    return patch(url, null, body);
  }

  public String patch(String url, Map<String, Object> headers, Object body) {
    return sendInternal('PATCH', url, null, headers, body);
  }

  public String httpDelete(String url) {
    return httpDelete(url, null, null);
  }

  public String httpDelete(String url, Map<String, Object> params) {
    return httpDelete(url, params, null);
  }

  public String httpDelete(String url, Map<String, Object> params, Map<String, Object> headers) {
    return sendInternal('DELETE', url, params, headers, null);
  }

  private String sendInternal(String method, String url, Map<String, Object> params, Map<String, Object> headers, Object body) {
    HttpDto.Response resp = send(new HttpDto.Request(method, url, params, headers, body));
    return String.valueOf(resp.body);
  }

  public HttpDto.Response send(HttpDto.Request req) {
    HttpRequest hreq = createHttpReq(req);
    System.debug('Sending http request: ' + hreq.getMethod() + ' ' + hreq.getEndpoint() + ' ' + hreq.getBody());

    Datetime st = Ut.now();

    HttpDto.Response resp = null;
    try {
      HttpResponse hresp = Test.isRunningTest() && Ut.getTestParam('HttpMock') != null
        ? ((HttpCalloutMock) Ut.getTestParam('HttpMock')).respond(hreq)
        : http.send(hreq);

      resp = createHttpResp(req, hresp, st, null);
    } catch (Exception e) {
      resp = createHttpResp(req, null, st, e);
    }

    System.debug('Received http response in ' + resp.elapsedTime + 'ms: ' + resp.statusCode + ' ' + resp.body);

    logToAppLog(req, resp);

    if (isError(resp)) {
      throw new HttpDto.HttpException(req, resp);
    }

    return resp;
  }

  private void logToAppLog(HttpDto.Request req, HttpDto.Response resp) {
    if (appLogDisabled) {
      System.debug('HttpClient AppLogging is disabled hence not logging');
      return;
    }

    for (String url : appLogDisabledUrls) {
      if (req.finalUrl.startsWithIgnoreCase(url)) {
        System.debug('HttpClient AppLogging is disabled for url hence not logging. Url [' + url + ']');
        appLogDisabled = true;
        break;
      }
    }

    if (!appLogDisabled) {
      resp.request = null; // we will set it back

      // We must save async so that callouts are not impacted
      App_Log_Event__e event = AppLogger.logAsync(createAppLog(req, resp));

      if (Test.isRunningTest()) {
        List<App_Log_Event__e> events = (List<App_Log_Event__e>) Ut.initList((List<App_Log_Event__e>) Ut.getTestParam('HttpClientTestAppLogEvents'));
        events.add(event);
        Ut.setTestParam('HttpClientTestAppLogEvents', events);
      }

      resp.request = req;
    }
  }

  private App_Log__c createAppLog(HttpDto.Request req, HttpDto.Response resp) {
    String action = Ut.firstNotBlank(req.action, options.action);
    if (String.isBlank(action)) {
      action = req.method + ' ' + req.finalUrl.substringBefore('?');
    }

    // We cannot serialize System.CalloutException as it fails with error Apex Type unsupported in JSON: System.CalloutException
    // To overcome that we will remove the Error, use the stacktrace field and revert back to original value.
    Exception e = resp.error;
    if (e != null) {
      resp.error = null;
      resp.stacktrace = Ut.getStackTrace(e);
    }

    App_Log__c appLog = new App_Log__c(
      Module__c = Ut.firstNotBlank(options.module, 'HttpClient'),
      Action__c = action,
      Record_id__c = req.recordId,
      Type__c = isError(resp) ? UtDto.LOG_ERROR : UtDto.LOG_DEBUG,
      Message__c = isError(resp) ? resp.body : 'Completed successfully',
      Details__c = isError(resp) ? resp.body : null,
      Request__c = Json.serialize(req),
      Response__c = Json.serialize(resp),
      Run_Url__c = req.finalUrl,
      Start_Time__c = resp.startTime,
      End_Time__c = resp.endTime,
      Value1__c = Ut.firstNotBlank(req.value1, options.value1),
      Value2__c = Ut.firstNotBlank(req.value2, options.value2),
      Value3__c = Ut.firstNotBlank(req.value3, options.value3),
      Value4__c = Ut.firstNotBlank(req.value4, options.value4),
      Value5__c = Ut.firstNotBlank(req.value5, options.value5)
    );

    resp.stacktrace = null;
    resp.error = e;

    return appLog;
  }

  private Boolean isError(HttpDto.Response resp) {
    return resp.statusCode >= 300;
  }

  private HttpDto.Response createHttpResp(HttpDto.Request req, HttpResponse hresp, DateTime st, Exception e) {
    HttpDto.Response resp = new HttpDto.Response();
    resp.request = req;

    if (hresp != null) {
      resp.statusCode = hresp.getStatusCode();
      for (String name : hresp.getHeaderKeys()) {
        resp.headers.put(name, hresp.getHeader(name));
      }
      resp.body = hresp.getBody();
    } else {
      resp.statusCode = 500;
      resp.body = Json.serialize(Ut.mapOf('exception', Ut.getStackTrace(e)));
    }

    resp.error = e;
    resp.startTime = st;
    resp.endTime = Ut.now();
    resp.elapsedTime = (Integer) (resp.endTime.getTime() - st.getTime());

    return resp;
  }

  @TestVisible
  private HttpRequest createHttpReq(HttpDto.Request req) {
    HttpRequest hreq = new HttpRequest();

    req.method = Ut.firstNotBlank(req.method, 'GET').toUpperCase();
    hreq.setMethod(req.method);

    req.finalUrl = getEndpoint(req);
    hreq.setEndpoint(req.finalUrl);

    Map<String, Object> headers = new Map<String, Object>();
    headers.putAll(options.headers);

    if (req.headers != null) {
      headers.putAll(req.headers);
    }

    if (!headers.isEmpty()) {
      for (String name : Ut.sort(headers.keySet())) {
        hreq.setHeader(name, headers.get(name) == null ? '' : String.valueOf(headers.get(name)));
      }
    }

    if (req.body != null) {
      boolean hasContentLength = headers.containsKey(HttpDto.Header_ContentLength);
      if (req.body instanceof Blob) {
        hreq.setBodyAsBlob((Blob) req.body);
        if (!hasContentLength) {
          hreq.setHeader(Httpdto.Header_ContentLength, '' + ((Blob) req.body).size());
        }
      } else {
        String body = req.body instanceof String ? (String) req.body : JSON.serialize(req.body);
        hreq.setBody(body);
        if (!hasContentLength) {
          hreq.setHeader(HttpDto.Header_ContentLength, '' + body.length());
        }
      }
    }

    Integer timeout = req.timeout == null ? options.timeout : req.timeout;
    if (timeout == null || timeout <= 0) {
      timeout = 120 * 1000; // 120s is max
    }

    req.finalTimeout = timeout;
    hreq.setTimeout(req.finalTimeout);

    return hreq;
  }

  private String getEndpoint(HttpDto.Request req) {
    String finalUrl = (req.url.startsWithIgnoreCase('http') || req.url.startsWithIgnoreCase('callout:')) ? '' : Ut.firstNotBlank(options.baseUrl, '');
    finalUrl += req.url;

    Map<String, Object> paramsMap = new Map<String, Object>();
    if (options.params != null && !options.params.isEmpty()) {
      paramsMap.putAll(options.params);
    }

    if (req.params != null) {
      paramsMap.putAll(req.params);
    }

    if (!paramsMap.isEmpty()) {
      List<String> params = new List<String>();
      for (String name : Ut.sort(paramsMap.keySet())) {
        params.add(name + '=' + (paramsMap.get(name) == null ? '' : Ut.urlEncode(String.valueOf(paramsMap.get(name)))));
      }

      String paramsString = Ut.join(params, '&', true);
      finalUrl += finalUrl.indexOf('?') >= 0 ? ('&' + paramsString) : ('?' + paramsString);
    }

    return finalUrl;
  }
}
