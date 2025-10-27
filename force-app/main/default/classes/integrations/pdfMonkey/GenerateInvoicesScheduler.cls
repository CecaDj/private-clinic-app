global class GenerateInvoicesScheduler implements Schedulable{
    public void execute(SchedulableContext sc) {
        GenerateInvoicesBatch batch = new GenerateInvoicesBatch();
        Database.executeBatch(batch, 20);
    }
}