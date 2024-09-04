@isTest(SeeAllData=false)
private class GetRecordTypeInfoByObjectTest {
  @isTest
  private static void canGetRecordType() {
    List<GetRecordTypeInfoByObject.Request> requestList = new List<GetRecordTypeInfoByObject.Request>();
    GetRecordTypeInfoByObject.Request request = new GetRecordTypeInfoByObject.Request();
    request.objectName = 'Account';
    request.onlyReturnActiveRecordTypes = false;
    request.onlyReturnRecordTypesAvailableToCurrentUser = false;
    request.ignoreMasterRecordType = false;
    requestList.add(request);

    List<GetRecordTypeInfobyObject.Result> results = GetRecordTypeInfoByObject.get(requestList);
    Assert.areNotEqual(null, results[0].recordTypes, 'Record Type Expected');
  }

  @isTest
  private static void canGetFilteredRecordType() {
    List<GetRecordTypeInfoByObject.Request> requestList = new List<GetRecordTypeInfoByObject.Request>();
    GetRecordTypeInfoByObject.Request request = new GetRecordTypeInfoByObject.Request();
    request.objectName = 'Payout__c';
    request.onlyReturnActiveRecordTypes = true;
    request.onlyReturnRecordTypesAvailableToCurrentUser = true;
    request.ignoreMasterRecordType = true;
    requestList.add(request);

    List<GetRecordTypeInfobyObject.Result> results = GetRecordTypeInfoByObject.get(requestList);
    Assert.areNotEqual(null, results[0].recordTypes, 'Record Type Expected');
  }
}
