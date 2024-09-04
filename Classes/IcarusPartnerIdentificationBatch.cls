public class IcarusPartnerIdentificationBatch implements Database.Batchable<sObject>, Database.Stateful {
  public list<App_Log__c> logsList = new List<App_Log__c>();
  public String workOrderAutomationStatus = 'Under partner Identification';
  public String Query;
  public IcarusPartnerIdentificationBatch() {
    query =
      'Select id,ServiceContractId,Service_Territory__c,' +
      +'Asset.Location.VisitorAddress.Country, Asset.Location.VisitorAddress.City, Description, Asset.Location.VisitorAddress.PostalCode,' +
      'IsEscalated, Asset.Servicer__c, Asset.Location.VisitorAddress.State, Asset.Location.VisitorAddress.Street, Subject, ' +
      'assetId, Asset.Product2.Manufacturer_Name__c, Asset.Product2Id,AccountId ' +
      'from Case where Work_Order_Automation_Status__c=:workOrderAutomationStatus and ' +
      System.Label.Icarus_Case_Filter;
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<Case> caseRecords) {
    try {
      map<String, list<ServiceAppointment>> mapOfWorkOrderIdVsSAList = new Map<String, list<ServiceAppointment>>();
      map<String, String> mapOfWorkOrderIdVsCaseId = new Map<String, String>();
      map<String, set<Id>> workOrderIdVsSkillRequirementIds = new Map<String, set<Id>>();
      list<WorkOrder> workOrderEligibleForAppointmentCreation = new List<WorkOrder>();
      map<String, ServiceResource> partnerIdVsServiceResource = new Map<String, ServiceResource>();
      set<String> partnerIds = new Set<String>();
      set<String> serviceTerritoryIds = new Set<String>();
      Id sunRunAccountId = GetChannelPartners.getSunrunAccount();

      list<WorkOrder> workOrderToUpdate = new List<WorkOrder>();
      list<Case> caseRecordsToUpdate = new List<Case>();
      list<WorkOrder> wOrderList = [
        SELECT
          id,
          AssetId,
          Asset.Servicer__c,
          Asset.Servicer__r.Partner_Type__c,
          case.AccountId,
          case.AssetId,
          worktype.Customer_Presence_Needed__c,
          worktype.Number_of_Technicians__c,
          worktype.EstimatedDuration,
          ServiceTerritoryId,
          Asset.Servicer__r.name,
          AccountId,
          caseId,
          Asset.Servicer__r.Partner_Status__c,
          (SELECT id, ServiceTerritoryId FROM ServiceAppointments),
          (SELECT id, SkillId FROM SkillRequirements)
        FROM Workorder
        WHERE caseId IN :caseRecords
      ];

      for (WorkOrder wOrder : wOrderList) {
        partnerIds.add(wOrder.Asset.Servicer__c);
        serviceTerritoryIds.add(wOrder.ServiceTerritoryId);
      }

      for (ServiceResource member : [
        SELECT
          id,
          name,
          AccountId,
          Account.Partner_Type__c,
          (
            SELECT Id, SkillId, ServiceResourceId
            FROM ServiceResourceSkills
            WHERE EffectiveStartDate <= TODAY AND EffectiveEndDate >= TODAY AND Service_Territory__c IN :serviceTerritoryIds
          ),
          (
            SELECT Id, ServiceTerritoryId, ServiceResourceId
            FROM ServiceTerritories
            WHERE EffectiveStartDate <= TODAY AND EffectiveEndDate >= TODAY AND ServiceTerritoryId IN :serviceTerritoryIds
          )
        FROM ServiceResource
        WHERE AccountId IN :partnerIds AND isActive = TRUE AND Field_Operations_Team__c = 'Partner'
      ]) {
        partnerIdVsServiceResource.put(member.AccountId, member);
      }

      for (WorkOrder woData : wOrderList) {
        workOrderIdVsSkillRequirementIds.put(woData.Id, new Set<Id>());
        for (SkillRequirement sreq : woData.SkillRequirements) {
          workOrderIdVsSkillRequirementIds.get(woData.Id).add(sreq.skillId);
        }
        mapOfWorkOrderIdVsCaseId.put(woData.Id, woData.caseid);
        if (
          woData.Asset.Servicer__r.Partner_Status__c != 'Active' ||
          woData.Asset.Servicer__c == sunRunAccountId ||
          !woData.Asset.Servicer__r.Partner_Type__c.contains('Channel Partner') ||
          !partnerIdVsServiceResource.containsKey(woData.Asset.Servicer__c)
        ) {
          if (woData.WorkType.Number_of_Technicians__c != null && woData.WorkType.Number_of_Technicians__c == 2) {
            workOrderEligibleForAppointmentCreation.add(woData);
            mapOfWorkOrderIdVsSAList.put(woData.Id, woData.ServiceAppointments);
          }
        } else if (partnerIdVsServiceResource.containsKey(woData.Asset.Servicer__c)) {
          List<ServiceResourceSkill> skillsList = partnerIdVsServiceResource.get(woData.Asset.Servicer__c).ServiceResourceSkills;
          List<ServiceTerritoryMember> stmList = partnerIdVsServiceResource.get(woData.Asset.Servicer__c).ServiceTerritories;
          if (skillsList == null || skillsList.size() == 0 || stmList == null || stmList.size() == 0) {
            workOrderEligibleForAppointmentCreation.add(woData);
            mapOfWorkOrderIdVsSAList.put(woData.Id, woData.ServiceAppointments);
          } else {
            Set<Id> resourceSkills = new Set<Id>();
            Set<Id> territoryIdsOfSTMs = new Set<Id>();
            if (skillsList != null) {
              for (ServiceResourceSkill ssr : skillsList) {
                resourceSkills.add(ssr.SkillId);
              }
            }
            if (stmList != null) {
              for (ServiceTerritoryMember stm : stmList) {
                territoryIdsOfSTMs.add(stm.ServiceTerritoryId);
              }
            }
            if (
              resourceSkills.containsAll(workOrderIdVsSkillRequirementIds.get(woData.Id)) &&
              woData.Asset.Servicer__c != sunRunAccountId &&
              territoryIdsOfSTMs != null &&
              territoryIdsOfSTMs.contains(woData.ServiceTerritoryId)
            ) {
              woData.Assigned_Partner__c = woData.Asset.Servicer__c;
              workOrderToUpdate.add(wodata);
              caseRecordsToUpdate.add(new Case(Id = woData.caseId, Work_Order_Automation_Status__c = 'Processed'));
            } else {
              if (woData.WorkType.Number_of_Technicians__c != null && woData.WorkType.Number_of_Technicians__c == 2) {
                workOrderEligibleForAppointmentCreation.add(woData);
                mapOfWorkOrderIdVsSAList.put(woData.Id, woData.ServiceAppointments);
              }
            }
          }
        }
      }

      list<ServiceAppointment> saListtoInsert = new List<ServiceAppointment>();
      for (WorkOrder woData : workOrderEligibleForAppointmentCreation) {
        ServiceAppointment saData = IcarusPartnerIdentificationBatch.createServiceAppointment(woData);
        mapOfWorkOrderIdVsSAList.get(woData.Id).add(saData);
        saListtoInsert.add(saData);
      }
      Database.SaveResult[] results = Database.insert(saListtoInsert, false);

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
            appLog = IcarusWorkOrderAutomationBatch.createAppLog(
              'Icarus Partner Identification Batch',
              'Service Appointment Insert',
              '',
              'Error',
              errMsg
            );
            logsList.add(appLog);
            String failedCaseId = mapOfWorkOrderIdVsCaseId.get(saListtoInsert[index].Work_Order__c);
          } else {
            String processedCaseId = mapOfWorkOrderIdVsCaseId.get(saListtoInsert[index].Work_Order__c);
            caseRecordsToUpdate.add(new Case(Id = processedCaseId, Work_Order_Automation_Status__c = 'Processed'));
          }
        }
      }

      list<FSL__Time_Dependency__c> appointmentDependencyList = new List<FSL__Time_Dependency__c>();
      for (String workOrderId : mapOfWorkOrderIdVsSAList.keySet()) {
        List<ServiceAppointment> saList = mapOfWorkOrderIdVsSAList.get(workOrderId);
        if (saList.size() == 2 && saList[1].Id != null) {
          FSL__Time_Dependency__c dependencyRec = IcarusPartnerIdentificationBatch.createAppointmentDependency(saList[0].Id, saList[1].Id);
          appointmentDependencyList.add(dependencyRec);
        }
      }
      insert appointmentDependencyList;

      if (workOrderToUpdate != null && workOrderToUpdate.size() > 0) {
        update workOrderToUpdate;

        List<ServiceAppointment> saList = [SELECT Id, status, Hold_Notes__c FROM ServiceAppointment WHERE Work_Order__c IN :workOrderToUpdate];
        for (ServiceAppointment saRecord : saList) {
          saRecord.Status = 'On Hold';
          saRecord.Hold_Notes__c = 'Assigned To Partner';
        }
        update saList;
      }

      update caseRecordsToUpdate;
    } catch (Exception ex) {
      App_Log__c appLog = new App_Log__c();
      appLog = IcarusWorkOrderAutomationBatch.createAppLog(
        'Icarus Partner Identification Batch',
        'Service Appointment Creation',
        '',
        'Error',
        ex.getMessage()
      );
      logsList.add(appLog);
    }
  }

  public void finish(Database.BatchableContext BC) {
    insert logsList;
  }

  public static FSL__Time_Dependency__c createAppointmentDependency(String SA1Id, String SA2Id) {
    FSL__Time_Dependency__c dependency = new FSL__Time_Dependency__c();
    dependency.FSL__Dependency__c = 'Same Start';
    dependency.FSL__Root_Service_Appointment__c = SA1Id;
    dependency.FSL__Service_Appointment_1__c = SA1Id;
    dependency.FSL__Service_Appointment_2__c = SA2Id;
    return dependency;
  }

  public static ServiceAppointment createServiceAppointment(WorkOrder woDetail) {
    ServiceAppointment newSA = new ServiceAppointment();
    newSA.Work_Order__c = woDetail.Id;
    newSA.ParentRecordId = woDetail.Id;
    newSa.Account__c = woDetail.case.AccountId;
    newSA.Asset__c = woDetail.case.AssetId;
    newSA.Customer_Presence_Needed__c = woDetail.worktype.Customer_Presence_Needed__c;
    newSA.duration = woDetail.worktype.EstimatedDuration;
    newSA.DurationType = 'Minutes';
    return newSA;
  }
}
