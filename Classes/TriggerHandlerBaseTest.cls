@IsTest
public class TriggerHandlerBaseTest {
  @IsTest
  static void testCls() {
    // there is nothing to test in this class as all are empty
    // methods so add these to get coverage
    TriggerHandlerBase cls = new TriggerHandlerBase();
    cls.beforeInsert(null);
    cls.afterInsert(null);
    cls.beforeUpdate(null);
    cls.afterUpdate(null);
    cls.beforeDelete(null);
    cls.afterDelete(null);
    cls.afterUndelete(null);
  }
}
