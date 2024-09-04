/*********************************************************
*Name           :   ksc_Constants
*Author         :   Megha Sahu
*Since          :   1st Nov 2022   
*Description    :   Constant class to store all the resable variables at one place
*History        :

Name                Date                  Change Description

*********************************************************/

public with sharing class ksc_Constants {

    public static final String STRING_BLANK ='';
    public static final String STRING_SPACE = ' ';
    public static final String STRING_NA = 'NA';
    public static final String STRING_HYPHEN = '-';
    public static final String STRING_SUCCESSCODE ='200';
    public static final String NOT_AVAILABLE ='Not Available';
    public static final Boolean BOOL_TRUE = true;
    public static final Boolean BOOL_FALSE = false;
    public static final String STATUS_NEW ='New';
    public static final String STATUS_IN_PROGRESS ='In Progress';
    public static final String STATUS_CLOSED ='Closed';
    public static final String ORDER_BY_CLAUSE = 'ksc_OrderNumber__c';
    public static final String LIMIT_CLAUSE = ' 100';
    public static final String STRING_ERRORCODE ='400';
    public static final String STRING_BALTYPE ='balType';
    public static final String STRING_BALAMT ='balAmt';
    public static final String STRING_BALAMTCODE ='balAmtCode';
    public static final String HRD_CORRELATIONID = 'ksc_correlation_id';
    public static final String HRD_CLIENTID = 'ksc_client_id';
    public static final String HRD_CLIENTSECRET = 'ksc_client_secret';
    public static final String HRD_TRANSACTIONID = 'ksc_transaction_id';
    public static final String HRD_BANKID = 'ksc_bankId';
    public static final String HRD_CHANNELID = 'ksc_channelId';
    public static final String HRD_KOTAKSCRAPP = 'ksc_kotak_src_app';
    public static final String HRD_APPLID = 'ksc_appl_id';
    public static final String HRD_SIGNONNAME = 'ksc_signonName';
    public static final String HRD_CCMASKED = 'ksc_ccMasked';
    public static final String HRD_FROMDATE = 'ksc_from_date';
    public static final String HRD_TODATE = 'ksc_to_date';
    public static final String HRD_PARTYID = 'ksc_party_id';
    public static final String HRD_CUSTTYPE = 'ksc_custType';
    public static final String HRD_ACTIONBY = 'ksc_actionBy';
    public static final String HRD_INDICATOR = 'ksc_Indicator';
    public static final String STRING_AND = ' AND ';
    public static final String ISACTIVE_CHECK_TRUE= 'ksc_IsActive__c = true';
    public static final String RECORDTYPE_PERSON = 'Person Account';
    public static final String RECORDTYPE_BUSINESS = 'Business Account';
    public static final String HRD_CARDIND = 'ksc_cardInd';
    public static final String HRD_LRPAPPLID = 'ksc_LRP_appl_id';
    public static final String HRD_LRPKOTAKSCRAPP = 'ksc_LRP_kotak_src_app';
    public static final String HRD_MOBILENUMBER = 'ksc_mobileNbr';
    public static final String HRD_ORG = 'ksc_org';
    public static final string STRING_DEBIT_CARDS = 'DebitCard';
    public static final string STRING_CREDIT_CARDS = 'CreditCard';
    public static final string STRING_COLON = ':';
    public static final string STRING_FORWARD_SLASH = '/';

    /**Added by Shreya */
    public static final String HRD_TXFRM = 'txnDateFrom';
    public static final String HRD_TXTHRU = 'txnDateThru';
    public static final String HRD_CONTEXT = 'ksc_context';
    public static final String HRD_EPPID = 'ksc_eppInd';
    public static final String HRD_TXNDETAIL= 'ksc_txnDetail';
    public static final String HRD_USERID = 'ksc_userId';
    public static final String HRD_CARDNUMBER = 'ksc_cardNo';
    public static final String HRD_ACTION_DC = 'ksc_action_DC';
    public static final String STRING_CREDUSERNAME = '{!$Credential.UserName}';
    public static final String STRING_CREDPASSWORD = '{!$Credential.Password}';
    public static final String STRING_ASTNAME = '{astName}';
    public static final String STRING_T = 'T';
    public static final String STRING_GRP_NAME = ' ksc_GroupName__c =';
    public static final String STRING_ODR_NUMBER = ' ksc_OrderNumber__c';
    public static final String STRING_100 = ' 100';
    public static final String STRING_ACCOUNTS = 'Accounts';
    public static final String STRING_ACCOUNTS_BRCKT ='Accounts (';
    public static final String STRING_CARDS= 'Cards';
    public static final String STRING_CARDS_BRCKT= 'Cards (';
    public static final String STRING_CLS_BRCKT= ')';
    public static final String STRING_OPEN_BRCKT= '(';
    public static final String STRING_LOANS= 'Loans';
    public static final String STRING_LOANS_BRCKT= 'Loans (';
    public static final String STRING_DEPOSITS= 'Deposits';
    public static final String STRING_DEPOSITS_BRCKT= 'Deposits (';
    public static final String STRING_ODS= 'ODs';
    public static final String STRING_ODS_BRCKT= 'ODs (';
    public static final String STRING_ACCOUNT= 'Account';
    public static final String STRING_CARD= 'Card';
    public static final String STRING_LOAN= 'Loan';
    public static final String STRING_DEPOSIT= 'Deposit';
    public static final String STRING_OD= 'OD';
    public static final String STRING_ACTION='action';
    public static final String STRING_DATE_FORMAT_1 = 'dd-MMM-yy';
    public static final String STRING_DATE ='Date';
    public static final String STRING_GENERIC_ERROR = 'There is no relevant data found. Please connect with System Administrator.';
    public static final String ICN_ACTION_CLS = 'action:close';
    public static final String ICN_ACTION_APP = 'action:approval';
    public static final String STRING_YES = 'Yes';
    public static final String STRING_FATCA = 'FATCA_RECVD__c';
    public static final String STRING_ACC_BA_RT = 'Business_Account';
    public static final String STRING_PAN = 'PAN';
    public static final String STRING_COMPANY_PAN ='company_pan__c';
    public static final String STRING_ACTIVE_CNDT =' AND ksc_IsActive__c = true ';
    public static final String STRING_PASSPORT = 'Passport__pc';
    public static final String STRING_PASSPORT_EXPIRY= 'Passport_Expiry__pc';
    public static final String STRING_INDICATOR = 'Indicator';
    public static final String STRING_BACKSLASH = '\'';
    public static final String STR_REKYC_UPDATE = 'ReKYC updated on ';
    public static final String STR_REKYC_NODATE = 'ReKYC is done. However the ReKYC date is not updated.';
    public static final String FLD_REKYC_STATUS = 'Re_KYC_Status__c';
    public static final String FLD_REKYC_DATE = 'ReKYC_Date__c';
     public static final String STR_DEBIT_CARD = 'Debit';
    public static final String STR_CREDIT_CARD = 'Credit';
    public static final String STR_DATE_FORMAT_2 = 'dd-MM-yyyy';
    public static final String STRING_MASKED = 'MASKED';
    public static final String STRING_NOACCESS = 'NOACCESS';
    public static final String STRING_CUSTOM_1 = 'Custom-1';
    public static final String STRING_ASTERISK = '*';

    /**Ended by Shreya */

    /* Added for OD INFO Class ~Soomjeet */
    public static final String GROUP_OD_ACCOUNT_INFO_SECTION ='OD Account Info Section';
    public static final String GROUP_OD_ACCOUNT_BRANCH_INFO_SECTION ='OD Account Info Section-BranchInfo';
    public static final String GROUP_OD_ACCOUNT_CUSTOMER_INFO_SECTION ='OD Account Info Section-CustDetails';
    public static final String GROUP_OD_ACCOUNT_STATEMENT_FREQ_SECTION ='OD Statement Frequency Section';
    public static final String GROUP_OD_ACCOUNT_BALANCE_SECTION ='OD Account Balance Section';
    public static final String GROUP_OD_ACCOUNT_INTEREST_SECTION ='OD Account Interest Section';
    public static final String GROUP_NOMINEE_DETAILS_SECTION ='OD Nominee Detail Section';
    public static final String GROUP_RELATED_PARTY_DETAILS_SECTION ='OD Related Party Detail Section';
    /* END - Added for OD INFO Class ~Soomjeet */

    /* Added for Loan Tx Section Class ~Soomjeet */
    public static final String GROUP_LOAN_TX_TABLE = 'Loan Transactions Table';
    public static final String GROUP_CHQ_DET_TABLE = 'Chq. Detail Table';
    public static final String GROUP_CHQ_BOUN_TABLE = 'Chq. Bounced Table';
    /* END - Added for Loan Tx Section Class ~Soomjeet */

    /* Added for Account Tx Section Class ~Soomjeet */
    public static final String GROUP_ACC_TX_TABLE = 'Account Transactions Table';
    /*END - Added for Loan Tx Section Class ~Soomjeet */
    
    /* Added for ksc_AccountsSearchParser Class ~Neeti */
    public static final String CUST_TYPE_RETAIL = 'retail';
    public static final String CUST_TYPE_CORPORATE = 'corporate';
    public static final String SUCCESS_MESSAGE  = 'Assets Updated Successfully';
    public static final String NO_DATA_MESSAGE  = 'Sync Complete. No new data found';
    public static final String ERROR_MESSAGE = 'An unexpected error Occured. Please connect with System Administrator.';
    /*END - Added for ksc_AccountsSearchParser Class ~Neeti */

    public static final String C360_PERM_SET_APINAME = 'ksc_Customer_360';
    public static final String MOCK_ERROR_RESPONSE_BODY = '{"code":400,"status":"FAILURE","transactionId":"MockTxIdError","error":{"errorMessage":"BAD_REQUEST","errorDetails":"ForBidden"},"data":null}';
    public static final String MOCK_DEFAULT_RESPONSE_BODY = '{"example":"test"}';
    public static final String MOCK_ENCRYPTION_KEY = 'OkSqBEB++kdiZmwmigEtCHMW8MXUgO02wGhVlA0+3JQ=';
    public static final String MOCK_ENCRYPTION_RESPONSE = 'ji+U/tVFevfj3LZQFHdIPyd9Q5MkYl7w1t0akDSgKPOYSX+b5F5EbgwnRe/YvMfkJH+sU4xuycbJCdt0a2YS9yTtGmwBPNy36m7vZiTnO1MLjSd0JhJYoSA6t1U5hVEy0o399b+8J6iC0ayjNq4cdtg7aoULEqZDq7P6IeaXlrpb2r3Ehf3zYDcBnVl9Z45PdPPmWnsR2R+8YAVVVCjUOw==';

    public static final String STRING_GSTIN = 'GSTIN Number';
    public static final String STRING_CKYC = 'CKYC Number';
    public static final String STRING_TURNOVER = 'Turnover';
    public static final String STRING_INCOME_SLAB = 'Income Slab';

    public static final String GRP_ACCOUNTHIGHLIGHTCOL = 'Account Highlights Columns';
    public static final String GRP_LINKEDCRN = 'Linked And Family Account';
    public static final String GRP_APACPARTYRELATION = 'Asset Related Party Detail Table';
    public static final String GRP_OUTSTANDINGAUTHINQ = 'Card Outstanding Auth Inq';
    public static final String GRP_REWARDPOINTINQ = 'Card Reward Point Inq';
    public static final String GRP_LOANHEADER = 'Loan Limit Detail Header';    
    public static final String GRP_CARDACCTINQ = 'Card Acct Inquiry';
	public static final String GRP_DYNAMICAPI = 'Profile Info-Dynamic API';
	public static final String GRP_ACCLIMITSCT = 'Account Limit - Sanction';
	public static final String GRP_ACCLMTDP = 'Account Limit - Drawing Power';
	public static final String STRING_AMOUNT_VALUE = 'amountValue';
	public static final String STRING_CURRENCY_CODE = 'currencyCode';

    public static final Integer INT_ATTACHMENT_SIZE = 5000;
    public static final String STR_ATTACHMENT = 'Please refer the attachment.';
    public static final String STR_ATTACHMENT_HEADER = 'Response Body of :- ';
    public static final String STRING_CARD_TX_HDR = 'Card Transactions Table';
    public static final String STRING_TYPE = 'type';
    public static final String STRING_DEBIT_CARD = 'Debit';
    public static final String STRING_D = 'd';
    public static final String STRING_CREDIT_CARD = 'Credit';
    public static final String STRING_C = 'c';
    public static final String STRING_CCMASKED ='ksc_ccMasked';
    public static final String STRING_MBL_NUMBER ='ksc_mobileNbr';
    public static final String STRING_PRODUCT_LISTING = 'Product_Listing';
    public static final String STRING_SEMI_COLON =';';
    public static final String STRING_PROD_LIST_TABLE = '% ProductListing Table';

    public static final String STRING_CARDNO = 'cardNo';
    public static final String STRING_ACTIONBY = 'actionBy';
    public static final String GRP_DEBITLMT = 'Debit Card Limit';
    public static final String STRING_DYNSRCAPP = 'ksc_DYN_kotak_src_app';

    public static final string STRING_PERSON_ACCOUNT_DEVELOPERNAME = 'PersonAccount';
    public static final string GRP_EMBOSSER_DTLS_API = 'Embosser Inquiry Detail';

    public static final string TIMEZONE_ASIA_KOLKATA = 'Asia/Kolkata';

    public static final String HRD_REQUIRED_ENCRYPTION = 'x-req-enc';
    public static final String HRD_ACTUAL_CONTENT_TYPE = 'actual-content-type';
    public static final String HRD_RESPONSE_ENCRYPTED = 'x-enc-flag';
    public static final String STRING_DOUBLEHYPHEN = '--';
    public static final String STRING_DEBITCARD_ACCOUNT_NUM = 'XXXX';
    public static final String STRING_DAY = ' Day';
    public static final String STRING_DAYS = ' Days';
    public static final String STRING_MONTHS = ' Months ';
    public static final String STRING_MONTH = ' Month ';
    public static final String STRING_YEAR = ' Year ';
    public static final String STRING_YEARS = ' Years ';
    public static final String STRING_DOT = '.';
    public static final String DDSUCCESS_MESSAGE  = 'Account added successfully';
    public static final String GRP_CPACCTDETAIL = 'Corporate Loan Account';
    public static final String HRD_ACCTCUR = 'ksc_acct_Cur';
    public static final String HRD_DTLSUMFLG = 'ksc_detailSumFlg';
    public static final String HRD_SETID = 'ksc_setId';
    public static final String FORWARD_SLASH_ESC_CHAR = '%2F';
    public static final String HRD_FIANACIALYEAR = 'ksc_financialYear';
    public static final String HRD_TYPEPROD = 'ksc_typeOfProduct';
    public static final String HRD_CARDNUMBER2 = 'ksc_cardNumber';
    public static final String HRD_STMTMON = 'ksc_statementMonth';
    public static final String HRD_STMTPATH = 'ksc_pathOfStatement';
    public static final String HRD_PINCODE = 'ksc_pinCode';

    /*JWT Auth Params*/
	public static final String STRING_BEARER = 'Bearer';
    public static final String HRD_AUTHORIZATION ='Authorization';
}