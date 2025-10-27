@IsTest
private class DownloadInvoicesBatchTest {

    @TestSetup
    static void setup() {
        Patient__c patient = TestDataFactory.createPatient(null);
        Doctor__c doctor = TestDataFactory.createDoctor();
        Treatment__c treatment = TestDataFactory.createTreatment();
        Appointment__c appointment = TestDataFactory.createAppointment(patient.Id, doctor.Id, treatment.Id);

        Invoice__c invoice = new Invoice__c(
            Patient__c = patient.Id,
            Appointment__c = appointment.Id,
            Total_Amount__c = 100,
            Issue_Date__c = Date.today(),
            Due_Date__c = Date.today().addDays(30),
            PDFMonkey_Document_Id__c = 'fake-doc-id'
        );
        insert invoice;
    }

    @IsTest
    static void testDownloadInvoicesBatch() {
        Test.setMock(HttpCalloutMock.class, new PDFMonkeyHttpMock());

        Test.startTest();
        Database.executeBatch(new DownloadInvoicesBatch(), 1);
        Test.stopTest();

        List<ContentVersion> cvs = [SELECT Id, Title FROM ContentVersion];
        System.assert(!cvs.isEmpty(), 'ContentVersion should have been created');
    }
}
