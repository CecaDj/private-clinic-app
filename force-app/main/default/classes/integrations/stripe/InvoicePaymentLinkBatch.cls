//Calls StripePaymentService to generate checkout URLs
//Updates each invoice with its Payment_Link__c field
public class InvoicePaymentLinkBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Total_Amount__c
            FROM Invoice__c
            WHERE Status__c = 'Draft'
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Invoice__c> scope) {
        Map<Id, String> invoiceToUrl = StripePaymentService.createCheckoutSessions(scope);

        List<Invoice__c> updates = new List<Invoice__c>();
        for (Id invId : invoiceToUrl.keySet()) {
            updates.add(new Invoice__c(
                Id = invId,
                Payment_Link__c = invoiceToUrl.get(invId)
            ));
        }

        if (!updates.isEmpty()) {
            Database.SaveResult[] results = Database.update(updates, false);

            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    System.debug('Failed to update Invoice ' + updates[i].Id + ': ' + results[i].getErrors()[0].getMessage());
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('InvoicePaymentLinkBatch finished');
    }
}
