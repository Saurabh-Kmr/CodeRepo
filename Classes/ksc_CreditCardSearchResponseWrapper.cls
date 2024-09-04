/**
* @Class         : ksc_CreditCardSearchResponseWrapper
* @Author        : Soomjeet Sahoo
* @Description   : This class is Wrapper class for CC Search Response
*
***********************************************************************************************************************
* 
*/
public with sharing class ksc_CreditCardSearchResponseWrapper {
    /****************************************************
     * @Description - Empty Constructor.    
     * @param none 
    *****************************************************/
    public ksc_CreditCardSearchResponseWrapper(){
        this.code = 0;
        this.transactionId = ksc_Constants.STRING_BLANK;
        this.status = ksc_Constants.STRING_BLANK;
        this.error = null;
        this.data = null;
    }

	public class PointsData {
		public String pointsBal;
		public String expirePoints;
	}

	public Integer code;
	public String status;
	public String transactionId;
	public Data data;
	public Object error;

	public class OutputArea {
		public String custName;
		public String totNbrOfAcct;
		public List<CustSumm> custSumm;
	}

	public class CardDtlsData {
		public String cardNbr;
		public String embName1;
		public String cardholderFlag;
		public String blockCode;
		public String cardExpireDate;
		public String spendLimit;
		public String plasticId;
		public String lastDatePlastic;
	}

	public class CustSumm {
		public String acctNbr;
		public String acctStatus;
		public String blockCode1;
		public String blockCode2;
		public String currBal;
		public String otb;
		public String billCyc;
		public String dueDate;
		public String logo;
		public String crlim;
		public String tempCrlim;
		public String tempCrlimDate;
		public String pmtCycle;
		public String graceBal;
		public String minAmtDue;
		public String directDb;
		public String pct;
		public String qualAmt;
		public String dateElgibility;
		public String cd;
		public String schdPmtAmt;
		public PointsData pointsData;
		public String totNbrOfCard;
		public List<CardDtlsData> cardDtlsData;
	}

	public class Data {
		public String svcReturn;
		public String rcNbrOccur;
		public OutputArea outputArea;
	}

}