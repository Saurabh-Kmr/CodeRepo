public with sharing class SkillsRequirementService {
  public static final SkillsRequirementService OBJ = new SkillsRequirementService();

  public List<String> getRequiredSkills(String recordId) {
    List<PendingServiceRouting> psrList = [
      SELECT Id
      FROM PendingServiceRouting
      WHERE WorkItemId = :recordId
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    Set<Id> skillIdSet = new Set<Id>();

    if (!psrList.isEmpty()) {
      List<SkillRequirement> skillRequirementList = [
        SELECT SkillId
        FROM SkillRequirement
        WHERE RelatedRecordId = :psrList[0].Id
      ];

      skillIdSet = Ut.getIdSet(skillRequirementList, 'SkillId');
    } else {
      List<AgentWork> agentWorkList = [
        SELECT Id
        FROM AgentWork
        WHERE WorkItemId = :recordId
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];

      if (!agentWorkList.isEmpty()) {
        List<AgentWorkSkill> agentWorkSkillList = [SELECT SkillId FROM AgentWorkSkill WHERE AgentWorkId = :agentWorkList[0].Id];

        skillIdSet = Ut.getIdSet(agentWorkSkillList, 'SkillId');
      }
    }

    List<Skill> skillList = [SELECT MasterLabel FROM Skill WHERE Id IN :skillIdSet ORDER BY MasterLabel];

    return Ut.getStringList(skillList, 'MasterLabel');
  }
}
