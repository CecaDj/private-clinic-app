@IsTest
private class InvoiceControllerTest {

    @IsTest
    static void testGetPatientInvoices() {
        User portalUser = TestDataFactory.createPortalUser();

        Patient__c patient = [
            SELECT Id FROM Patient__c WHERE User__c = :portalUser.Id LIMIT 1
        ];

        Doctor__c doctor = TestDataFactory.createDoctor();
        Treatment__c treatment = TestDataFactory.createTreatment();
        Appointment__c appt = TestDataFactory.createAppointment(patient.Id, doctor.Id, treatment.Id);
        TestDataFactory.createInvoice(patient.Id, appt.Id);

        System.runAs(portalUser) {
            Test.startTest();
            List<Map<String, Object>> results = InvoiceController.getPatientInvoices();
            Test.stopTest();
            System.assert(results.size() > 0);
        }
    }

}
