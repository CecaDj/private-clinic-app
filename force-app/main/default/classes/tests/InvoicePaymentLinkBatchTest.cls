@isTest
private class InvoicePaymentLinkBatchTest {

    @testSetup
    static void setupData() {
        Doctor__c doctor = TestDataFactory.createDoctor();
        Treatment__c treatment = TestDataFactory.createTreatment();
        Patient__c patient = TestDataFactory.createPatient(null);
        Appointment__c appointment = TestDataFactory.createAppointment(patient.Id, doctor.Id, treatment.Id);

        List<Invoice__c> invoices = new List<Invoice__c>();
        for (Integer i = 0; i < 3; i++) {
            invoices.add(new Invoice__c(
                Patient__c = patient.Id,
                Appointment__c = appointment.Id,
                Total_Amount__c = 200,
                Status__c = 'Draft'
            ));
        }
        insert invoices;
    }

    @isTest
    static void testBatchUpdatesInvoices() {
        Test.setMock(HttpCalloutMock.class, new StripeHttpMock(true));

        Test.startTest();
        Database.executeBatch(new InvoicePaymentLinkBatch(), 5);
        Test.stopTest();

        List<Invoice__c> updated = [
            SELECT Id, Payment_Link__c
            FROM Invoice__c
        ];

        for (Invoice__c inv : updated) {
            System.assertNotEquals(null, inv.Payment_Link__c,
                'Each invoice should have a payment link after batch execution');
        }
    }

    @isTest
    static void testBatchHandlesErrors() {
        Test.setMock(HttpCalloutMock.class, new StripeHttpMock(false));

        Test.startTest();
        Database.executeBatch(new InvoicePaymentLinkBatch(), 5);
        Test.stopTest();

        List<Invoice__c> updated = [
            SELECT Id, Payment_Link__c
            FROM Invoice__c
        ];

        for (Invoice__c inv : updated) {
            System.assertEquals(null, inv.Payment_Link__c,
                'Invoices should not be updated when Stripe callout fails');
        }
    }
}
