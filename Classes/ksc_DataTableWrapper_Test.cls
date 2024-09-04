/*********************************************************
*Class        :  ksc_DataTableWrapper_Test
*Author       :  Neeti Panda
*Description  :  Parser class for Datatable
*********************************************************/
@isTest
public class ksc_DataTableWrapper_Test {

    /****************************************************
* @Description - Tests the Datatable wrapper classes   
*****************************************************/
    @isTest
    public static void kscDataTableTest(){
        User tUser = ksc_TestDataFactory.createCS60UserWithPermissions();
        ksc_DataTableWrapper data = new ksc_DataTableWrapper();
        System.runAs(tUser){
            Test.startTest();
            ksc_DataTableWrapper.DataTableActionWrapper action = new ksc_DataTableWrapper.DataTableActionWrapper();
            ksc_DataTableWrapper.DataTableActionWrapper action1 = new ksc_DataTableWrapper.DataTableActionWrapper('test','test');
            List<ksc_DataTableWrapper.DataTableActionWrapper> actions = new List<ksc_DataTableWrapper.DataTableActionWrapper>();
            actions.add(action);
            actions.add(action1);
            ksc_DataTableWrapper.TypeAttributeInnerWrapper innerWrapper = new ksc_DataTableWrapper.TypeAttributeInnerWrapper('test');
            ksc_DataTableWrapper.TypeAttributeWrapper type1 = new ksc_DataTableWrapper.TypeAttributeWrapper(actions);
            ksc_DataTableWrapper.TypeAttributeWrapper type2 = new ksc_DataTableWrapper.TypeAttributeWrapper(innerWrapper,'test');
            ksc_DataTableWrapper.TypeAttributeWrapper type3 = new ksc_DataTableWrapper.TypeAttributeWrapper();
            
            ksc_DataTableWrapper.DataTableColumnWrapper col = new ksc_DataTableWrapper.DataTableColumnWrapper();
            ksc_DataTableWrapper.DataTableColumnWrapper col1 = new ksc_DataTableWrapper.DataTableColumnWrapper('test','test','test');
            col1.typeAttributes = type1;
           	col1.typeAttributes = type2;
            col1.typeAttributes = type3;
            
            List<ksc_DataTableWrapper.DataTableColumnWrapper> cols = new List<ksc_DataTableWrapper.DataTableColumnWrapper>();
            cols.add(col);
            cols.add(col1);
            data.columns= cols;
            data.rowData = col;
            Test.stopTest();
        }
        System.assertNotEquals(NULL, data, 'Creating a User record is failed.');
    }
}