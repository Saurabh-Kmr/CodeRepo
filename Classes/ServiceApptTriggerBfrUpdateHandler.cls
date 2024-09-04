public without sharing class ServiceApptTriggerBfrUpdateHandler {
  public void updateServiceAppointments(List<ServiceAppointment> newServiceAppointments, Map<ID, sObject> oldServiceAppointmentMap) {
    new ServiceApptTriggerBfrUpdateHandler().updateServiceTerritory(newServiceAppointments, oldServiceAppointmentMap);
    new ServiceApptTriggerBfrUpdateHandler().updateSAInformation(newServiceAppointments, oldServiceAppointmentMap);
  }
  public void updateServiceTerritory(List<ServiceAppointment> newServiceAppointments, Map<ID, sObject> oldServiceAppointmentMap) {
    try {
      Set<Id> workOrderIdSet = new Set<Id>();
      Map<ServiceAppointment, String> mapOfSAtoPolygonIds = new Map<ServiceAppointment, String>();
      String postPTOPicklistVal = Sf.settings.getString('Post_PTO_Polygons', 'Field Service');
      String prePTOPicklistVal = Sf.settings.getString('Pre_PTO_Polygons', 'Install');
      String fieldService = Sf.settings.getString('Field_Service_Work_Order_Api_Name', 'Field_Service');
      String install = Sf.settings.getString('Install_Work_Order_Record_Type_Name', 'Install');

      List<FSL__Polygon__c> listOfPolygon = [SELECT Id, Type__c, FSL__Service_Territory__c FROM FSL__Polygon__c];

      Map<String, Set<String>> mapOfKeyTypePolygon = getPolygonIdsByType(listOfPolygon);

      for (ServiceAppointment saIterVar : newServiceAppointments) {
        if (
          Ut.getSobjName(saIterVar.ParentRecordId) == 'WorkOrder' &&
          (saIterVar.Latitude != (Double) oldServiceAppointmentMap.get(saIterVar.Id).get('Latitude') ||
          saIterVar.Longitude != (Double) oldServiceAppointmentMap.get(saIterVar.Id).get('Longitude'))
        ) {
          workOrderIdSet.add(saIterVar.ParentRecordId);
        }
      }

      Map<Id, WorkOrder> mapOfIdWorkOrder = new Map<Id, WorkOrder>(
        [SELECT Id, RecordType.DeveloperName, RecordTypeId FROM WorkOrder WHERE Id IN :workOrderIdSet]
      );

      for (ServiceAppointment saIterVar : newServiceAppointments) {
        if (!mapOfKeyTypePolygon.isEmpty()) {
          if (
            mapOfIdWorkOrder.get(saIterVar.ParentRecordId)?.RecordType.DeveloperName == fieldService &&
            mapOfKeyTypePolygon.containsKey(postPTOPicklistVal)
          ) {
            saIterVar.ServiceTerritoryId = getServiceTerritoryFromLatLong(
              saIterVar.Id,
              (Double) saIterVar.Longitude,
              (Double) saIterVar.Latitude,
              mapOfKeyTypePolygon.get(postPTOPicklistVal)
            );
          }
          if (
            mapOfIdWorkOrder.get(saIterVar.ParentRecordId)?.RecordType.DeveloperName == install && mapOfKeyTypePolygon.containsKey(prePTOPicklistVal)
          ) {
            saIterVar.ServiceTerritoryId = getServiceTerritoryFromLatLong(
              saIterVar.Id,
              (Double) saIterVar.Longitude,
              (Double) saIterVar.Latitude,
              mapOfKeyTypePolygon.get(prePTOPicklistVal)
            );
          }
        }
      }
    } catch (Exception ex) {
      AppLogger.logError('Polygon', 'updateServiceTerritory', newServiceAppointments[0].Id, 'Error Occurred in Updating the service territory', ex);
    }
  }
  public Map<String, Set<String>> getPolygonIdsByType(List<FSL__Polygon__c> listOfPolygon) {
    Map<String, Set<String>> mapOfTypeReturnIds = new Map<String, Set<String>>();
    if (!listOfPolygon.isEmpty()) {
      for (FSL__Polygon__c polygonIter : listOfPolygon) {
        if (mapOfTypeReturnIds.containsKey(polygonIter.Type__c)) {
          mapOfTypeReturnIds.get(polygonIter.Type__c).add(polygonIter.Id);
        } else {
          mapOfTypeReturnIds.put(polygonIter.Type__c, new Set<String>());
          mapOfTypeReturnIds.get(polygonIter.Type__c).add(polygonIter.Id);
        }
      }
      return mapOfTypeReturnIds;
    }
    return null;
  }
  public String getServiceTerritoryFromLatLong(String saId, Double SAlongitude, Double SAlatitude, Set<String> typeOfPolygonIdsList) {
    List<FSL__Polygon__c> relevantPrePolygons = FSL.PolygonUtils.getAllPolygonsByLatLong(SAlongitude, SAlatitude);
    String serviceTerritorySt = '';
    if (!relevantPrePolygons.isEmpty()) {
      for (FSL__Polygon__c polygonIter : relevantPrePolygons) {
        if (typeOfPolygonIdsList.contains(polygonIter.Id)) {
          return String.valueOf(polygonIter.FSL__Service_Territory__c);
        }
      }
    }
    return null;
  }
  /*Method used to calculate arrival slot and to empty the values of Arrival Start Date, Arrival End Date and Arrival Slot when SA is unscheduled*/
  /*Added by Sirigowri.Ananthapadmanabha@sunrun.com on Aug 24 20238*****************************************************************/
  public void updateSAInformation(List<ServiceAppointment> newServiceAppointments, Map<ID, sObject> oldServiceAppointmentMap) {
    System.debug('updateSAInformation');
    List<ServiceAppointment> listOfSAtoUpdate = new List<ServiceAppointment>();
    Set<Id> workOrderIdSet = new Set<Id>();
    Set<Id> sTIdSet = new Set<Id>();
    String fieldService = Sf.settings.getString('Field_Service_Work_Order_Api_Name', 'Field_Service');
    String scheduledSAStatus = Sf.settings.getString('SA_Status', 'Scheduled');
    String unscheduledSAStatus = Sf.settings.getString('SA_Status_Unscheduled', 'Ready To Be Scheduled');

    for (ServiceAppointment saIterVar : newServiceAppointments) {
      /*When the Service Appointment status changes from Scheduled to Ready To Be Scheduled**
       **assign null values to ArrivalWindowStartTime,ArrivalWindowEndTime and Arrival_Slot__c*/
      if (
        saIterVar.Status == unscheduledSAStatus &&
        (String) oldServiceAppointmentMap.get(saIterVar.Id).get('Status') == scheduledSAStatus &&
        (saIterVar.ArrivalWindowStartTime != null ||
        saIterVar.ArrivalWindowEndTime != null)
      ) {
        System.debug('inside 1st if');
        saIterVar.ArrivalWindowStartTime = null;
        saIterVar.ArrivalWindowEndTime = null;
        saIterVar.Arrival_Slot__c = null;
      }
      /*filter the Service Appointments only when the Arrival Window Start/End Time is changed 
and if the Service Appointments have a Service Territory********************************
also create a set of Work Orders to check for the Record Type =Field Service************ 
and Service Territories to check for Operating hour timezone respectively***************/
      if (
        ((saIterVar.ArrivalWindowStartTime != (DateTime) oldServiceAppointmentMap.get(saIterVar.Id).get('ArrivalWindowStartTime') ||
        saIterVar.ArrivalWindowEndTime != (DateTime) oldServiceAppointmentMap.get(saIterVar.Id).get('ArrivalWindowEndTime'))) &&
        (saIterVar.ServiceTerritoryId != null &&
        Ut.getSobjName(saIterVar.ParentRecordId) == 'WorkOrder')
      ) {
        System.debug('inside 2nd if');
        listOfSAtoUpdate.add(saIterVar);
        workOrderIdSet.add(saIterVar.ParentRecordId);
        sTIdSet.add(saIterVar.ServiceTerritoryId);
      }
    }

    Map<Id, WorkOrder> mapOfIdWorkOrder = new Map<Id, WorkOrder>(
      [SELECT Id, RecordType.DeveloperName, RecordTypeId FROM WorkOrder WHERE Id IN :workOrderIdSet]
    );
    Map<Id, ServiceTerritory> mapOfIdServiceTerritory = new Map<Id, ServiceTerritory>(
      [SELECT Id, OperatingHours.TimeZone FROM ServiceTerritory WHERE Id IN :sTIdSet]
    );
    System.debug('mapOfIdWorkOrder' + mapOfIdWorkOrder);
    System.debug('mapOfIdServiceTerritory' + mapOfIdServiceTerritory);
    System.debug('listOfSAtoUpdate' + listOfSAtoUpdate);
    //Iterate over the filtered Service Appointments to calculate the arrival slot
    for (ServiceAppointment saIterVar : listOfSAtoUpdate) {
      System.debug('inside filtered sa');
      if (mapOfIdWorkOrder.get(saIterVar.ParentRecordId)?.RecordType.DeveloperName == fieldService && saIterVar.ArrivalWindowStartTime != null) {
        System.debug('inside filtered sa if');
        calculateArrivalSlot(saIterVar, Timezone.getTimeZone(mapOfIdServiceTerritory.get(saIterVar.ServiceTerritoryId).OperatingHours.TimeZone));
      }
    }
  }

  /*Method used to compute the arrival slot for the given Arrival Start Time and Arrival End Time using the offset to calculate time
   * in the Service Appointment's Service Territory Operating Hour Timezone and then adding verbiage like morning, afternoon based on
   * the timings of the arrival window***********************************************************************************************
   * Added by Sirigowri.Ananthapadmanabha@sunrun.com on Aug 24 2023*****************************************************************/
  public static void calculateArrivalSlot(ServiceAppointment saItem, Timezone tz) {
    String arrivalSlotFieldServiceRT = Sf.settings.getString('Arrival_Slot_FieldService_RT', 'Field Service');

    //get ArrivalWindowStartTime and ArrivalWindowEndTime from Service Appointment
    DateTime arrivalStart = saItem.ArrivalWindowStartTime;
    DateTime arrivalEnd = saItem.ArrivalWindowEndTime;

    //converting the Arrival Start and End Dates in Operating Hour Timezone from UTC to Operating Hour Timezone
    DateTime arrivalStartFormatted = arrivalStart.addSeconds((tz.getOffset(arrivalStart) / 1000));
    DateTime arrivalEndFormatted = arrivalEnd.addSeconds((tz.getOffset(arrivalEnd) / 1000));

    //Format the time to 12 hour time to calculate the Slot
    String timeOfarrivalWindow = arrivalStartFormatted.formatGmt('h:mm a') + '-' + arrivalEndFormatted.formatGmt('h:mm a');

    //To easily compute verbiage use 24h time format for the Arrival Start time
    Integer intStartArrTime = arrivalStartFormatted.hourGmt();
    saItem.Arrival_Slot__c = '';

    //Based on the Arrival Start Time compute the verbiage and concatenate with the Arrival Slot
    List<Arrival_Slot__mdt> arrivalSlotResult = [
      SELECT Id, Slot_Name__c
      FROM Arrival_Slot__mdt
      WHERE
        Start_Time_GT_in_24_Hours__c <= :intStartArrTime
        AND Start_Time_LT_in_24_hours__c >= :intStartArrTime
        AND Record_Type__c = :arrivalSlotFieldServiceRT
    ];

    if (!arrivalSlotResult.isEmpty() && arrivalSlotResult.size() == 1) {
      saItem.Arrival_Slot__c = saItem.Arrival_Slot__c + timeOfarrivalWindow + ' ' + arrivalSlotResult[0].Slot_Name__c;
    }
  }
}
