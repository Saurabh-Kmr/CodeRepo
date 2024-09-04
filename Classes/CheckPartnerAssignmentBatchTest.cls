@isTest
public with sharing class CheckPartnerAssignmentBatchTest {
  @TestSetup
  static void makeData() {
    // Insert test data
    Account acc = new Account(Name = 'Test');
    insert acc;

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
      Name = 'O&M: AZ-301 Phoenix North',
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
      Country = 'United States',
      Assigned_Partner__c = acc.Id,
      Status = 'Open'
    );
    insert installWorkOrder;

    List<BusinessHours> bhs = [SELECT id FROM BusinessHours WHERE IsDefault = TRUE];
  }

  @isTest
  public static void testBatchExecution() {
    // Run the batch
    Test.startTest();
    FSL.GlobalAPIS.addStatusTransition('On Hold', 'Cancelled');
    WorkOrder wo = [SELECT Id, Status FROM WorkOrder];
    wo.Partner_Job_Assignment_Date__c = Datetime.now().addDays(-10);
    update wo;
    Database.executeBatch(new CheckPartnerAssignmentBatch());
    Test.stopTest();

    // Verify WO and SA status updated
    WorkOrder wo1 = [SELECT Status FROM WorkOrder];
    System.assertEquals('Cancelled', wo1.Status);
  }
}
