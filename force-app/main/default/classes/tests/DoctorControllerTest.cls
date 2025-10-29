@IsTest
private class DoctorControllerTest {

    @TestSetup
    static void setup() {
        TestDataFactory.createDoctor();
        TestDataFactory.createTreatment();
    }

    @IsTest
    static void testGetAllDoctors() {
        Test.startTest();
        List<Doctor__c> results = DoctorController.getAllDoctors();
        Test.stopTest();
        System.assert(results.size() > 0, 'Expected at least one doctor');
    }

    @IsTest
    static void testGetAvailableSlots() {
        Doctor__c doctor = [SELECT Id FROM Doctor__c LIMIT 1];
        Treatment__c treatment = [SELECT Id FROM Treatment__c LIMIT 1];

        Test.startTest();
        List<String> results = DoctorController.getAvailableSlots(
            doctor.Id, Date.today().addDays(1), treatment.Id
        );
        Test.stopTest();

        System.assertNotEquals(null, results, 'Expected slot list (even if empty)');
    }
}
