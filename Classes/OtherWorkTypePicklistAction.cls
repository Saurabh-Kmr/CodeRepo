public class OtherWorkTypePicklistAction {
  @InvocableMethod(label='Get Other Work Type' description='Returns the Other Work Type Picklist Values' category='Other Work Type Picklist')
  public static List<List<PicklistWrapper>> getOtherWorkType(List<String> category) {
    List<String> inputs = category[0].split(',');
    String typeOfWork = inputs[0];
    String assetType = inputs[1];
    List<List<PicklistWrapper>> pickListValuesList = new List<List<PicklistWrapper>>();
    List<PicklistWrapper> tempPicklistValues = new List<PicklistWrapper>();
    List<Work_Type_Picklist_Setting__mdt> lstWorkTypePicklist = [
      SELECT Id, Other_Work_Type__c
      FROM Work_Type_Picklist_Setting__mdt
      WHERE Asset_Type__c = :assetType AND Type_of_Work__c = :typeOfWork
    ];
    if (lstWorkTypePicklist.isEmpty()) {
      return null;
    } else if (lstWorkTypePicklist[0].Other_Work_Type__c == null) {
      return null;
    } else {
      List<String> otherWorkTypes = lstWorkTypePicklist[0]?.Other_Work_Type__c.split(',');
      for (Integer i = 0; i < otherWorkTypes.size(); i++) {
        PicklistWrapper newPicklistVal = new PicklistWrapper();
        newPicklistVal.label = otherWorkTypes[i];
        newPicklistVal.value = otherWorkTypes[i];
        tempPicklistValues.add(newPicklistVal);
      }
      if (tempPicklistValues.size() > 0) {
        pickListValuesList.add(tempPicklistValues);
        System.debug('pickListValuesList' + pickListValuesList);
        return pickListValuesList;
      } else {
        return null;
      }
    }
  }
}
