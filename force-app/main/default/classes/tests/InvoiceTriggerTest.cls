@IsTest
private class InvoiceTriggerTest {

    @IsTest
    static void testInvoiceSharing() {
        User portalUser = TestDataFactory.createPortalUser();
        Patient__c patient = [SELECT Id FROM Patient__c WHERE User__c = :portalUser.Id];
        Doctor__c doctor = TestDataFactory.createDoctor();
        Treatment__c treatment = TestDataFactory.createTreatment();
        Appointment__c appointment = TestDataFactory.createAppointment(patient.Id, doctor.Id, treatment.Id);

        Test.startTest();
        Invoice__c invoice = TestDataFactory.createInvoice(patient.Id, appointment.Id);
        Test.stopTest();

        List<Invoice__Share> shares = [
            SELECT Id, ParentId, UserOrGroupId, AccessLevel
            FROM Invoice__Share
            WHERE ParentId = :invoice.Id AND UserOrGroupId = :portalUser.Id
        ];

        System.assertEquals(1, shares.size(), 'Invoice share should be created');
        System.assertEquals(portalUser.Id, shares[0].UserOrGroupId);
        System.assertEquals('Read', shares[0].AccessLevel);
    }
}
