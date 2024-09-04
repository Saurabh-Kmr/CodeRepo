trigger ServiceAppointmentTrigger on ServiceAppointment(before update, after update) {
  Sf.triggers.handle(new ServiceAppointmentTriggerHandler());
}
