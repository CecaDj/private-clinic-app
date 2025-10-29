@IsTest
private class AppointmentControllerTest {

    @TestSetup
    static void setup() {
        Id userId = UserInfo.getUserId();
        Patient__c patient = TestDataFactory.createPatient(userId);
        Doctor__c doctor = TestDataFactory.createDoctor();
        Treatment__c treatment = TestDataFactory.createTreatment();
        
        TestDataFactory.createAppointment(patient.Id, doctor.Id, treatment.Id);
    }

    @IsTest
    static void testGetAppointments() {

        Test.startTest();
        List<Map<String, Object>> results = AppointmentController.getAppointments();
        Test.stopTest();
        System.assertNotEquals(null, results, 'Expected non-null results');  
    }

    @IsTest
    static void testGetAppointmentsForPatient() {

        Test.startTest();
        Map<String, List<Appointment__c>> results = AppointmentController.getAppointmentsForPatient();
        Test.stopTest();
        System.assertNotEquals(null, results, 'Expected a result map');
        System.assert(results.containsKey('upcoming'), 'Expected upcoming appointments key');
        System.assert(results.containsKey('past'), 'Expected past appointments key');
        
    }

    @IsTest
    static void testCancelAppointment() {
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];

        Test.startTest();
        AppointmentController.cancelAppointment(appt.Id);
        Test.stopTest();

        Appointment__c updated = [SELECT Status__c FROM Appointment__c WHERE Id = :appt.Id];
        System.assertEquals('Cancelled', updated.Status__c, 'Appointment should be cancelled');
    }

    @IsTest
    static void testBookAppointment() {
        Doctor__c doctor = [SELECT Id FROM Doctor__c LIMIT 1];
        Treatment__c treatment = [SELECT Id FROM Treatment__c LIMIT 1];

        Test.startTest();
        String result = AppointmentController.bookAppointment(
            doctor.Id,
            treatment.Id,
            Date.today().addDays(1),
            '09:00 AM'
        );
        Test.stopTest();

        System.assert(result.contains('Appointment booked successfully'),
            'Expected success message but got: ' + result);

    }

}
