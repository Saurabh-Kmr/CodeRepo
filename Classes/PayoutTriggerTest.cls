@isTest
public with sharing class PayoutTriggerTest {
  @testSetup
  static void setup() {
    Account acc = new Account(Name = 'Test Account');
    insert acc;
    Contact con = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc.Id);
    insert con;
    Payout__c payout = new Payout__c();
    payout.Approval_Status__c = 'Submitted';
    payout.Amount__c = 5001;
    payout.Required_Documentation_Attached__c = false;
    payout.Type__c = 'Appeasement';
    payout.Direction__c = 'Outbound';
    payout.Account__c = acc.Id;
    payout.Contact__c = con.Id;
    insert payout;
  }
  @isTest
  static void beforeUpdateTest() {
    Payout__c payout = [
      SELECT Approval_Status__c, Amount__c, Required_Documentation_Attached__c
      FROM Payout__c
      WHERE Approval_Status__c = 'Submitted' AND Amount__c = 5001 AND Required_Documentation_Attached__c = FALSE
      LIMIT 1
    ];
    payout.Approval_Status__c = 'Approved';
    Test.startTest();
    try {
      update payout;
      System.assert(false, 'Expected exception not thrown.');
    } catch (DmlException e) {
      if (e.getMessage().contains('A legal agreement is required before approval.')) {
        System.assert(true, 'Expected exception thrown.');
      } else {
        System.assert(false, e.getMessage());
      }
    }
    Test.stopTest();
    System.assertNotEquals('Approved', [SELECT Approval_Status__c FROM Payout__c WHERE Id = :payout.Id].Approval_Status__c);
  }
}
