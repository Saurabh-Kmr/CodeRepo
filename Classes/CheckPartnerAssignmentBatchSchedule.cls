global class CheckPartnerAssignmentBatchSchedule implements Schedulable {
  global void execute(SchedulableContext sc) {
    CheckPartnerAssignmentBatch batch = new CheckPartnerAssignmentBatch();
    if (!Test.isRunningTest()) {
      database.executeBatch(batch);
    }
  }
}
