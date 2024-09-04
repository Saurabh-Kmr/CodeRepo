/*********************************************************
*Name           :   ksc_LimitInquiryWrapper
*Author         :   Chaynnitt Agarwal
*Since          :   
*Description    :   Wrapper class for Limit Details Inquiry (Limit ID) integration API 
*History
Name                Date                  Change Description
*********************************************************/

public with sharing class ksc_LimitInquiryWrapper {
    
    public ksc_LimitInquiryWrapper(){
        this.code = 0;
        this.status = ksc_Constants.STRING_BLANK;
        this.transactionId = ksc_Constants.STRING_BLANK;
	    this.correlationId = ksc_Constants.STRING_BLANK;
	    this.error = null;
	    this.data = new Data();
    }

    public Integer code;
	public String status;
	public String transactionId;
	public String correlationId;
	public Object error;
	public Data data;

	public class LimitDtls {

        public LimitDtls(){
            this.customerName = ksc_Constants.STRING_BLANK;
            this.drawingPower = ksc_Constants.STRING_BLANK;
            this.limitType = ksc_Constants.STRING_BLANK;
            this.sanctionLimit = ksc_Constants.STRING_BLANK;
            this.outstandingAmount = ksc_Constants.STRING_BLANK;
            this.fundLiability = ksc_Constants.STRING_BLANK;
            this.nonfundedLiability = ksc_Constants.STRING_BLANK;
            this.creditBalance = ksc_Constants.STRING_BLANK;
            this.utilized_Limit = ksc_Constants.STRING_BLANK;
            this.availableSanctionLimit = ksc_Constants.STRING_BLANK;
            this.availableDrawingPower = ksc_Constants.STRING_BLANK;
            this.description = ksc_Constants.STRING_BLANK;
            this.CCY = ksc_Constants.STRING_BLANK;
            this.parentLimitID = ksc_Constants.STRING_BLANK;
            this.userMaintainedLiability = ksc_Constants.STRING_BLANK;
            this.limitApprovalDate = ksc_Constants.STRING_BLANK;
            this.limitExpiryDate = ksc_Constants.STRING_BLANK;
            this.limitEffectiveDate = ksc_Constants.STRING_BLANK;
            this.limitExpiryExtendedUpTo = ksc_Constants.STRING_BLANK;
            this.limitTypeId = ksc_Constants.STRING_BLANK;
            this.drawingPowerInd = ksc_Constants.STRING_BLANK;
            this.limitReviewDate = ksc_Constants.STRING_BLANK;
            this.availabilityEndDate = ksc_Constants.STRING_BLANK;
        }

		public String customerName;
		public String drawingPower;
		public String limitType;
		public String sanctionLimit;
		public String outstandingAmount;
		public String fundLiability;
		public String nonfundedLiability;
		public String creditBalance;
		public String utilized_Limit;
		public String availableSanctionLimit;
		public String availableDrawingPower;
		public String description;
		public String CCY;
		public String parentLimitID;
		public String userMaintainedLiability;
		public String limitApprovalDate;
		public String limitExpiryDate;
		public String limitEffectiveDate;
		public String limitExpiryExtendedUpTo;
		public String limitTypeId;
		public String drawingPowerInd;
		public String limitReviewDate;
		public String availabilityEndDate;
	}

	public class Data {

        public Data(){
            this.requestUUId = ksc_Constants.STRING_BLANK;
            this.serviceRequestId = ksc_Constants.STRING_BLANK;
            this.serviceRequestVersion = ksc_Constants.STRING_BLANK;
            this.ChannelId = ksc_Constants.STRING_BLANK;
            this.bankId = ksc_Constants.STRING_BLANK;
            this.messageDateTime = ksc_Constants.STRING_BLANK;
            this.messageTimeZone = ksc_Constants.STRING_BLANK;
            this.UBUSTxnId = ksc_Constants.STRING_BLANK;
            this.UBUSTxnStatus = ksc_Constants.STRING_BLANK;
            this.hostTxnId = ksc_Constants.STRING_BLANK;
            this.hostTxnStatus = ksc_Constants.STRING_BLANK;
            this.hostParentTxnId = ksc_Constants.STRING_BLANK;
            this.hostParentTxnStatus = ksc_Constants.STRING_BLANK;
            this.limitDtls = new limitDtls();
        }

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
		public LimitDtls limitDtls;
	}
}