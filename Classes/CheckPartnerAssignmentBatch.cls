public with sharing class CheckPartnerAssignmentBatch implements Database.Batchable<sObject> {
  public CheckPartnerAssignmentBatch() {
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'select id,Status,Partner_Job_Assignment_Date__c,ServiceTerritory.OperatingHours.TimeZone,ServiceTerritoryId from WorkORder where Assigned_Partner__c !=null and Status in (\'Open\',\'New\')  Order by Partner_Job_Assignment_Date__c asc';
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<WorkOrder> scope) {
    Integer autoDeclineHours = Integer.valueOf(system.Label.Partner_Job_Auto_Decline_Hours);
    Set<Id> woIds = new Set<Id>();
    List<WorkOrder> updateWOList = new List<WorkOrder>();
    List<ServiceAppointment> updateSAList = new List<ServiceAppointment>();
    for (WorkOrder wotemp : scope) {
      woIds.add(wotemp.Id);
    }

    List<ServiceAppointment> saList = [SELECT id, ParentRecordId FROM serviceappointment WHERE ParentRecordId IN :woIds AND Status = 'On Hold'];

    List<BusinessHours> bhs = [SELECT id, TimeZoneSidKey, IsDefault FROM BusinessHours WHERE Name != 'Default'];

    Map<String, BusinessHours> bhsMap = new Map<String, BusinessHours>();
    BusinessHours temp;
    for (BusinessHours bh : bhs) {
      if (bh.IsDefault) {
        temp = bh;
      }
      bhsMap.put(bh.TimeZoneSidKey, bh);
    }

    Datetime dtNow = datetime.now();

    for (WorkOrder wo : scope) {
      String timzoneName = wo.ServiceTerritory.OperatingHours.TimeZone;

      if (String.isNotEmpty(timzoneName)) {
        if (bhsMap.get(timzoneName) != null) {
          temp = bhsMap.get(timzoneName);
        }
      }

      if (wo.Partner_Job_Assignment_Date__c == null) {
        continue;
      }

      Long diff = BusinessHours.diff(temp.Id, wo.Partner_Job_Assignment_Date__c, dtNow);
      Double diffHours = diff / 3600000;

      if (diffHours > autoDeclineHours) {
        wo.Status = 'Cancelled';
        wo.Cancellation_Reason__c = 'Partner Outside of SLA';
        wo.Declined_Date__c = dtNow;
        wo.Declined_Reason__c = 'Auto-Declined';
        updateSAList.addAll(getSA(saList, wo.Id));
        updateWOList.add(wo);
      }
    }

    if (!updateSAList.IsEmpty()) {
      update updateSAList;
    }

    if (!updateWOList.IsEmpty()) {
      update updateWOList;
    }
  }

  public void finish(Database.BatchableContext BC) {
  }

  private List<ServiceAppointment> getSA(List<ServiceAppointment> saLst, Id woId) {
    List<ServiceAppointment> returnSAList = new List<ServiceAppointment>();
    for (ServiceAppointment sa : saLst) {
      if (sa.ParentRecordId == woId) {
        sa.Status = 'Cancelled';
        returnSAList.add(sa);
      }
    }

    return returnSAList;
  }
}
