global class DownloadInvoicesScheduler implements Schedulable{
    global void execute(SchedulableContext sc) {
        DownloadInvoicesBatch batch = new DownloadInvoicesBatch();
        Database.executeBatch(batch, 20);
    }
}