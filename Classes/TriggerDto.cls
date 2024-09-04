@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class TriggerDto {
  private static Map<Id, Boolean> recurringIds = new Map<Id, Boolean>();

  public class Context {
    public String sobjectName;
    public Boolean isBefore = false;
    public Boolean isAfter = false;
    public Boolean isInsert = false;
    public Boolean isUpdate = false;
    public Boolean isDelete = false;
    public Boolean isUndelete = false;
    public Boolean isBeforeInsert = false;
    public Boolean isAfterInsert = false;
    public Boolean isBeforeUpdate = false;
    public Boolean isAfterUpdate = false;
    public Boolean isBeforeDelete = false;
    public Boolean isAfterDelete = false;
    public Boolean isAfterUndelete = false;

    public Map<Id, SObject> oldMap = new Map<Id, SObject>();
    public Map<Id, SObject> newMap = new Map<Id, SObject>();
    public List<SObject> oldList = new List<SObject>();
    public List<SObject> newList = new List<SObject>();

    public TriggerOperation operation;

    public Context(String sobjName) {
      this(sobjName, TriggerOperation.BEFORE_INSERT);
    }

    public Context(String sobjName, TriggerOperation oper) {
      this.sobjectName = sobjName;
      setFlags(oper);
    }

    public Context() {
      if (!Trigger.isExecuting) {
        return;
      }

      sobjectName = (Trigger.isDelete ? Trigger.old.getSObjectType() : Trigger.new.getSObjectType()).getDescribe().getName();

      oldMap = Trigger.oldMap;
      newMap = Trigger.newMap;
      oldList = Trigger.old;
      newList = Trigger.new;

      setFlags(Trigger.operationType);
    }

    private void setFlags(TriggerOperation oper) {
      operation = oper;

      isBeforeInsert = oper == TriggerOperation.BEFORE_INSERT;
      isAfterInsert = oper == TriggerOperation.AFTER_INSERT;
      isBeforeUpdate = oper == TriggerOperation.BEFORE_UPDATE;
      isAfterUpdate = oper == TriggerOperation.AFTER_UPDATE;
      isBeforeDelete = oper == TriggerOperation.BEFORE_DELETE;
      isAfterDelete = oper == TriggerOperation.AFTER_DELETE;
      isAfterUndelete = oper == TriggerOperation.AFTER_UNDELETE;

      isBefore = isBeforeInsert || isBeforeUpdate || isBeforeDelete;
      isAfter = isAfterInsert || isAfterUpdate || isAfterDelete || isAfterUndelete;
      isInsert = isBeforeInsert || isAfterInsert;
      isUpdate = isBeforeUpdate || isAfterUpdate;
      isDelete = isBeforeDelete || isAfterDelete;
      isUndelete = isAfterUndelete;
    }

    public List<Id> getNewIds() {
      return Ut.getIdList(this.newList);
    }

    public Sobject getOld(Id newId) {
      return oldMap != null ? oldMap.get(newId) : null;
    }

    public Sobject getNew(Id oldId) {
      return newMap != null ? newMap.get(oldId) : null;
    }

    public Boolean isRecurring(Id id) {
      if (recurringIds.containsKey(id)) {
        return true;
      } else {
        recurringIds.put(id, true);
        return false;
      }
    }
  }
}
