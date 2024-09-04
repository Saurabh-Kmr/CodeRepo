public with sharing class ServiceAppointmentTriggerHandler extends TriggerHandlerBase {
  public override void beforeUpdate(TriggerDto.Context info) {
    new ServiceApptTriggerBfrUpdateHandler().updateServiceAppointments(info.newList, info.oldMap);
  }
  public override void afterUpdate(TriggerDto.Context info) {
    new ServiceApptTriggerAfterUpdateHandler().updateServiceAppointments(info.newList, info.oldMap);
  }
}
