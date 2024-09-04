@SuppressWarnings('PMD.ExcessiveParameterList,PMD.EmptyStatementBlock.PMD.FieldNamingConventions')
public class HttpDto {
  public static final String Header_ContentType = 'Content-Type';
  public static final String Header_ContentLength = 'Content-Length';
  public static final String Header_Authorization = 'Authorization';

  public static final String Mime_Json = 'application/json';
  public static final String Mime_Xml = 'application/xml';

  public class Options {
    public String baseUrl;
    public Map<String, Object> params = new Map<String, Object>();
    public Map<String, Object> headers = new Map<String, Object>();
    /**
     * Default Read timeout in milliseconds
     */
    public Integer timeout;
    public String module;
    public String action;
    public String value1;
    public String value2;
    public String value3;
    public String value4;
    public String value5;

    public Options() {
      this(null);
    }

    public Options(String baseUrl) {
      this(baseUrl, null);
    }

    public Options(String baseUrl, Map<String, Object> headers) {
      this.baseUrl = baseUrl;
      this.headers = headers == null ? new Map<String, Object>() : headers;
      if (!this.headers.containsKey(Header_ContentType)) {
        this.headers.put(Header_ContentType, Mime_Json);
      }
    }
  }

  public class Request {
    public String method;
    public String url;
    public Map<String, Object> params;
    public Map<String, Object> headers;
    public Object body;

    /**
     * Read timeout in milliseconds
     */
    public Integer timeout;
    public Id recordId;
    public Id action;
    public String value1;
    public String value2;
    public String value3;
    public String value4;
    public String value5;

    public Integer finalTimeout;
    public String finalUrl;

    public Request() {
      this(null, null, null);
    }

    public Request(String method, String url) {
      this(method, url, null, null, null);
    }

    public Request(String method, String url, Map<String, Object> params) {
      this(method, url, params, null, null);
    }

    public Request(String method, String url, Map<String, Object> params, Map<String, Object> headers, Object body) {
      this.method = method;
      this.url = Ut.emptyIfNull(url);
      this.params = params == null ? new Map<String, Object>() : params;
      this.headers = headers == null ? new Map<String, Object>() : headers;
      this.body = body;
    }
  }

  public class Response {
    public Request request;
    public Integer statusCode;
    public Map<String, String> headers = new Map<String, String>();
    public String body;
    public DateTime startTime;
    public DateTime endTime;
    public Integer elapsedTime;
    public Exception error;
    public String stacktrace;
  }

  public class HttpException extends Exception {
    public HttpDto.Request request;
    public HttpDto.Response response;

    public HttpException(HttpDto.Request req, HttpDto.Response resp) {
      setMessage(
        'Http error for Request [' + req.method + ' ' + req.finalUrl + '] Response [statusCode=' + resp.statusCode + ', body=' + resp.body + ']'
      );
      request = req;
      response = resp;
    }
  }
}
