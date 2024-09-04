public class UpdateAssetServicerBatch implements Database.Batchable<sObject> {
  public Database.QueryLocator start(Database.BatchableContext BC) {
    Date endDatefilterDate = system.today().addDays(-1);
    String query = 'SELECT id, AssetId, Equipment_Servicer__c, StartDate FROM AssetWarranty WHERE ( StartDate = TODAY OR EndDate =: endDatefilterDate ) and WarrantyType = \'Equipment\' Order By StartDate ASC';
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<AssetWarranty> assetWarrenties) {
    if (!assetWarrenties.isEmpty()) {
      List<Asset> assetsToUpdate = new List<Asset>();
      set<Id> assetIds = new Set<Id>();
      List<Account> lstAccount = [SELECT id FROM Account WHERE name = 'Sunrun' LIMIT 1];
      for (AssetWarranty aW : assetWarrenties) {
        Asset ast = new Asset(Id = aW.AssetId);
        if (aW.StartDate == System.today()) {
          ast.Servicer__c = aW.Equipment_Servicer__c;
        } else if (!lstAccount.isEmpty()) {
          ast.Servicer__c = lstAccount[0].id;
        } else {
          ast.Servicer__c = null;
        }
        assetsToUpdate.add(ast);
      }

      if (!assetsToUpdate.isEmpty()) {
        update assetsToUpdate;
      }
    }
  }

  public void finish(Database.BatchableContext BC) {
  }
}
