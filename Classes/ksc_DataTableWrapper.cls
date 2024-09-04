/*********************************************************
*Class        :  DataTableWrapper
*Author       :  Neeti
*Description  :  Warapper class for Lightning Data-Table
*********************************************************/
public class ksc_DataTableWrapper {
    @AuraEnabled
    public List<DataTableColumnWrapper> columns {get;set;}
    @AuraEnabled
	public Object rowData {get;set;}
    @AuraEnabled
    public Boolean isNoSelect{get;set;}    
    @AuraEnabled
    public Boolean isMultiSelect{get;set;}  
    @AuraEnabled
    public Boolean isRadioSelect{get;set;}  
    
    
	
    public ksc_DataTableWrapper(){
        this.isNoSelect = false;
        this.isRadioSelect = false;
        this.isMultiSelect = false;
    }
    
    public class DataTableColumnWrapper {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Boolean wrapText {get;set;} 
        @AuraEnabled
        public TypeAttributeWrapper typeAttributes {get;set;}
        @AuraEnabled
        public String strAdditionalText {get;set;}
        
        public DataTableColumnWrapper(String label, String fieldName, String type)
        {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;     
            this.typeAttributes = null;
            this.strAdditionalText ='';
            this.wrapText = false;
        }
        public DataTableColumnWrapper(){
            this.label = '';
            this.fieldName = '';
            this.type ='';   
        }
    }
    public class DataTableActionWrapper {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String name {get;set;}
        public DataTableActionWrapper(String label, String name)
        {
            this.label = label;
            this.name = name;
        }
        public DataTableActionWrapper(){
            this.label = '';
            this.name = '';
        }
    }
     public class TypeAttributeWrapper {
        @AuraEnabled
        public List<DataTableActionWrapper> rowActions {get;set;}

        @AuraEnabled public TypeAttributeInnerWrapper label {get;set;}
        @AuraEnabled public String target {get;set;}
        public TypeAttributeWrapper(List<DataTableActionWrapper> actions)
        {
            this.rowActions = actions;
        }
        public TypeAttributeWrapper(TypeAttributeInnerWrapper label,String target)
        {
            this.label = label;
            this.target = target;
        }
        
        public TypeAttributeWrapper(){
            this.label = null;
            this.target = '';
        }
    }

    public class TypeAttributeInnerWrapper{
        @AuraEnabled public String fieldName {get;set;}
        public TypeAttributeInnerWrapper(String fieldName){
            this.fieldName = fieldName;
        }
    }

}