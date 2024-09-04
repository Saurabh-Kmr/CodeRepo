public class GetChannelPartners {
  @InvocableMethod(label='Get Channel Partners')
  public static List<List<PartnerDetailsWrapper>> getChannelPartnerDetails(List<String> sAIds) {
    List<List<PartnerDetailsWrapper>> finalResponse = new List<List<PartnerDetailsWrapper>>();
    List<PartnerDetailsWrapper> responseList = new List<PartnerDetailsWrapper>();
    if (!sAIds.isEmpty()) {
      Set<Id> cancelledWOAccountIds = new Set<Id>();
      Id channelPartnerId;
      Id sunRunAccountId = GetChannelPartners.getSunrunAccount();
      list<ServiceAppointment> sApts = [
        SELECT ParentRecordId, ServiceTerritoryId
        FROM ServiceAppointment
        WHERE id IN :sAIds
        LIMIT 1
      ];
      cancelledWOAccountIds = GetServicePartners.getCancelledPartners(sApts[0].ParentRecordId);
      list<WorkOrder> wo = [
        SELECT id, AssetId, Asset.Servicer__c, Asset.Servicer__r.Partner_Type__c, Asset.Servicer__r.name, AccountId
        FROM WorkOrder
        WHERE id = :sApts[0].ParentRecordId AND Asset.Servicer__r.Partner_Status__c = 'Active'
        LIMIT 1
      ];
      if (!wo.isEmpty()) {
        if (
          !cancelledWOAccountIds.contains(wo[0].Asset.Servicer__c) &&
          wo[0].Asset.Servicer__c != sunRunAccountId &&
          wo[0].Asset.Servicer__r.Partner_Type__c.contains('Channel Partner')
        ) {
          channelPartnerId = wo[0].Asset.Servicer__c;
        }
      }
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

      if (channelPartnerId != null) {
        list<ServiceResource> members = [
          SELECT id, name, AccountId, Account.Partner_Type__c
          FROM ServiceResource
          WHERE AccountId = :channelPartnerId AND isActive = TRUE AND Field_Operations_Team__c = 'Partner'
          LIMIT 1
        ];
        if (!members.isEmpty()) {
          list<ServiceResourceSkill> srSkills = [
            SELECT Id, SkillId, ServiceResourceId
            FROM ServiceResourceSkill
            WHERE
              ServiceResourceId = :members[0].Id
              AND Service_Territory__c = :sApts[0].ServiceTerritoryId
              AND EffectiveStartDate <= TODAY
              AND EffectiveEndDate >= TODAY
          ];
          if (!srSkills.isEmpty()) {
            Set<Id> resourceSkills = new Set<Id>();
            for (ServiceResourceSkill ssr : srSkills) {
              resourceSkills.add(ssr.SkillId);
            }

            if (resourceSkills.containsAll(woSkillsIds) && channelPartnerId != sunRunAccountId) {
              PartnerDetailsWrapper response = new PartnerDetailsWrapper();
              response.partnerName = members[0].name;
              responseList.add(response);
            }
            finalResponse.add(responseList);
          }
        }
      }
    }
    if (!finalResponse.isEmpty()) {
      return finalResponse; // Return the list of responses
    } else {
      return null;
    }
  }

  public static Id getSunrunAccount() {
    List<account> sunrunAccount = [
      SELECT id
      FROM Account
      WHERE Account.name = :System.label.Sunrun_Internal_Default_Account_Name
      LIMIT 1
    ];
    if (!sunrunAccount.isEmpty()) {
      return sunrunAccount[0].Id;
    } else {
      return null;
    }
  }
}
