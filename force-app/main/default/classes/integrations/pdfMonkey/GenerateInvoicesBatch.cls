// Generate invoices via PDFMonkey
public class GenerateInvoicesBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query draft invoices that need PDF generation
        return Database.getQueryLocator([
            SELECT Id, Name, Status__c, Patient__r.Name, Total_Amount__c, Patient__r.Address__c, Appointment__r.Treatment__r.Name,
            Appointment__r.Treatment__r.Description__c, Due_Date__c, Issue_Date__c
            FROM Invoice__c
            WHERE Status__c = 'Draft' AND PDFMonkey_Document_Id__c = null
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Invoice__c> scope) {
        List<Invoice__c> updates = new List<Invoice__c>();

        for (Invoice__c inv : scope) {
            try {
                // Convert Invoice__c to DTO suitable for PDFMonkey payload
                InvoicePdfDto dto = InvoicePdfDto.parse(inv);
                // Generate PDF in PDFMonkey and store returned document ID on invoice
                String documentId = PdfMonkeyService.generateInvoiceDocument(inv, dto);
                inv.PDFMonkey_Document_Id__c = documentId;
                updates.add(inv);
            } catch (Exception e) {
                System.debug('Invoice number ' + inv.Name + ' not generated: ' + e.getMessage());
            }
        }
        // Update all successfully processed invoices
        if (!updates.isEmpty()) {
            Database.update(updates, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Invoices have been generated.');
    }
}
