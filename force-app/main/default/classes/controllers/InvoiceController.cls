public with sharing class InvoiceController {

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getPatientInvoices() { 
        return InvoiceService.getInvoicesForLoggedInPatient();
    }
}