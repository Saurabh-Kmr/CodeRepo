public with sharing class UserTriggerHandler extends TriggerHandlerBase {
  public static final UserTriggerHandler OBJ = new UserTriggerHandler();

  public void handleUserUpdate(TriggerDto.Context info) {
    if (info.isAfterUpdate) {
      for (User user : (List<User>) info.newList) {
        Ut.clearUserCache(user.id);
      }
    }
  }
}
