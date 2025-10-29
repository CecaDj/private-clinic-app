@IsTest
private class TreatmentControllerTest {

    @TestSetup
    static void setup() {
        TestDataFactory.createTreatment();
    }

    @IsTest
    static void testGetAllTreatments() {
        Test.startTest();
        List<Treatment__c> results = TreatmentController.getAllTreatments();
        Test.stopTest();
        System.assert(results.size() > 0, 'Expected at least one treatment');
    }
}
