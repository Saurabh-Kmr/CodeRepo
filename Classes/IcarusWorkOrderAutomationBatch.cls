public class IcarusWorkOrderAutomationBatch implements Database.Batchable<sObject>, Database.Stateful {
  public String Query;
  public list<App_Log__c> logsList = new List<App_Log__c>();
  public map<String, System_Health__c> mapOfErrorCodeVsSystemHealthRecord = new Map<String, System_Health__c>();
  public list<Case> caseListforPartnerIdentification = new List<Case>();
  public static Id fsRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByName().get('Field Service').getRecordTypeId();
  public map<String, String> manufactureNameVsSkillIdMap = new Map<String, String>();
  public IcarusWorkOrderAutomationBatch() {
    query =
      'Select id,ServiceContractId,Service_Territory__c,System_State__c,' +
      +'Asset.Location.VisitorAddress.Country, Asset.Location.VisitorAddress.City, Description, Asset.Location.VisitorAddress.PostalCode,' +
      'IsEscalated, Asset.Servicer__c, Asset.Location.VisitorAddress.State, Asset.Location.VisitorAddress.Street, Subject, ' +
      'assetId, Asset.Product2.Manufacturer_Name__c, Asset.Product2Id,AccountId ' +
      'from Case where Work_Order_Automation_Status__c=null AND ' +
      System.Label.Icarus_Case_Filter;

    set<String> manufactureSkillsSet = new Set<String>();
    map<String, String> skillNameVsSkillIdMap = new Map<String, String>();
    list<Manufacturer_Skill__mdt> manufectureSkillList = [SELECT id, Skill__c, Manufacturer_Name__c FROM Manufacturer_Skill__mdt];
    if (manufectureSkillList != null && manufectureSkillList.size() > 0) {
      for (Manufacturer_Skill__mdt skillMdt : manufectureSkillList) {
        manufactureSkillsSet.add(skillMdt.Skill__c);
      }
      list<Skill> skillsList = [SELECT id, MasterLabel FROM Skill WHERE MasterLabel IN :manufactureSkillsSet];
      for (Skill skillRec : skillsList) {
        skillNameVsSkillIdMap.put(skillRec.MasterLabel, skillRec.Id);
      }
      for (Manufacturer_Skill__mdt skillMdt : manufectureSkillList) {
        manufactureNameVsSkillIdMap.put(skillMdt.Manufacturer_Name__c, skillNameVsSkillIdMap.get(skillMdt.Skill__c));
      }
    }

    list<System_Health__c> systemHealthRecs = [
      SELECT
        Id,
        Name,
        System_State__c,
        Work_Type__r.Work_Description__c,
        Work_Type__r.Number_of_Technicians__c,
        Work_Type__r.Customer_Presence_Needed__c,
        Work_Type__c,
        Work_Type__r.EstimatedDuration
      FROM System_Health__c
    ];
    if (systemHealthRecs != null && systemHealthRecs.size() > 0) {
      for (System_Health__c sysHealthrec : systemHealthRecs) {
        mapOfErrorCodeVsSystemHealthRecord.put(sysHealthrec.System_State__c, sysHealthrec);
      }
    }
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<Case> caseRecords) {
    map<String, WorkOrder> caseidVsWorkOrderDetailMap = new Map<String, WorkOrder>();
    map<String, list<ServiceAppointment>> mapOfWorkOrderIdVsSAList = new Map<String, list<ServiceAppointment>>();
    try {
      list<WorkOrder> woToInsert = new List<WorkOrder>();

      for (Case cseRec : caseRecords) {
        if (mapOfErrorCodeVsSystemHealthRecord.containsKey(cseRec.System_State__c)) {
          WorkOrder wOrder = IcarusWorkOrderAutomationBatch.createWorkOrder(cseRec, mapOfErrorCodeVsSystemHealthRecord);
          caseidVsWorkOrderDetailMap.put(cseRec.Id, wOrder);
        } else {
          cseRec.Work_Order_Automation_Status__c = 'Error Code Not Found';
        }
      }
      Database.SaveResult[] results = Database.insert(caseidVsWorkOrderDetailMap.values(), false);
      if (results != null) {
        for (Database.SaveResult result : results) {
          if (!result.isSuccess()) {
            Database.Error[] errs = result.getErrors();
            String errMsg = '';
            for (Database.Error err : errs) {
              errMsg += err.getMessage() + '\n';
            }
            App_Log__c appLog = new App_Log__c();
            appLog = createAppLog('Icarus Work orrder creation Batch', 'Work Order Insert', '', 'Error', errMsg);
            logsList.add(appLog);
          }
        }
      }

      list<SkillRequirement> skillRequirementRecords = new List<SkillRequirement>();
      for (Case cseRec : caseRecords) {
        WorkOrder wOrder = caseidVsWorkOrderDetailMap.get(cseRec.Id);
        if (wOrder != null) {
          if (wOrder.Id != null && cseRec.Asset.Product2Id != null && cseRec.Asset.Product2.Manufacturer_Name__c != null) {
            String skillId = manufactureNameVsSkillIdMap.get(cseRec.Asset.Product2.Manufacturer_Name__c);
            SkillRequirement sReq = IcarusWorkOrderAutomationBatch.createManufacturingSkills(wOrder.Id, skillId);
            skillRequirementRecords.add(sReq);
          }

          if (wOrder.Id != null) {
            cseRec.Work_Order_Automation_Status__c = 'Under partner Identification';
            mapOfWorkOrderIdVsSAList.put(
              wOrder.Id,
              IcarusWorkOrderAutomationBatch.createServiceAppointment(cseRec, wOrder, mapOfErrorCodeVsSystemHealthRecord)
            );
          }
        }
      }
      if (skillRequirementRecords != null && skillRequirementRecords.size() > 0) {
        insert skillRequirementRecords;
      }

      list<ServiceAppointment> finallistOfAppointmentsToInsert = new List<ServiceAppointment>();
      for (List<ServiceAppointment> saList : mapOfWorkOrderIdVsSAList.values()) {
        finallistOfAppointmentsToInsert.addAll(saList);
      }
      results = Database.insert(finallistOfAppointmentsToInsert, false);
      list<WorkOrder> woToDelete = new List<WorkOrder>();
      if (results != null) {
        for (Integer index = 0; index < results.size(); index++) {
          Database.SaveResult result = results[index];
          if (!result.isSuccess()) {
            Database.Error[] errs = result.getErrors();
            String errMsg = '';
            for (Database.Error err : errs) {
              errMsg += err.getMessage() + '\n';
            }
            App_Log__c appLog = new App_Log__c();
            appLog = createAppLog('Icarus Work orrder creation Batch', 'Work Order Insert', '', 'Error', errMsg);
            logsList.add(appLog);
            woToDelete.add(new WorkOrder(id = finallistOfAppointmentsToInsert[index].Work_Order__c));
          }
        }
      }

      results = Database.update(caseRecords, false);
      if (results != null) {
        for (Database.SaveResult result : results) {
          if (!result.isSuccess()) {
            Database.Error[] errs = result.getErrors();
            String errMsg = '';
            for (Database.Error err : errs) {
              errMsg += err.getMessage() + '\n';
            }
            App_Log__c appLog = new App_Log__c();
            appLog = createAppLog('Icarus Work orrder creation Batch', 'Update Case', '', 'Error', errMsg);
            logsList.add(appLog);
          }
        }
      }

      if (woToDelete != null && woToDelete.size() > 0) {
        List<ProductRequest> productRequestList = [SELECT id FROM ProductRequest WHERE WorkOrderId IN :woToDelete];
        if (productRequestList != null && productRequestList.size() > 0) {
          delete productRequestList;
        }
        delete woToDelete;
      }
    } catch (Exception ex) {
      App_Log__c appLog = new App_Log__c();
      appLog = createAppLog('Icarus Work orrder creation Batch', 'Work Order Insert', '', 'Error', ex.getMessage());
      logsList.add(appLog);
    }
  }

  public void finish(Database.BatchableContext BC) {
    insert logsList;
    System.scheduleBatch(new IcarusPartnerIdentificationBatch(), 'Icarus Work Order Automation Job', 30, 200);
  }

  public static WorkOrder createWorkOrder(Case cseRec, map<String, System_Health__c> mapOfErrorCodeVsSystemHealthRecord) {
    WorkOrder wOrder = new WorkOrder();
    worder.RecordTypeId = fsRecordTypeId;
    worder.accountId = cseRec.AccountId;
    worder.duration = mapOfErrorCodeVsSystemHealthRecord.get(cseRec.System_State__c).Work_Type__r.EstimatedDuration;
    worder.Status = 'Open';
    worder.worktypeId = mapOfErrorCodeVsSystemHealthRecord.get(cseRec.System_State__c).Work_Type__c;
    worder.CaseId = cseRec.Id;
    worder.Subject = cseRec.Subject;
    worder.Description = cseRec.Subject;
    worder.Priority = cseRec.isEscalated ? 'Medium' : 'Low';
    worder.ServiceContractId = cseRec.ServiceContractId;
    worder.ServiceTerritoryId = cseRec.Service_Territory__c;
    worder.street = cseRec.Asset.Location.VisitorAddress.Street;
    worder.city = cseRec.Asset.Location.VisitorAddress.City;
    worder.state = cseRec.Asset.Location.VisitorAddress.State;
    worder.postalCode = cseRec.Asset.Location.VisitorAddress.PostalCode;
    worder.country = cseRec.Asset.Location.VisitorAddress.Country;
    worder.Servicer__c = cseRec.Asset.Servicer__c;
    worder.AssetId = cseRec.AssetId;
    return wOrder;
  }

  public static list<ServiceAppointment> createServiceAppointment(
    Case cseRec,
    WorkOrder woDetail,
    map<String, System_Health__c> mapOfErrorCodeVsSystemHealthRecord
  ) {
    List<ServiceAppointment> saToInsert = new List<ServiceAppointment>();
    ServiceAppointment newSA = new ServiceAppointment();
    newSA.Work_Order__c = woDetail.Id;
    newSA.ParentRecordId = woDetail.Id;
    newSa.Account__c = cseRec.AccountId;
    newSA.Asset__c = cseRec.AssetId;
    newSA.Customer_Presence_Needed__c = mapOfErrorCodeVsSystemHealthRecord.get(cseRec.System_State__c).Work_Type__r.Customer_Presence_Needed__c;
    newSA.duration = mapOfErrorCodeVsSystemHealthRecord.get(cseRec.System_State__c).Work_Type__r.EstimatedDuration;
    newSA.DurationType = 'Minutes';
    saToInsert.add(newSA);
    return saToInsert;
  }

  public static SkillRequirement createManufacturingSkills(String woDetailId, String skillId) {
    SkillRequirement skillReq = new SkillRequirement();
    skillReq.skillId = skillId;
    skillReq.RelatedRecordId = woDetailId;
    return skillReq;
  }

  public static App_Log__c createAppLog(String module, String action, String caseId, String logType, String msgBody) {
    App_Log__c appLog = new App_Log__c(
      Module__c = module,
      Action__c = action,
      Record_id__c = caseId,
      Type__c = logType,
      Message__c = msgBody,
      Start_Time__c = system.now()
    );

    return appLog;
  }
}
