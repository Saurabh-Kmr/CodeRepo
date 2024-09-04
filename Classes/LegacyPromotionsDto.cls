public class LegacyPromotionsDto {
  // This structure maps API response. Do not rename fields
  public class ListPromotionsResp {
    @AuraEnabled
    public AppeasementPromo[] appeasementPromos;
    @AuraEnabled
    public AppliedPromo[] appliedPromos;
    @AuraEnabled
    public PromoRec[] promoRec;
    @AuraEnabled
    public String todaysDateValue;
    @AuraEnabled
    public String partnerUrl;
  }

  public class AppeasementPromo {
    @AuraEnabled
    public WrapRec wrapRec;
  }

  public class AppliedPromo {
    @AuraEnabled
    public WrapRec wrapRec;
  }

  public class PromoRec {
    @AuraEnabled
    public WrapRec wrapRec;
  }

  public class WrapRec {
    @AuraEnabled
    public String totalAmnt; //0
    @AuraEnabled
    public String stackable; //Yes
    @AuraEnabled
    public boolean restrictedApplyUnapply;
    @AuraEnabled
    public String refereePaymentAmount; //0
    @AuraEnabled
    public String promoType; //Offer
    @AuraEnabled
    public String promoSubtype; //Sales Appeasement
    @AuraEnabled
    public String promoSegmentation; //Appeasement
    @AuraEnabled
    public String promoName; //T&C's offer promotion
    @AuraEnabled
    public String promoId; //a0Y52000002IYf2EAG
    @AuraEnabled
    public String promoEnabled; //true
    @AuraEnabled
    public String opptyStage; //7. Closed Won
    @AuraEnabled
    public String opptyId; //0065200000GKw21AAD
    @AuraEnabled
    public boolean opptyGuardrails;
    @AuraEnabled
    public String offerValidityStatus; //Invalid
    @AuraEnabled
    public String offerStatus; //Applied
    @AuraEnabled
    public String offerId; //a5a52000000M3V4AAK
    @AuraEnabled
    public boolean managerApproval;
    @AuraEnabled
    public boolean isDeductibleFromCommission;
    @AuraEnabled
    public boolean exceptionOfr;
    @AuraEnabled
    public String dateApplied; //2023-05-26
    @AuraEnabled
    public boolean autoApply;
    @AuraEnabled
    public boolean adminOnly;
    @AuraEnabled
    public String promoApplicableTo;
    @AuraEnabled
    public String offerPayout1Status;
    @AuraEnabled
    public String datePayment;
  }
}
