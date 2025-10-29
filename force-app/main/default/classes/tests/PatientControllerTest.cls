@IsTest
private class PatientControllerTest {

    @IsTest
    static void testGetMyPatientId() {
        Id userId = UserInfo.getUserId();
        Patient__c patient = TestDataFactory.createPatient(userId);
       
        Test.startTest();
        Id result = PatientController.getMyPatientId();
        Test.stopTest();
        System.assertNotEquals(null, result);
    }


    @IsTest
    static void testIsPatientProfileComplete() {
        Id userId = UserInfo.getUserId();
        Patient__c patient = TestDataFactory.createPatient(userId);

        Test.startTest();
        Boolean result = PatientController.isPatientProfileComplete();
        Test.stopTest();
        System.assertEquals(true, result);

    }

}
