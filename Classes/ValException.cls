public class ValException extends Exception {
  public Integer statusCode = 400;
  public String errorCode = 'InvalidRequest';

  public ValException(String errorCode, String message) {
    this(400, errorCode, message);
  }

  public ValException(Integer statusCode, String errorCode, String message) {
    this.errorCode = errorCode;
    this.statusCode = statusCode;
    setMessage(message);
  }
}
