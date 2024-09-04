global class UpdateAssetServicerBatchSchedule implements Schedulable {
  global void execute(SchedulableContext sc) {
    UpdateAssetServicerBatch updtAssetSerBatch = new UpdateAssetServicerBatch();
    database.executeBatch(updtAssetSerBatch);
  }
}
