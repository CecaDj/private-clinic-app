@IsTest
public class PortalSharingServiceTest {

    @IsTest
    static void testCascadeSharing() {
        User portalUser = TestDataFactory.createPortalUser();
        Patient__c patient = [SELECT Id FROM Patient__c WHERE User__c = :portalUser.Id];
        Doctor__c doctor = TestDataFactory.createDoctor();
        Treatment__c treatment = TestDataFactory.createTreatment();
        Appointment__c appointment = TestDataFactory.createAppointment(patient.Id, doctor.Id, treatment.Id);

        // Invoice that should be shared (Status__c = Sent)
        Invoice__c invoiceShared = TestDataFactory.createInvoice(patient.Id, appointment.Id);

        // Invoice that should NOT be shared (Status__c = Draft)
        Invoice__c invoiceDraft = new Invoice__c(
            Patient__c = patient.Id,
            Appointment__c = appointment.Id,
            Status__c = 'Draft',
            Total_Amount__c = 50
        );
        insert invoiceDraft;

        Test.startTest();
        PortalSharingService.shareRecords(new List<String>{ patient.Id }, 'Patient__c');
        Test.stopTest();
        
        Patient__Share patientShared = [
            SELECT ParentId, UserOrGroupId, AccessLevel
            FROM Patient__Share
            WHERE ParentId = :patient.Id AND RowCause = 'Manual'
            LIMIT 1
        ];
        System.assertEquals(portalUser.Id, patientShared.UserOrGroupId);
        System.assertEquals('Edit', patientShared.AccessLevel);

        Appointment__Share appShared = [
            SELECT ParentId, UserOrGroupId, AccessLevel
            FROM Appointment__Share
            WHERE ParentId = :appointment.Id AND RowCause = 'Manual'
            LIMIT 1
        ];
        System.assertEquals(portalUser.Id, appShared.UserOrGroupId);
        System.assertEquals('Edit', appShared.AccessLevel);

        Invoice__Share invShared = [
            SELECT ParentId, UserOrGroupId, AccessLevel
            FROM Invoice__Share
            WHERE ParentId = :invoiceShared.Id AND RowCause = 'Manual'
            LIMIT 1
        ];
        System.assertEquals(portalUser.Id, invShared.UserOrGroupId);
        System.assertEquals('Read', invShared.AccessLevel);

        List<Invoice__Share> draftShares = [
            SELECT Id FROM Invoice__Share WHERE ParentId = :invoiceDraft.Id AND RowCause = 'Manual'
        ];
        System.assertEquals(0, draftShares.size(), 'Draft invoice should NOT be shared');
    }
}
