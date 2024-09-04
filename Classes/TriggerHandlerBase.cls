/**
 * Extend this class and override only the required lifecycle methods. Note that
 * lifecycle methods are called only if trigger is enabled for current tx/user
 */
@SuppressWarnings('PMD.EmptyStatementBlock')
public virtual class TriggerHandlerBase {
  public virtual void beforeInsert(TriggerDto.Context info) {
  }

  public virtual void afterInsert(TriggerDto.Context info) {
  }

  public virtual void beforeUpdate(TriggerDto.Context info) {
  }

  public virtual void afterUpdate(TriggerDto.Context info) {
  }

  public virtual void beforeDelete(TriggerDto.Context info) {
  }

  public virtual void afterDelete(TriggerDto.Context info) {
  }

  public virtual void afterUndelete(TriggerDto.Context info) {
  }
}
