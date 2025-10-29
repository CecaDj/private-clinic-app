@IsTest
private class PatientControllerTest {

    @IsTest
    static void testGetMyPatientId() {
        User portalUser = TestDataFactory.createPortalUser();
        Patient__c patient = [
            SELECT Id FROM Patient__c WHERE User__c = :portalUser.Id LIMIT 1
        ];

        System.runAs(portalUser) {
            Test.startTest();
            Id result = PatientController.getMyPatientId();
            Test.stopTest();
            System.assertNotEquals(null, result);
        }
    }


    @IsTest
    static void testIsPatientProfileComplete() {
        User portalUser = TestDataFactory.createPortalUser();

        Patient__c patient = [
            SELECT Id, Date_of_Birth__c, Funding_Type__c, Phone__c, Address__c
            FROM Patient__c
            WHERE User__c = :portalUser.Id
            LIMIT 1
        ];

        patient.Date_of_Birth__c = Date.newInstance(1990,1,1);
        patient.Funding_Type__c = 'Self-Funding';
        patient.Phone__c = '555-555';
        patient.Address__c = 'Test Street';
        update patient;

        System.runAs(portalUser) {
            Test.startTest();
            Boolean result = PatientController.isPatientProfileComplete();
            Test.stopTest();
            System.assertEquals(true, result);
        }
    }

}
