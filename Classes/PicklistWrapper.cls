public class PicklistWrapper {
  @AuraEnabled
  @InvocableVariable(Label='label' Description='This is the label of the picklist value')
  public String label;

  @AuraEnabled
  @InvocableVariable(Label='value' Description='This is the value of the picklist value')
  public String value;
  public PicklistWrapper() {
  }
}
