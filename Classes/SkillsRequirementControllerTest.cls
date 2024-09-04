@isTest
public with sharing class SkillsRequirementControllerTest {
  @testSetup
  static void setup() {
    List<Case> caseList = new List<Case>();
    Case caseRecPsr = new Case(Subject = 'SkillsRequirementControllerPsrTest', Creation_Reason__c = 'Damage', Customer_Concern__c = 'CC');
    Case caseRecAw = new Case(Subject = 'SkillsRequirementControllerAwTest', Creation_Reason__c = 'Damage', Customer_Concern__c = 'CC');
    caseList.add(caseRecPsr);
    caseList.add(caseRecAw);
    insert caseList;

    Skill skill = [SELECT Id, MasterLabel FROM Skill WHERE MasterLabel = 'Collections'];
    ServiceChannel serviceChannel = [SELECT Id FROM ServiceChannel WHERE DeveloperName = 'Case' LIMIT 1];

    // Create test data for PendingServiceRouting and SkillRequirement
    PendingServiceRouting psr = new PendingServiceRouting(
      CapacityWeight = 1,
      RoutingType = 'SkillsBased',
      RoutingModel = 'MostAvailable',
      ServiceChannelId = serviceChannel.Id,
      RoutingPriority = 1,
      isReadyForRouting = false,
      WorkItemId = caseRecPsr.id
    );
    insert psr;

    SkillRequirement skillReq = new SkillRequirement(RelatedRecordId = psr.Id, SkillId = skill.Id);
    insert skillReq;
  }
  @isTest
  static void testGetRequiredSkillsPsr() {
    Case caseRecPsr = [SELECT Id FROM Case WHERE Subject = 'SkillsRequirementControllerPsrTest'];
    Test.startTest();
    List<String> requiredSkills = SkillsRequirementController.getRequiredSkills(caseRecPsr.Id);
    Test.stopTest();
    System.assertEquals(1, requiredSkills.size(), 'Expected 1 required skill');
    System.assertEquals('Collections', requiredSkills[0], 'Expected the required skill to be Collections');
  }

  @isTest
  static void testGetRequiredSkillsAw() {
    Case caseRecAw = [SELECT Id FROM Case WHERE Subject = 'SkillsRequirementControllerAwTest'];
    Test.startTest();
    List<String> requiredSkills = SkillsRequirementController.getRequiredSkills(caseRecAw.Id);
    Test.stopTest();
    System.assertEquals(0, requiredSkills.size(), 'Expected 0 required skill');
  }
}
