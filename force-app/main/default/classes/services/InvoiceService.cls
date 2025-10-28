public with sharing class InvoiceService {

    public static List<Map<String, Object>> getInvoicesForLoggedInPatient() {

        Id patientId = PatientService.getMyPatientId();
        if (patientId == null) {
            throw new AuraHandledException('No patient record found for this user.');
        }

        // Exclude Draft
        List<Invoice__c> invoices = [
            SELECT Id, Name, Status__c, Total_Amount__c,
                   Issue_Date__c, Due_Date__c, Payment_Link__c
            FROM Invoice__c
            WHERE Patient__c = :patientId
              AND Status__c != 'Draft'
            ORDER BY Issue_Date__c DESC
        ];
        
        if (invoices.isEmpty()) {
            return new List<Map<String, Object>>();
        }
        
        Date today = Date.today();
        List<Map<String, Object>> formattedInvoices = new List<Map<String, Object>>();

        for (Invoice__c inv : invoices) {
            String displayStatus = inv.Status__c;

            // Overdue if past due and not paid/cancelled
            if (inv.Status__c != 'Paid' && inv.Status__c != 'Cancelled'
                && inv.Due_Date__c != null && inv.Due_Date__c < today) {
                displayStatus = 'Overdue';
            }
            // Outstanding if Sent and not overdue
            else if (inv.Status__c == 'Sent') {
                displayStatus = 'Outstanding';
            }
            // Paid and Cancelled pass through as-is

            formattedInvoices.add(new Map<String, Object>{
                'Id' => inv.Id,
                'InvoiceNumber' => inv.Name,
                'Date' => inv.Issue_Date__c,
                'Amount' => inv.Total_Amount__c,
                'Status' => displayStatus,
                'PaymentLink' => inv.Payment_Link__c
            });
        }

        return formattedInvoices;
    }
}