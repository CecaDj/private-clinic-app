public class InvoicePaymentLinkScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        InvoicePaymentLinkBatch batch = new InvoicePaymentLinkBatch();
        Database.executeBatch(batch, 50);
    }
}
