global with sharing class GetRecordTypeInfoByObject {
  @InvocableMethod
  global static List<Result> get(List<Request> requests) {
    List<Result> results = new List<Result>();

    for (Request req : requests) {
      Result result = new Result();
      for (Schema.RecordTypeInfo rt : Ut.getRecordTypeInfoMap(req.objectName).values()) {
        if (
          (rt.isActive() || !req.onlyReturnActiveRecordTypes) &&
          (rt.isAvailable() || !req.onlyReturnRecordTypesAvailableToCurrentUser) &&
          (!rt.isMaster() || !req.ignoreMasterRecordType)
        ) {
          result.recordTypes.add(new RecordType(Id = rt.getRecordTypeId(), Name = rt.getName()));
        }

        if (rt.isDefaultRecordTypeMapping()) {
          result.defaultRecordTypeId = rt.getRecordTypeId();
          result.defaultRecordTypeName = rt.getName();
        }
      }

      results.add(result);
    }

    return results;
  }

  global class Request {
    @InvocableVariable(label='Object Name' required=true)
    global String objectName;

    @InvocableVariable
    global Boolean onlyReturnActiveRecordTypes;

    @InvocableVariable
    global Boolean onlyReturnRecordTypesAvailableToCurrentUser;

    @InvocableVariable
    global Boolean ignoreMasterRecordType;
  }

  global class Result {
    public Result() {
      recordTypes = new List<RecordType>();
      defaultRecordTypeId = '';
      defaultRecordTypeName = '';
    }

    @InvocableVariable
    global List<RecordType> recordTypes;

    @InvocableVariable
    global String defaultRecordTypeId;

    @InvocableVariable
    global String defaultRecordTypeName;
  }

  global class InvocableActionException extends Exception {
  }
}
