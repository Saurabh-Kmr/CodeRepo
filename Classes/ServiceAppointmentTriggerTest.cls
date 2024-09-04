@isTest
private class ServiceAppointmentTriggerTest {
  @testSetup
  static void setup() {
    OperatingHours oh = new OperatingHours(Name = 'Test Operating Hours');
    oh.TimeZone = 'America/Los_Angeles';
    insert oh;
    ServiceTerritory preServiceTerritory = new ServiceTerritory(
      Name = 'California - Install',
      OperatingHoursId = oh.Id,
      PostalCode = '94105',
      State = 'CA',
      City = 'San Francisco',
      Street = '415 Mission St',
      Country = 'United States',
      isActive = true
    );
    insert preServiceTerritory;
    ServiceTerritory phoenixST = new ServiceTerritory(
      Name = 'O&M: AZ-301 Phoenix North1',
      OperatingHoursId = oh.Id,
      PostalCode = '85004',
      State = 'AZ',
      City = 'Phoenix',
      Street = '77 East Polk Street',
      Country = 'United States',
      isActive = true
    );
    insert phoenixST;
    FSL__Polygon__c installPolygon = new FSL__Polygon__c(
      Name = 'CA- Install',
      FSL__Color__c = '#5679C0',
      FSL__KML__c = '<?xml version="1.0" encoding="UTF-8"?> ' +
        '<kml xmlns="http://www.opengis.net/kml/2.2">' +
        '<Style id="CentralSSSStyle">' +
        '<LineStyle>' +
        '<width>1</width>' +
        '</LineStyle>' +
        '<PolyStyle>' +
        '<color>80C07956</color>' +
        '</PolyStyle>' +
        '</Style>' +
        '<Placemark>' +
        '<name>CA- Install</name>' +
        '<styleUrl>#CentralSSSStyle</styleUrl>' +
        '<Polygon>' +
        '<outerBoundaryIs>' +
        '<LinearRing>\n' +
        '<coordinates>-121.77679254456541,36.524529300343126,0\n' +
        '-120.52435113831541,36.179447180075286,0\n' +
        '-118.85442926331541,36.25035791310597,0\n' +
        '-119.03295709534666,39.27637790736462,0\n' +
        '-124.39153863831541,40.31041897304344,0\n' +
        '-121.77679254456541,36.524529300343126,0\n' +
        '</coordinates>\n' +
        '</LinearRing>' +
        '</outerBoundaryIs>' +
        '</Polygon>' +
        '</Placemark>' +
        '</kml>',
      FSL__Ma_La__c = 40.31041897304344,
      FSL__Ma_Lo__c = -118.85442926331541,
      FSL__Mi_La__c = 36.179447180075286,
      FSL__Mi_Lo__c = -124.39153863831541,
      Type__c = 'Field Service'
    );
    insert installPolygon;
    WorkType installWorkType = new WorkType(
      ShouldAutoCreateSvcAppt = true,
      Name = 'Install Panel Test',
      EstimatedDuration = 60.00,
      DurationType = 'Minutes'
    );
    insert installWorkType;
    WorkOrder installWorkOrder = new WorkOrder(
      Subject = 'Test Work Order',
      workTypeId = installWorkType.Id,
      recordtypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Field_Service').getRecordTypeId(),
      PostalCode = '94105',
      State = 'CA',
      City = 'San Francisco',
      Street = '415 Mission St',
      Country = 'United States'
    );
    insert installWorkOrder;
    ServiceAppointment testServiceAppointment = new ServiceAppointment();
    testServiceAppointment.ParentRecordId = installWorkOrder.Id;
    testServiceAppointment.Status = 'Ready To Be Scheduled';
    testServiceAppointment.EarliestStartTime = DateTime.now();
    testServiceAppointment.DueDate = DateTime.now().addDays(7);
    testServiceAppointment.ArrivalWindowStartTime = null;
    testServiceAppointment.ArrivalWindowEndTime = null;
    testServiceAppointment.ServiceTerritoryId = preServiceTerritory.Id;
    testServiceAppointment.Note__c = 'Test SA';
    insert testServiceAppointment;
    ServiceAppointment testServiceAppointment1 = new ServiceAppointment();
    testServiceAppointment1.ParentRecordId = installWorkOrder.Id;
    testServiceAppointment1.Status = 'Ready To Be Scheduled';
    testServiceAppointment1.EarliestStartTime = DateTime.now();
    testServiceAppointment1.DueDate = DateTime.now().addDays(7);
    testServiceAppointment1.ArrivalWindowStartTime = null;
    testServiceAppointment1.ArrivalWindowEndTime = null;
    testServiceAppointment1.ServiceTerritoryId = preServiceTerritory.Id;
    testServiceAppointment1.Note__c = 'Test SA Two';
    insert testServiceAppointment1;

    FSL.GlobalAPIS.addStatusTransition('Ready To Be Scheduled', 'Scheduled');
    FSL.GlobalAPIS.addStatusTransition('Scheduled', 'Ready To Be Scheduled');
  }
  @isTest
  static void beforeUpdateTest() {
    WorkOrder testWorkOrder = [SELECT Id, ServiceTerritoryId FROM WorkOrder WHERE Subject = 'Test Work Order'];
    ServiceAppointment testServiceAppointment = [
      SELECT Id, Latitude, Longitude, ServiceTerritoryId
      FROM ServiceAppointment
      WHERE ParentRecordId = :testWorkOrder.Id AND Note__c != 'Test SA' AND Note__c != 'Test SA Two'
    ];
    testServiceAppointment.Latitude = 37.789853;
    testServiceAppointment.Longitude = -122.396806;

    System.Debug('Test Data ' + testServiceAppointment);
    Test.startTest();
    update testServiceAppointment;
    Test.stopTest();
    system.Assert(testWorkOrder.ServiceTerritoryId == testServiceAppointment.ServiceTerritoryId, 'Territory needs to be same');
    delete testServiceAppointment;
    ServiceAppointment[] savedServiceAppointment = [SELECT Id FROM ServiceAppointment WHERE Id = :testServiceAppointment.Id ALL ROWS];
    undelete savedServiceAppointment;
  }
  @isTest
  static void arrivalSlotTest() {
    ServiceAppointment testServiceAppointment = [
      SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status
      FROM ServiceAppointment
      WHERE Note__c = 'Test SA'
    ];
    testServiceAppointment.ArrivalWindowStartTime = DateTime.now();
    testServiceAppointment.ArrivalWindowEndTime = DateTime.now().addHours(5);
    testServiceAppointment.Status = 'Scheduled';
    Test.startTest();
    update testServiceAppointment;
    testServiceAppointment.Status = 'Ready To Be Scheduled';
    update testServiceAppointment;
    Test.stopTest();
  }
  @isTest
  static void arrivalSlotTest1() {
    ServiceAppointment testServiceAppointment = [
      SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status
      FROM ServiceAppointment
      WHERE Note__c = 'Test SA'
    ];
    testServiceAppointment.ArrivalWindowStartTime = DateTime.now();
    testServiceAppointment.ArrivalWindowEndTime = DateTime.now().addHours(5);
    testServiceAppointment.Status = 'Scheduled';
    Test.startTest();
    update testServiceAppointment;
    Test.stopTest();
  }
  @isTest
  static void arrivalSlotTest2() {
    ServiceAppointment testServiceAppointment = [
      SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status
      FROM ServiceAppointment
      WHERE Note__c = 'Test SA'
    ];
    testServiceAppointment.ArrivalWindowStartTime = DateTime.now().addHours(4);
    testServiceAppointment.ArrivalWindowEndTime = testServiceAppointment.ArrivalWindowStartTime.addHours(5);
    testServiceAppointment.Status = 'Scheduled';
    Test.startTest();
    update testServiceAppointment;
    Test.stopTest();
  }
  @isTest
  static void arrivalSlotTest3() {
    ServiceAppointment testServiceAppointment = [
      SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status
      FROM ServiceAppointment
      WHERE Note__c = 'Test SA'
    ];
    testServiceAppointment.ArrivalWindowStartTime = DateTime.now().addHours(8);
    testServiceAppointment.ArrivalWindowEndTime = testServiceAppointment.ArrivalWindowStartTime.addHours(5);
    testServiceAppointment.Status = 'Scheduled';
    Test.startTest();
    update testServiceAppointment;
    Test.stopTest();
  }
  @isTest
  static void arrivalSlotTest4() {
    ServiceAppointment testServiceAppointment = [
      SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status
      FROM ServiceAppointment
      WHERE Note__c = 'Test SA Two'
    ];
    testServiceAppointment.ArrivalWindowStartTime = DateTime.now().addHours(12);
    testServiceAppointment.ArrivalWindowEndTime = testServiceAppointment.ArrivalWindowStartTime.addHours(5);
    testServiceAppointment.Status = 'Scheduled';
    ServiceAppointment testServiceAppointment1 = [
      SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status
      FROM ServiceAppointment
      WHERE Note__c = 'Test SA'
    ];
    FSL__Time_Dependency__c dependency = new FSL__Time_Dependency__c();
    dependency.FSL__Root_Service_Appointment__c = testServiceAppointment.Id;
    dependency.FSL__Service_Appointment_1__c = testServiceAppointment.Id;
    dependency.FSL__Service_Appointment_2__c = testServiceAppointment1.Id;
    dependency.FSL__Dependency__c = 'Same Start';
    insert dependency;
    Test.startTest();
    update testServiceAppointment;
    Test.stopTest();
  }
  @isTest
  static void arrivalSlotTest5() {
    ServiceAppointment testServiceAppointment = [
      SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status
      FROM ServiceAppointment
      WHERE Note__c = 'Test SA'
    ];
    ServiceAppointment testServiceAppointment1 = [
      SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status
      FROM ServiceAppointment
      WHERE Note__c = 'Test SA Two'
    ];
    testServiceAppointment.ArrivalWindowStartTime = DateTime.now().addHours(16);
    testServiceAppointment.ArrivalWindowEndTime = testServiceAppointment.ArrivalWindowStartTime.addHours(5);
    testServiceAppointment.Status = 'Scheduled';
    FSL__Time_Dependency__c dependency = new FSL__Time_Dependency__c();
    dependency.FSL__Root_Service_Appointment__c = testServiceAppointment1.Id;
    dependency.FSL__Service_Appointment_1__c = testServiceAppointment1.Id;
    dependency.FSL__Service_Appointment_2__c = testServiceAppointment.Id;
    dependency.FSL__Dependency__c = 'Same Start';
    insert dependency;
    Test.startTest();
    update testServiceAppointment;
    Test.stopTest();
  }
  @isTest
  static void serviceTerritoryUpdate() {
    ServiceAppointment testServiceAppointment = [
      SELECT Id, ArrivalWindowStartTime, ArrivalWindowEndTime, Status
      FROM ServiceAppointment
      WHERE Note__c = 'Test SA'
    ];
    ServiceTerritory stToUpdate = [SELECT Id FROM ServiceTerritory WHERE Name = 'O&M: AZ-301 Phoenix North1' LIMIT 1];
    testServiceAppointment.ArrivalWindowStartTime = DateTime.now().addHours(16);
    testServiceAppointment.ArrivalWindowEndTime = testServiceAppointment.ArrivalWindowStartTime.addHours(5);
    testServiceAppointment.Status = 'Scheduled';
    testServiceAppointment.ServiceTerritoryId = stToUpdate.Id;
    Test.startTest();
    update testServiceAppointment;
    Test.stopTest();
  }
}
