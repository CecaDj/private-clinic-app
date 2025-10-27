// Service class handling PDFMonkey API calls
public class PdfMonkeyService {
    // Named Credential for API calls
    private static final String NAMED_CRED = 'PDFMonkey';

    // Generate PDF document in PDFMonkey and return the document ID
    public static String generateInvoiceDocument(Invoice__c invoice, InvoicePdfDto dto) {
        // Retrieve template ID from Custom Metadata
        String templateId = PDF_Monkey__mdt.getInstance('Invoice_Template_ID').Template_ID__c;

        Map<String, Object> documentMap = new Map<String, Object>{
            'document' => new Map<String, Object>{
                'document_template_id' => templateId,
                'status' => 'pending',
                'payload' => dto,
                'meta' => new Map<String, Object>{ '_filename' => 'Invoice_' + invoice.Name + '.pdf' }
            }
        };

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + NAMED_CRED);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(documentMap));

        Http http = new Http();
        HttpResponse res = http.send(req);
        
        // Parse response and return document ID
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> doc = (Map<String, Object>) result.get('document');
            return (String) doc.get('id');
        } else {
            throw new CalloutException('PDFMonkey POST failed: ' + res.getBody());
        }
    }

    // Get metadata for a PDFMonkey document
    public static Map<String, Object> getDocumentMetadata(String docId) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + NAMED_CRED + '/' + EncodingUtil.urlEncode(docId,'UTF-8'));
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        } else {
            throw new CalloutException('PDFMonkey GET metadata failed: ' + res.getBody());
        }
    }

    // Download a PDF from a given URL
    public static Blob downloadPDF(String downloadUrl) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(downloadUrl);
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return res.getBodyAsBlob();
        } else {
            throw new CalloutException('PDFMonkey PDF download failed: ' + res.getStatus());
        }
    }
}