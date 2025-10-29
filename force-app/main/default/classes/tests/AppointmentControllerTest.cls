@IsTest
private class AppointmentControllerTest {

    @TestSetup
    static void setup() {
        User portalUser = TestDataFactory.createPortalUser();
        Doctor__c doctor = TestDataFactory.createDoctor();
        Treatment__c treatment = TestDataFactory.createTreatment();

        Patient__c patient = [SELECT Id FROM Patient__c WHERE User__c = :portalUser.Id LIMIT 1];
        TestDataFactory.createAppointment(patient.Id, doctor.Id, treatment.Id);
    }

    @IsTest
    static void testGetAppointments() {
        User portalUser = [SELECT Id FROM User WHERE Profile.Name='Patient Portal User' LIMIT 1];

        System.runAs(portalUser) {
            Test.startTest();
            List<Map<String, Object>> results = AppointmentController.getAppointments();
            Test.stopTest();
            System.assertNotEquals(null, results, 'Expected non-null results');
        }
    }

    @IsTest
    static void testGetAppointmentsForPatient() {
        User portalUser = [SELECT Id FROM User WHERE Profile.Name='Patient Portal User' LIMIT 1];

        System.runAs(portalUser) {
            Test.startTest();
            Map<String, List<Appointment__c>> results = AppointmentController.getAppointmentsForPatient();
            Test.stopTest();
            System.assertNotEquals(null, results, 'Expected a result map');
            System.assert(results.containsKey('upcoming'), 'Expected upcoming appointments key');
            System.assert(results.containsKey('past'), 'Expected past appointments key');
        }
    }

    @IsTest
    static void testCancelAppointment() {
        User portalUser = [SELECT Id FROM User WHERE Profile.Name='Patient Portal User' LIMIT 1];
        Appointment__c appt = [SELECT Id FROM Appointment__c LIMIT 1];

        System.runAs(portalUser) {
            Test.startTest();
            AppointmentController.cancelAppointment(appt.Id);
            Test.stopTest();

            Appointment__c updated = [SELECT Status__c FROM Appointment__c WHERE Id = :appt.Id];
            System.assertEquals('Cancelled', updated.Status__c, 'Appointment should be cancelled');
        }
    }

    @IsTest
    static void testBookAppointment() {
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

        Doctor__c doctor = [SELECT Id FROM Doctor__c LIMIT 1];
        Treatment__c treatment = [SELECT Id FROM Treatment__c LIMIT 1];

        System.runAs(portalUser) {
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

}
