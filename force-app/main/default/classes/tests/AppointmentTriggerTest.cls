@IsTest
private class AppointmentTriggerTest {

    @TestSetup
    static void setupTestData() {
        Doctor__c doctor = TestDataFactory.createDoctor();
        Treatment__c treatment = TestDataFactory.createTreatment();
        Patient__c patient = TestDataFactory.createPatient(null);

        TestDataFactory.createAppointment(patient.Id, doctor.Id, treatment.Id);
    }

    @IsTest
    static void testPastAppointmentValidation() {
        Doctor__c doctor = [SELECT Id FROM Doctor__c LIMIT 1];
        Treatment__c treatment = [SELECT Id FROM Treatment__c LIMIT 1];
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];
        Appointment__c existingAppointment = [SELECT Id, Date__c FROM Appointment__c LIMIT 1];

        Appointment__c pastApp = new Appointment__c(
            Doctor__c = doctor.Id,
            Patient__c = patient.Id,
            Treatment__c = treatment.Id,
            Date__c = Date.today().addDays(-1), // past date
            Start_Time__c = Time.newInstance(10, 0, 0, 0)
        );

        Test.startTest();
        Database.SaveResult insertResult = Database.insert(pastApp, false);
        existingAppointment.Date__c = Date.today().addDays(-1);
        Database.SaveResult updateResult = Database.update(existingAppointment, false);
        Test.stopTest();

        System.assert(
            insertResult.getErrors().size() > 0,
            'Appointment should not be created in the past.'
        );
        System.assert(
            updateResult.getErrors().size() > 0,
            'Appointment should not be updated to a past date.'
        );
    }

    @IsTest
    static void testDoctorWorkingHoursValidation() {
        Doctor__c doctor = [SELECT Id, Working_Hours_End__c FROM Doctor__c LIMIT 1];
        Treatment__c treatment = [SELECT Id FROM Treatment__c LIMIT 1];
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];
        Appointment__c existingAppointment = [SELECT Id, Date__c FROM Appointment__c LIMIT 1];

        Appointment__c lateApp = new Appointment__c(
            Doctor__c = doctor.Id,
            Patient__c = patient.Id,
            Treatment__c = treatment.Id,
            Date__c = Date.today().toStartOfWeek().addDays(8),
            Start_Time__c = Time.newInstance(23, 0, 0, 0)
        );

        Test.startTest();
        Database.SaveResult insertResult = Database.insert(lateApp, false);
        Test.stopTest();

        System.assert(
            insertResult.getErrors().size() > 0,
            'Appointment should not be created outside working hours.'
        );
    }

    @IsTest
    static void testAppointmentOverlapValidation() {
        Doctor__c doctor = [SELECT Id FROM Doctor__c LIMIT 1];
        Treatment__c treatment = [SELECT Id, Duration__c FROM Treatment__c LIMIT 1];
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];
        Appointment__c existingApp = [SELECT Id, Date__c, Start_Time__c FROM Appointment__c LIMIT 1];

        Appointment__c overlapApp = new Appointment__c(
            Doctor__c = doctor.Id,
            Patient__c = patient.Id,
            Treatment__c = treatment.Id,
            Date__c = existingApp.Date__c,
            Start_Time__c = existingApp.Start_Time__c // same time
        );

        Test.startTest();
        Database.SaveResult result = Database.insert(overlapApp, false);
        Test.stopTest();

        System.assert(
            result.getErrors().size() > 0,
            'Appointment should not overlap with existing appointments.'
        );
    }

    @IsTest
    static void testValidAppointmentInsertedSuccessfully() {
        Doctor__c doctor = [SELECT Id FROM Doctor__c LIMIT 1];
        Treatment__c treatment = [SELECT Id, Duration__c FROM Treatment__c LIMIT 1];
        Patient__c patient = [SELECT Id FROM Patient__c LIMIT 1];

        Appointment__c validApp = new Appointment__c(
            Doctor__c = doctor.Id,
            Patient__c = patient.Id,
            Treatment__c = treatment.Id,
            Date__c = Date.today().addDays(2),
            Start_Time__c = Time.newInstance(10, 0, 0, 0)
        );

        Test.startTest();
        insert validApp;
        Test.stopTest();

        System.assertNotEquals(
            null,
            validApp.Id,
            'Appointment within valid working hours and future date should insert successfully.'
        );
    }

    @IsTest
    static void testAppointmentSharing() {
        User portalUser = TestDataFactory.createPortalUser();
        Patient__c patient = [SELECT Id FROM Patient__c WHERE User__c = :portalUser.Id];
        Doctor__c doctor = TestDataFactory.createDoctor();
        Treatment__c treatment = [SELECT Id FROM Treatment__c LIMIT 1];

        Test.startTest();
        Appointment__c appointment = TestDataFactory.createAppointment(patient.Id, doctor.Id, treatment.Id);
        Test.stopTest();

        List<Appointment__Share> shares = [
            SELECT Id, ParentId, UserOrGroupId, AccessLevel
            FROM Appointment__Share
            WHERE ParentId = :appointment.Id AND UserOrGroupId = :portalUser.Id
        ];

        System.assertEquals(1, shares.size(), 'Appointment share should be created');
        System.assertEquals(portalUser.Id, shares[0].UserOrGroupId);
        System.assertEquals('Edit', shares[0].AccessLevel);
    }
}
