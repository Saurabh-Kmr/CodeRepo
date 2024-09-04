trigger PayoutTrigger on Payout__c(before update) {
  Sf.triggers.handle(new PayoutTriggerHandler());
}
