@IsTest
private class GenerateInvoicesBatchTest {

    @TestSetup
    static void setup() {
        Patient__c patient = TestDataFactory.createPatient(null);
        Doctor__c doctor = TestDataFactory.createDoctor();
        Treatment__c treatment = TestDataFactory.createTreatment();
        Appointment__c appointment = TestDataFactory.createAppointment(patient.Id, doctor.Id, treatment.Id);
        
        Invoice__c invoice = new Invoice__c(
            Patient__c = patient.Id,
            Appointment__c = appointment.Id,
            Total_Amount__c = treatment.Treatment_Fee__c,
            Issue_Date__c = Date.today(),
            Due_Date__c = Date.today().addDays(30),
            PDFMonkey_Document_Id__c = null, 
            Status__c = 'Draft' 
        );
        insert invoice;
    }

    @IsTest
    static void testGenerateInvoicesBatch() {
        Test.setMock(HttpCalloutMock.class, new PDFMonkeyHttpMock());

        Test.startTest();
        Database.executeBatch(new GenerateInvoicesBatch(), 1);
        Test.stopTest();

        Invoice__c updatedInv = [SELECT PDFMonkey_Document_Id__c FROM Invoice__c LIMIT 1];
        System.assertNotEquals(null, updatedInv.PDFMonkey_Document_Id__c, 'Document Id should be set');
    }
}
