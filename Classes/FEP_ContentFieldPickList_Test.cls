@isTest
public with sharing class FEP_ContentFieldPickList_Test {
    @isTest
    public static void getDefaultValues(){
        FEP_ContentFieldPickList pickList = new FEP_ContentFieldPickList();
        VisualEditor.DataRow defaultValue = pickList.getDefaultValue();
        Assert.areEqual('FEP_Content1__c', defaultValue.getValue(),'Value Match');
        Assert.areEqual('Content1', defaultValue.getlabel(),'label Match');
    }

    @isTest
    public static void getPickList(){
        FEP_ContentFieldPickList pickList = new FEP_ContentFieldPickList();
        VisualEditor.DynamicPickListRows rows = pickList.getValues();
        Assert.isTrue(rows.size()>0, 'Entry fetched');
        VisualEditor.DataRow dataRow = rows.getDataRows()[0];     
        Assert.areEqual('FEP_Content1__c',dataRow.getValue(),'Value Match');
    }
}