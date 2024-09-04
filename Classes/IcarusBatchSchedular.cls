public class IcarusBatchSchedular implements Schedulable {
  Integer batchSize = 200;
  public IcarusBatchSchedular() {
  }
  public IcarusBatchSchedular(Integer batchSize) {
    this.batchSize = batchSize;
  }
  public void execute(SchedulableContext SC) {
    Database.executeBatch(new IcarusWorkOrderAutomationBatch(), batchSize);
  }
}
