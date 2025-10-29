@IsTest
private class PatientTriggerTest {

    @IsTest
    static void testPatientSharing() {
        User portalUser = TestDataFactory.createPortalUser();

        Test.startTest();
        Patient__c patient = TestDataFactory.createPatient(portalUser.Id);
        Test.stopTest();

        List<Patient__Share> shares = [
            SELECT Id, ParentId, UserOrGroupId, AccessLevel
            FROM Patient__Share
            WHERE ParentId = :patient.Id AND UserOrGroupId = :portalUser.Id
        ];

        System.assertEquals(1, shares.size(), 'Patient share should be created');
        System.assertEquals(portalUser.Id, shares[0].UserOrGroupId);
        System.assertEquals('Edit', shares[0].AccessLevel);
    }
}
