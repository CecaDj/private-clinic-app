public without sharing class PortalSharingService {
     /**
    * Handles record sharing for portal users.
    * Ensures that a patient's assigned portal user can see:
    * - Their Patient record
    * - Their Appointments
    * - Their Invoices (not Draft)
    *
    * Sharing cascades automatically:
    * Patient → Appointments → Invoices
    *
    * This ensures the portal user always sees their complete medical history.
    */
    public static void shareRecords(List<String> recordIds, String objectName) {
        if (recordIds == null || recordIds.isEmpty() || String.isBlank(objectName)) return;

        switch on objectName {
            when 'Patient__c'     { sharePatients(recordIds); }
            when 'Appointment__c' { shareAppointments(recordIds); }
            when 'Invoice__c'     { shareInvoices(recordIds); }
            when else              { System.debug('Unknown object: ' + objectName); }
        }
    }

    private static void sharePatients(List<String> patientIds) {
        List<Patient__c> patients = [
            SELECT Id, User__c 
            FROM Patient__c 
            WHERE Id IN :patientIds AND User__c != null
        ];

        List<Patient__Share> shares = new List<Patient__Share>();
        for (Patient__c p : patients) {
            shares.add(new Patient__Share(
                ParentId = p.Id,
                UserOrGroupId = p.User__c,
                AccessLevel = 'Edit',
                RowCause = Schema.Patient__Share.RowCause.Manual
            ));
        }
        if (!shares.isEmpty()) insert shares;

        // cascade
        List<Appointment__c> relatedApps = [
            SELECT Id, Patient__r.User__c 
            FROM Appointment__c 
            WHERE Patient__c IN :patientIds
        ];
        
        if (!relatedApps.isEmpty()) {
            List<String> appointmentIdsToShare = new List<String>();
            for (Id appId : new Map<Id, Appointment__c>(relatedApps).keySet()) {
                appointmentIdsToShare.add(String.valueOf(appId));
            }
            shareAppointments(appointmentIdsToShare);
        }

    }

    private static void shareAppointments(List<String> appointmentIds) {
        List<Appointment__c> apps = [
            SELECT Id, Patient__r.User__c 
            FROM Appointment__c 
            WHERE Id IN :appointmentIds AND Patient__r.User__c != null
        ];

        List<Appointment__Share> shares = new List<Appointment__Share>();
        for (Appointment__c app : apps) {
            shares.add(new Appointment__Share(
                ParentId = app.Id,
                UserOrGroupId = app.Patient__r.User__c,
                AccessLevel = 'Edit',
                RowCause = Schema.Appointment__Share.RowCause.Manual
            ));
        }
        if (!shares.isEmpty()) insert shares;

        // cascade to invoices
        List<Invoice__c> invs = [
            SELECT Id, Patient__r.User__c, Status__c 
            FROM Invoice__c 
            WHERE Patient__c IN (SELECT Patient__c FROM Appointment__c WHERE Id IN :appointmentIds)
        ];
        if (!invs.isEmpty()) {
            List<String> invoiceIdsToShare = new List<String>();
            for (Id invId : new Map<Id, Invoice__c>(invs).keySet()) {
                invoiceIdsToShare.add(String.valueOf(invId));
            }
            shareInvoices(invoiceIdsToShare);
        }

    }

    private static void shareInvoices(List<String> invoiceIds) {
        List<Invoice__c> invs = [
            SELECT Id, Patient__r.User__c, Status__c 
            FROM Invoice__c 
            WHERE Id IN :invoiceIds AND Patient__r.User__c != null AND Status__c != 'Draft'
        ];

        List<Invoice__Share> shares = new List<Invoice__Share>();
        for (Invoice__c inv : invs) {
            shares.add(new Invoice__Share(
                ParentId = inv.Id,
                UserOrGroupId = inv.Patient__r.User__c,
                AccessLevel = 'Read',
                RowCause = Schema.Invoice__Share.RowCause.Manual
            ));
        }
        if (!shares.isEmpty()) insert shares;
    }
}
