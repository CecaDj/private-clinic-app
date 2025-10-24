@IsTest
private class AppointmentControllerTest {

    @IsTest
    static void testGetAppointments_AsAdmin() {
        
        Doctor__c doctor = TestDataFactory.createDoctor();
        Treatment__c treatment = TestDataFactory.createTreatment();
        Patient__c patient = TestDataFactory.createPatient(null);
        Appointment__c appointment = TestDataFactory.createAppointment(patient.Id, doctor.Id, treatment.Id);

        
        Test.startTest();
        List<Map<String, Object>> result = AppointmentController.getAppointments();
        Test.stopTest();

        
        System.assertEquals(1, result.size(), 'Should return one appointment');
        System.assertEquals('Dr. Smith', result[0].get('DoctorName'));
        System.assertEquals('Initial consultation', result[0].get('Treatment'));
        System.assertEquals('09:00:00', result[0].get('StartTime'));
        System.assertEquals(patient.Name, result[0].get('Patient'));
    }

    @IsTest
    static void testGetAppointments_AsDoctor() {

        Doctor__c doctor = TestDataFactory.createDoctor();
        Treatment__c treatment = TestDataFactory.createTreatment();
        Patient__c patient = TestDataFactory.createPatient(null);
        Appointment__c appointment = TestDataFactory.createAppointment(patient.Id, doctor.Id, treatment.Id);

        Profile doctorProfile = [SELECT Id FROM Profile WHERE Name = 'Doctor' LIMIT 1];
        User doctorUser = new User(
            ProfileId = doctorProfile.Id,
            LastName = 'DoctorUser',
            Username = 'doctoruser' + System.currentTimeMillis() + '@test.com',
            Email = 'doctoruser' + System.currentTimeMillis() + '@test.com',
            Alias = 'drusr',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert doctorUser;

        doctor.User__c = doctorUser.Id;
        update doctor;

        Test.startTest();
        System.runAs(doctorUser) {
            List<Map<String, Object>> result = AppointmentController.getAppointments();
        }
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Doctor should see their own appointment');
        System.assertEquals('Dr. Smith', result[0].get('DoctorName'));
    }
}
