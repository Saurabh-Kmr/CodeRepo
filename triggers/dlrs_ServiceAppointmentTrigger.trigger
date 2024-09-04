/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 * Danny Maltby created for the DLRS deployement issue presented with FSL package
 **/
trigger dlrs_ServiceAppointmentTrigger on ServiceAppointment(
  before delete,
  before insert,
  before update,
  after delete,
  after insert,
  after undelete,
  after update
) {
  if (Sf.triggers.isTriggerEnabled(new TriggerDto.Context())) {
    dlrs.RollupService.triggerHandler(ServiceAppointment.SObjectType);
  }
}
