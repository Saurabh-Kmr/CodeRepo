public with sharing class ksc_StatementDownloadResponseWrapper {
    public ksc_StatementDownloadResponseWrapper() {
        this.code = 0;
        this.status =ksc_Constants.STRING_BLANK;
        this.transactionId = ksc_Constants.STRING_BLANK;
        this.correlationId = ksc_Constants.STRING_BLANK;
        this.error = null;
        this.data = null;
        
    }

	public class StmtDownld {
		public String referenceId;
		public String dwnldStatus;
		public ReqData reqData;
	}

	public Integer code;
	public String status;
	public String transactionId;
	public String correlationId;
	public Object error;
	public Data data;

	public class ReqData {
		public String byteStream;
	}

	public class Data {
		public String srcAppCd;
		public String requestId;
		public StmtDownld stmtDownld;
	}

}