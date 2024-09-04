@IsTest
private class SunrunAwsServiceTest {
  private static SunrunAwsServiceSubClass service = new SunrunAwsServiceSubClass();

  @IsTest
  static void testGet() {
    setupData();
    HttpMock mock = new HttpMock(200, '{"message" :"test message"}');

    TestResp resp = (TestResp) service.httpGet('/test', new Map<String, String>{ 'firstName' => 'John' }, TestResp.class);
    System.assertEquals('test message', resp.message);

    HttpRequest req = mock.calloutRequests.get(0).request;
    System.assertEquals('abc123', req.getHeader('x-api-key'));
    System.assertEquals('https://example.com/test?firstName=John', req.getEndpoint());
    System.assertEquals('GET', req.getMethod());
  }

  @IsTest
  static void testPost() {
    setupData();
    HttpMock mock = new HttpMock(200, '{"message" :"test message"}');

    TestResp resp = (TestResp) service.httpPost('/test', new Map<String, String>{ 'firstName' => 'John' }, TestResp.class);
    System.assertEquals('test message', resp.message);

    HttpRequest req = mock.calloutRequests.get(0).request;
    System.assertEquals('abc123', req.getHeader('x-api-key'));
    System.assertEquals('https://example.com/test', req.getEndpoint());

    mock.calloutRequests.clear();
    resp = (TestResp) service.httpPost('/test', '{"foo":"bar"}', TestResp.class);
    req = mock.calloutRequests.get(0).request;
    System.assertEquals('{"foo":"bar"}', req.getBody());
  }

  private static void setupData() {
    Sf.settings.setForTx('ServiceUrl', 'https://example.com');
    Sf.settings.setForTx('ServiceKey', 'abc123');
  }

  class SunrunAwsServiceSubClass extends SunrunAwsService {
    public SunrunAwsServiceSubClass() {
      super('ServiceUrl', 'ServiceKey');
    }

    public Object httpPost(String path, Object req, Type respClass) {
      return super.post(path, req, respClass);
    }

    public Object httpGet(String path, Map<String, String> query, Type respClass) {
      return super.get(path, query, respClass);
    }
  }

  class TestResp {
    public String message;
  }
}
