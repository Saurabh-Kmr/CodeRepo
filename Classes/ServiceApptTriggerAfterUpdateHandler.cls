public without sharing class ServiceApptTriggerAfterUpdateHandler {
  public void updateServiceAppointments(List<ServiceAppointment> newServiceAppointments, Map<ID, sObject> oldServiceAppointmentMap) {
    new ServiceApptTriggerAfterUpdateHandler().updateServiceTerritory(newServiceAppointments, oldServiceAppointmentMap);
    new ServiceApptTriggerAfterUpdateHandler().updateSAInformation(newServiceAppointments, oldServiceAppointmentMap);
  }
  public void updateServiceTerritory(List<ServiceAppointment> newServiceAppointments, Map<ID, sObject> oldServiceAppointmentMap) {
    String fieldService = Sf.settings.getString('Field_Service_Work_Order_Api_Name', 'Field_Service');
    Map<Id, WorkOrder> mapOfIdWorkOrder = new Map<Id, WorkOrder>();
    for (ServiceAppointment saIterVar : newServiceAppointments) {
      if (
        saIterVar.ParentRecordId.getSObjectType().getDescribe().getName() == 'WorkOrder' &&
        saIterVar.ServiceTerritoryId != (String) oldServiceAppointmentMap.get(saIterVar.Id).get('ServiceTerritoryId')
      ) {
        mapOfIdWorkOrder.put(
          saIterVar.ParentRecordId,
          new WorkOrder(Id = saIterVar.ParentRecordId, ServiceTerritoryId = saIterVar.ServiceTerritoryId)
        );
      }
    }
    if (!mapOfIdWorkOrder.values().isEmpty() && mapOfIdWorkOrder.values().size() > 0) {
      update mapOfIdWorkOrder.values();
    }
  }
  public void updateSAInformation(List<ServiceAppointment> newServiceAppointments, Map<ID, sObject> oldServiceAppointmentMap) {
    try {
      Map<Id, ServiceAppointment> mapOfSAsToUpdate = new Map<Id, ServiceAppointment>();
      Set<Id> setOfSAIds = new Set<Id>();
      for (ServiceAppointment saIterVar : newServiceAppointments) {
        if (
          (saIterVar.Arrival_Slot__c != oldServiceAppointmentMap.get(saIterVar.Id).get('Arrival_Slot__c') && saIterVar.Arrival_Slot__c != null) &&
          Ut.getSobjName(saIterVar.ParentRecordId) == 'WorkOrder'
        ) {
          setOfSAIds.add(saIterVar.Id);
        }
      }
      List<FSL__Time_Dependency__c> lstSADependency = [
        SELECT
          Id,
          FSL__Service_Appointment_2__c,
          FSL__Service_Appointment_1__c,
          FSL__Service_Appointment_1__r.Arrival_Slot__c,
          FSL__Service_Appointment_1__r.ArrivalWindowStartTime,
          FSL__Service_Appointment_1__r.ArrivalWindowEndTime,
          FSL__Service_Appointment_2__r.Arrival_Slot__c,
          FSL__Service_Appointment_2__r.ArrivalWindowStartTime,
          FSL__Service_Appointment_2__r.ArrivalWindowEndTime
        FROM FSL__Time_Dependency__c
        WHERE FSL__Service_Appointment_1__c IN :setOfSAIds OR FSL__Service_Appointment_2__c IN :setOfSAIds
      ];
      if (!lstSADependency.isEmpty()) {
        for (FSL__Time_Dependency__c sadepIter : lstSADependency) {
          if (setOfSAIds.contains(sadepIter.FSL__Service_Appointment_2__c) && sadepIter.FSL__Service_Appointment_1__r.Arrival_Slot__c == null) {
            ServiceAppointment saToUpdate = new ServiceAppointment(
              Id = sadepIter.FSL__Service_Appointment_1__c,
              Arrival_Slot__c = sadepIter.FSL__Service_Appointment_2__r.Arrival_Slot__c,
              ArrivalWindowStartTime = sadepIter.FSL__Service_Appointment_2__r.ArrivalWindowStartTime,
              ArrivalWindowEndTime = sadepIter.FSL__Service_Appointment_2__r.ArrivalWindowEndTime
            );
            mapOfSAsToUpdate.put(saToUpdate.Id, saToUpdate);
          }
          if (setOfSAIds.contains(sadepIter.FSL__Service_Appointment_1__c) && sadepIter.FSL__Service_Appointment_2__r.Arrival_Slot__c == null) {
            ServiceAppointment saToUpdate = new ServiceAppointment(
              Id = sadepIter.FSL__Service_Appointment_2__c,
              Arrival_Slot__c = sadepIter.FSL__Service_Appointment_1__r.Arrival_Slot__c,
              ArrivalWindowStartTime = sadepIter.FSL__Service_Appointment_1__r.ArrivalWindowStartTime,
              ArrivalWindowEndTime = sadepIter.FSL__Service_Appointment_1__r.ArrivalWindowEndTime
            );
            mapOfSAsToUpdate.put(saToUpdate.Id, saToUpdate);
          }
        }
      }
      if (!mapOfSAsToUpdate.values().isEmpty()) {
        update mapOfSAsToUpdate.values();
      }
    } catch (Exception ex) {
      AppLogger.logError(
        'ArrivalSlot',
        'updateSAInformation',
        newServiceAppointments[0].Id,
        'Error Occurred in Updating the Arrival Slot on the dependent Service Appointment',
        ex
      );
    }
  }
}
