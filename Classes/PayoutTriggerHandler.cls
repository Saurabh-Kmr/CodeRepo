public with sharing class PayoutTriggerHandler extends TriggerHandlerBase {
  public override void beforeUpdate(TriggerDto.Context info) {
    new PayoutBeforeUpdateTriggerHandler().enforceLegalDocumentRequirement((List<Payout__c>) info.newList, (Map<Id, Payout__c>) info.oldMap);
  }
}
