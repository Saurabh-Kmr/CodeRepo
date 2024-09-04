/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_AssetWarrantyTrigger on AssetWarranty(
  before delete,
  before insert,
  before update,
  after delete,
  after insert,
  after undelete,
  after update
) {
  if (Sf.triggers.isTriggerEnabled(new TriggerDto.Context())) {
    dlrs.RollupService.triggerHandler(AssetWarranty.SObjectType);
  }
}
