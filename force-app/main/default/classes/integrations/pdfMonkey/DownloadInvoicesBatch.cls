// Download generated invoices from PDFMonkey
public class DownloadInvoicesBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    // Query invoices that have a PDFMonkey document ID and are still drafts
    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator([
            SELECT Id, Name, PDFMonkey_Document_Id__c
            FROM Invoice__c
            WHERE PDFMonkey_Document_Id__c != null AND Status__c = 'Draft'
        ]);
    }

    // Process each batch: download PDFs and attach as ContentVersion
    public void execute(Database.BatchableContext bc, List<Invoice__c> scope) {
    List<ContentVersion> filesToInsert = new List<ContentVersion>();

    for (Invoice__c inv : scope) {
        try {        
            // Get document metadata from PDFMonkey
            Map<String, Object> metadata = PdfMonkeyService.getDocumentMetadata(inv.PDFMonkey_Document_Id__c);
            Map<String, Object> doc = (Map<String, Object>) metadata.get('document');

            // Only proceed if document generation succeeded
            if (doc != null && doc.get('status') == 'success') {
                String downloadUrl = (String) doc.get('download_url');

                if (!String.isBlank(downloadUrl)) {
                    // Download PDF file as Blob
                    Blob pdfFile = PdfMonkeyService.downloadPDF(downloadUrl);
                    // Create ContentVersion (attachment) for the invoice
                    ContentVersion cv = new ContentVersion(
                        Title = 'Invoice_' + inv.Name,
                        PathOnClient = 'Invoice_' + inv.Name + '.pdf',
                        VersionData = pdfFile,
                        FirstPublishLocationId = inv.Id
                    );
                    filesToInsert.add(cv);
                }
            } 
        } catch (Exception e) {
            System.debug('Failed to download invoice number ' + inv.Name + ': ' + e.getMessage());
        }
    }

    // Insert all successfully downloaded files
    if (!filesToInsert.isEmpty()) {
        Database.insert(filesToInsert, false);
    }
}

    public void finish(Database.BatchableContext bc) {
        System.debug('Invoices have been downloaded.');
    }

}
