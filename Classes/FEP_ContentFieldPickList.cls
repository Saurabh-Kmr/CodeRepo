/*------------------------------------------------------------
Author:        Saurabh Kumar
Company:       Salesforce
Description:   Controller Class to display fields as picklist in site editor
Inputs:                      
Test Class:    FEP_ContentFieldPickList_Test
History
15/03/2024      Saurabh Kumar    New Class Created
------------------------------------------------------------*/
global class FEP_ContentFieldPickList extends VisualEditor.DynamicPickList{
    
    /*------------------------------------------------------------
    Author:        Saurabh Kumar
    Company:       Salesforce
    Description:   Function returns default value
    Inputs:        
    Returns:       VisualEditor.DataRow- Picklist
               
    History
   15/03/2024      Saurabh Kumar    New Function 
    ------------------------------------------------------------*/ 
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Content1', 'FEP_Content1__c');
        return defaultValue;
    }

    /*------------------------------------------------------------
    Author:        Saurabh Kumar
    Company:       Salesforce
    Description:   Function returns picklist values to select based on custom label FEP_PersonalizedContentFields
    Inputs:        
    Returns:       VisualEditor.DynamicPickListRows- Picklist
               
    History
   15/03/2024      Saurabh Kumar    New Function 
    ------------------------------------------------------------*/ 
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        String fieldCustomLabel = System.Label.FEP_PersonalizedContentFields;
        List<String> fieldNames = fieldCustomLabel.split(';');
        if(!fieldNames.isEmpty()){
            for(String fields:fieldNames){
                List<String> valueCombo = fields.split(':');
                VisualEditor.DataRow value = new VisualEditor.DataRow(valueCombo[0].trim(), valueCombo[1].trim());
                myValues.addRow(value);
            }
        }
        return myValues;
    }
}