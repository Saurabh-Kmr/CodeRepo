public with sharing class SkillsRequirementController {
  @AuraEnabled(cacheable=true)
  public static List<String> getRequiredSkills(String recordId) {
    return SkillsRequirementService.OBJ.getRequiredSkills(recordId);
  }
}
