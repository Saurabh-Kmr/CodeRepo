@IsTest
public class HttpClientTest {
  @IsTest
  static void testCreateReq() {
    HttpDto.Options options = new HttpDto.Options();
    HttpClient client = new HttpClient(options);
    HttpDto.Request req = new HttpDto.Request();

    // Endpoint
    req.url = 'https://api.sunrun.com';
    Assert.areEqual('https://api.sunrun.com', client.createHttpReq(req).getEndPoint());

    req.params.put('foo', 'bar & alice');
    Assert.areEqual('https://api.sunrun.com?foo=bar+%26+alice', client.createHttpReq(req).getEndPoint());

    req.params.put('bar', 'foo');
    Assert.areEqual('https://api.sunrun.com?bar=foo&foo=bar+%26+alice', client.createHttpReq(req).getEndPoint());

    options.params.put('bar', 'fooOld'); //req level variable should take precedence
    Assert.areEqual('https://api.sunrun.com?bar=foo&foo=bar+%26+alice', client.createHttpReq(req).getEndPoint());

    options.params.put('alice', 'bob'); // New options level params is added to url
    Assert.areEqual('https://api.sunrun.com?alice=bob&bar=foo&foo=bar+%26+alice', client.createHttpReq(req).getEndPoint());

    options.baseUrl = 'https://api2.sunrun.com'; // Since req is absolute url, then base url is not prefixed
    Assert.areEqual('https://api.sunrun.com?alice=bob&bar=foo&foo=bar+%26+alice', client.createHttpReq(req).getEndPoint());

    req.url = 'callout:sunrunprd'; // Since req is absolute url, then base url is not prefixed
    Assert.areEqual('callout:sunrunprd?alice=bob&bar=foo&foo=bar+%26+alice', client.createHttpReq(req).getEndPoint());

    req.url = '/path/get-something'; // Base url is added since it is not abolute url
    Assert.areEqual('https://api2.sunrun.com/path/get-something?alice=bob&bar=foo&foo=bar+%26+alice', client.createHttpReq(req).getEndPoint());

    // Headers
    Assert.areEqual(HttpDto.Mime_Json, client.createHttpReq(req).getHeader(HttpDto.Header_ContentType)); // by default application/json is set as content type

    options.headers.put(HttpDto.Header_ContentType, HttpDto.Mime_Xml);
    Assert.areEqual(HttpDto.Mime_Xml, client.createHttpReq(req).getHeader(HttpDto.Header_ContentType));

    req.headers.put(HttpDto.Header_ContentType, HttpDto.Mime_Json);
    Assert.areEqual(HttpDto.Mime_Json, client.createHttpReq(req).getHeader(HttpDto.Header_ContentType));

    req.headers.put(HttpDto.Header_Authorization, 'Bearer 123');
    Assert.areEqual('Bearer 123', client.createHttpReq(req).getHeader(HttpDto.Header_Authorization));

    // Body
    Assert.areEqual('', client.createHttpReq(req).getBody()); // by default it is empty

    req.body = '{"foo":"bar"}';
    Assert.areEqual('{"foo":"bar"}', client.createHttpReq(req).getBody());

    req.body = Ut.mapOf('foo', 'bar');
    Assert.areEqual('{"foo":"bar"}', client.createHttpReq(req).getBody()); // Serializes the body if it is not string
    Assert.areEqual('13', client.createHttpReq(req).getHeader(HttpDto.Header_ContentLength));

    req.body = Blob.valueOf('123');
    Assert.areEqual(Blob.valueOf('123'), client.createHttpReq(req).getBodyAsBlob());
    Assert.areEqual('3', client.createHttpReq(req).getHeader(HttpDto.Header_ContentLength));

    // Timeout
    client.createHttpReq(req);
    Assert.areEqual(120 * 1000, req.finalTimeout); // default 120s

    options.timeout = 10 * 1000;
    client.createHttpReq(req);
    Assert.areEqual(10 * 1000, req.finalTimeout);

    req.timeout = 30 * 1000;
    client.createHttpReq(req);
    Assert.areEqual(30 * 1000, req.finalTimeout);
  }

  @IsTest
  public static void testCalls() {
    Test.startTest();

    HttpMock mock = new HttpMock();
    mock.ifUrlStartsWithReturn('https://accounts.google.com', '{"message": "ok"}');

    String resp = HttpClient.OBJ.get('https://accounts.google.com');
    System.assertEquals('{"message": "ok"}', resp);

    mock.calloutRequests.clear();
    resp = HttpClient.OBJ.get('https://accounts.google.com', new Map<String, Object>{ 'param1' => 'value1', 'param2' => 'value2' });
    System.assertEquals('{"message": "ok"}', resp);
    System.assertEquals('https://accounts.google.com?param1=value1&param2=value2', mock.calloutRequests.get(0).request.getEndpoint());
    System.assertEquals('GET', mock.calloutRequests.get(0).request.getMethod());

    mock.calloutRequests.clear();
    resp = HttpClient.OBJ.put('https://accounts.google.com', new Map<String, Object>{ 'param1' => 'value1', 'param2' => 'value2' });
    System.assertEquals('{"message": "ok"}', resp);
    System.assertEquals('https://accounts.google.com', mock.calloutRequests.get(0).request.getEndpoint());
    System.assertEquals('{"param2":"value2","param1":"value1"}', mock.calloutRequests.get(0).request.getBody());
    System.assertEquals('PUT', mock.calloutRequests.get(0).request.getMethod());

    mock.calloutRequests.clear();
    resp = HttpClient.OBJ.patch('https://accounts.google.com', new Map<String, Object>{ 'param1' => 'value1', 'param2' => 'value2' });
    System.assertEquals('{"message": "ok"}', resp);
    System.assertEquals('https://accounts.google.com', mock.calloutRequests.get(0).request.getEndpoint());
    System.assertEquals('{"param2":"value2","param1":"value1"}', mock.calloutRequests.get(0).request.getBody());
    System.assertEquals('PATCH', mock.calloutRequests.get(0).request.getMethod());

    mock.calloutRequests.clear();
    resp = HttpClient.OBJ.httpDelete('https://accounts.google.com');
    System.assertEquals('{"message": "ok"}', resp);
    System.assertEquals('https://accounts.google.com', mock.calloutRequests.get(0).request.getEndpoint());
    System.assertEquals('DELETE', mock.calloutRequests.get(0).request.getMethod());

    mock.calloutRequests.clear();
    resp = HttpClient.OBJ.post(
      'https://accounts.google.com',
      new Map<String, Object>{ 'param1' => 'value1', 'param2' => 'value2' },
      '{"input": "abc"}'
    );
    System.assertEquals('{"message": "ok"}', resp);
    System.assertEquals('https://accounts.google.com', mock.calloutRequests.get(0).request.getEndpoint());
    System.assertEquals('value1', mock.calloutRequests.get(0).request.getHeader('param1'));
    System.assertEquals('value2', mock.calloutRequests.get(0).request.getHeader('param2'));
    System.assertEquals('{"input": "abc"}', mock.calloutRequests.get(0).request.getBody());
    System.assertEquals('POST', mock.calloutRequests.get(0).request.getMethod());

    mock = new HttpMock();
    mock.addConfig(new HttpMock.UrlContainsMatch('https://accounts.google.com'), new HttpMock.MockResponse(401, '{"message":"unauthorized"}'));
    try {
      HttpClient.OBJ.post('https://accounts.google.com', null);
      System.assert(false, 'Expected exception');
    } catch (HttpDto.HttpException e) {
      // expected
    }

    Test.stopTest(); // This will deliver log events
    Assert.areEqual(false, ((List<App_Log_Event__e>) Ut.getTestParam('HttpClientTestAppLogEvents')).isEmpty());
  }
}
