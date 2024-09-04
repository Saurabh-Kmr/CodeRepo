public with sharing class ImageCaptureController {
  @AuraEnabled(cacheable=true)
  public static List<ContentVersion> getContentDocumentId(String contentVersionId) {
    return [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :contentVersionId
      WITH SECURITY_ENFORCED
    ];
  }

  @AuraEnabled
  public static List<ContentVersion> getContentVersionId(String uniqueCvId) {
    return [
      SELECT Id
      FROM ContentVersion
      WHERE ReasonForChange = :uniqueCvId
      WITH SECURITY_ENFORCED
    ];
  }

  @AuraEnabled
  public static void createContentDocumentLink(String contentDocumentId, String imageType, String recordId) {
    Boolean isErrorFound = false;
    ContentDocumentLink cdl = new ContentDocumentLink(LinkedEntityId = recordId, ContentDocumentId = contentDocumentId, ShareType = 'V');
    Database.SaveResult[] srList = Database.insert(new List<ContentDocumentLink>{ cdl }, false);
    // Iterate through each returned result
    for (Database.SaveResult sr : srList) {
      if (sr.isSuccess()) {
        // Operation was successful, so get the ID of the record that was processed
      } else {
        // Operation failed, so get all errors
        for (Database.Error err : sr.getErrors()) {
          isErrorFound = true;
        }
      }
    }
    if (!isErrorFound) {
      WorkOrderLineItem woli = ImageCaptureController.getWorkOrderDetails(recordId);
      if (woli != null && woli.New_Meter_Reading_kWh__c != null && woli.WorkType.Name == System.Label.Meter_Read_Work_Type_Label) {
        woli.status = 'Closed';
        update woli;
      }
    }
  }

  @AuraEnabled
  public static WorkOrderLineItem getWorkOrderDetails(String recordId) {
    try {
      WorkOrderLineItem workOrderLIRec = [
        SELECT Id, WorkOrder.Status, Status, WorkType.Name, New_Meter_Reading_kWh__c
        FROM WorkOrderLineItem
        WHERE Id = :recordId
        LIMIT 1
      ];
      return workOrderLIRec;
    } catch (Exception ex) {
      return null;
    }
  }
}
