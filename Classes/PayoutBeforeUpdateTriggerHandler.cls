public with sharing class PayoutBeforeUpdateTriggerHandler {
  public void enforceLegalDocumentRequirement(List<Payout__c> newPayoutList, Map<Id, Payout__c> oldPayoutMap) {
    for (Payout__c payout : newPayoutList) {
      if (
        payout.Amount__c > 5000 &&
        !payout.Required_Documentation_Attached__c &&
        oldPayoutMap.get(payout.Id).Approval_Status__c == 'Submitted' &&
        payout.Approval_Status__c == 'Approved'
      ) {
        payout.addError('A legal agreement is required before approval.');
      }
    }
  }
}
