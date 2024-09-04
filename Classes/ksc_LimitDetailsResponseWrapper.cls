public with sharing class ksc_LimitDetailsResponseWrapper {
    public ksc_LimitDetailsResponseWrapper() {

        this.code = 0;
        this.status =ksc_Constants.STRING_BLANK;
        this.transactionId = ksc_Constants.STRING_BLANK;
        this.correlationId = ksc_Constants.STRING_BLANK;
        this.error = null;
        this.data = null;

    }
    public Integer code;
	public String status;
	public String transactionId;
	public String correlationId;
	public Object error;
	public Data data;

	public class Data {
		public String requestUUId;
		public String serviceRequestId;
		public String serviceRequestVersion;
		public String ChannelId;
		public String bankId;
		public String messageDateTime;
		public String messageTimeZone;
		public String UBUSTxnId;
		public String UBUSTxnStatus;
		public String hostTxnId;
		public String hostTxnStatus;
		public String hostParentTxnId;
		public String hostParentTxnStatus;
		public List<LimitInfo> limitInfo;
	}

	public class LimitInfo {
		public String limitId;
		public String limitDesc;
		public String amt;
		public String liability;
	}

}