public class GetServicePartners {
  @InvocableMethod(label='Get Service Partners')
  public static List<List<PartnerDetailsWrapper>> getServicePartnerDetails(List<String> sAIds) {
    List<List<PartnerDetailsWrapper>> finalResponse = new List<List<PartnerDetailsWrapper>>();
    List<PartnerDetailsWrapper> responseList = new List<PartnerDetailsWrapper>();
    if (!sAIds.isEmpty()) {
      Set<Id> cancelledWOAccountIds = new Set<Id>();
      list<ServiceAppointment> sApts = [
        SELECT ParentRecordId, ServiceTerritoryId
        FROM ServiceAppointment
        WHERE id = :sAIds[0]
        LIMIT 1
      ];
      WorkOrder wo = [SELECT ServiceTerritoryId FROM WorkOrder WHERE id = :sApts[0].ParentRecordId LIMIT 1];
      cancelledWOAccountIds = GetServicePartners.getCancelledPartners(sApts[0].ParentRecordId);
      list<SkillRequirement> woSkills = [
        SELECT Id, SkillId
        FROM SkillRequirement
        WHERE RelatedRecordId = :sApts[0].ParentRecordId
      ];
      Set<Id> woSkillsIds = new Set<Id>();
      if (!woSkills.isEmpty()) {
        for (SkillRequirement skill : woSkills) {
          woSkillsIds.add(skill.SkillId);
        }
      }
      system.debug('sApts[0].ServiceTerritoryId ==>' + sApts[0].ServiceTerritoryId);
      if (sApts[0].ServiceTerritoryId != null) {
        list<ServiceTerritoryMember> members = [
          SELECT id, ServiceResourceId, ServiceResource.name, ServiceResource.Account.Partner_Type__c
          FROM ServiceTerritoryMember
          WHERE
            ServiceTerritoryId = :sApts[0].ServiceTerritoryId
            AND ServiceResource.Field_Operations_Team__c = 'Partner'
            AND ServiceResource.isActive = TRUE
            AND ServiceResource.Account.Partner_Status__c = 'Active'
            AND ServiceResource.AccountId NOT IN :cancelledWOAccountIds
        ];

        if (!members.isEmpty()) {
          map<Id, string> serviceResourceMap = new Map<Id, string>();
          for (ServiceTerritoryMember stm : members) {
            if (stm.ServiceResource.Account.Partner_Type__c.contains('Service Partner')) {
              serviceResourceMap.put(stm.ServiceResourceId, stm.ServiceResource.name);
            }
          }
          if (!serviceResourceMap.isEmpty()) {
            list<ServiceResourceSkill> srSkills = [
              SELECT Id, SkillId, ServiceResourceId
              FROM ServiceResourceSkill
              WHERE
                ServiceResourceId IN :serviceResourceMap.keySet()
                AND Service_Territory__c = :sApts[0].ServiceTerritoryId
                AND EffectiveStartDate <= TODAY
                AND EffectiveEndDate >= TODAY
            ];
            if (!srSkills.isEmpty()) {
              Map<String, Set<Id>> resourceWithSkills = new Map<String, Set<Id>>();

              for (ServiceResourceSkill skill : srSkills) {
                string resourceName = serviceResourceMap.get(skill.ServiceResourceId);

                if (!resourceWithSkills.containsKey(resourceName)) {
                  resourceWithSkills.put(resourceName, new Set<Id>{ skill.SkillId });
                } else {
                  resourceWithSkills.get(resourceName).add(skill.SkillId);
                }
              }

              if (!resourceWithSkills.isEmpty()) {
                for (String resource : resourceWithSkills.keySet()) {
                  if (resourceWithSkills.get(resource) != null) {
                    if (resourceWithSkills.get(resource).containsAll(woSkillsIds)) {
                      PartnerDetailsWrapper response = new PartnerDetailsWrapper();
                      response.partnerName = resource;
                      responseList.add(response);
                    }
                  }
                }
                finalResponse.add(responseList);
              }
            }
          }
        }
      }
    }

    return finalResponse; // Return the list of responses
  }

  public static Set<Id> getCancelledPartners(Id woID) {
    Set<Id> cancelledWOPartnerIds = new Set<Id>();

    List<WorkOrder> workOrders = [
      SELECT id, caseId
      FROM WorkOrder
      WHERE id = :woID
      LIMIT 1
    ];
    if (!workOrders.isEmpty() && workOrders[0].caseId != null) {
      List<WorkOrder> cancelledWOs = [
        SELECT id, Assigned_Partner__c
        FROM WorkOrder
        WHERE status = 'Cancelled' AND caseId = :workOrders[0].caseId
      ];
      if (!cancelledWOs.isEmpty()) {
        for (WorkOrder wo : cancelledWOs) {
          if (wo.Assigned_Partner__c != null) {
            cancelledWOPartnerIds.add(wo.Assigned_Partner__c);
          }
        }
      }
    }
    return cancelledWOPartnerIds;
  }
}
