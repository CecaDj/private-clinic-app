@IsTest
private class InvoiceControllerTest {

    @IsTest
    static void testGetPatientInvoices() {
        Id userId = UserInfo.getUserId();
        Patient__c patient = TestDataFactory.createPatient(userId);
        Doctor__c doctor = TestDataFactory.createDoctor();
        Treatment__c treatment = TestDataFactory.createTreatment();
        Appointment__c appt = TestDataFactory.createAppointment(patient.Id, doctor.Id, treatment.Id);
        TestDataFactory.createInvoice(patient.Id, appt.Id);

        Test.startTest();
        List<Map<String, Object>> results = InvoiceController.getPatientInvoices();
        Test.stopTest();
        
        System.assert(results.size() > 0);
        
    }

}
