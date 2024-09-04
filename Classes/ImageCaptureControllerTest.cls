@isTest
private class ImageCaptureControllerTest {
  @isTest
  static void createContentDocumentLinkTest() {
    ContentVersion contentVersion = new ContentVersion(
      Title = 'a picture',
      PathOnClient = 'Pic.jpg',
      VersionData = Blob.valueOf('Test Content'),
      ReasonForChange = 'test123',
      IsMajorVersion = true
    );
    insert contentVersion;
    WorkOrder testWO = new WorkOrder(Subject = 'Test WO');
    insert testWO;
    WorkOrderLineItem testWOLI = new WorkOrderLineItem(WorkOrderId = testWO.Id);
    insert testWOLI;
    List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

    //create ContentDocumentLink  record
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.LinkedEntityId = testWOLI.Id;
    cdl.ContentDocumentId = documents[0].Id;
    cdl.ShareType = 'V';
    cdl.Visibility = 'AllUsers';
    insert cdl;
    List<ContentVersion> lstContentVersion = ImageCaptureController.getContentDocumentId(contentVersion.Id);
    List<ContentVersion> lstContentVersion1 = ImageCaptureController.getContentVersionId('test123');
    ImageCaptureController.createContentDocumentLink(documents[0].Id, 'JPEG', testWOLI.Id);
    WorkOrderLineItem testWOLI1 = ImageCaptureController.getWorkOrderDetails(testWOLI.Id);
  }
}
