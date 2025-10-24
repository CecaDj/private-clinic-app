@IsTest
public class TestDataFactory {

    public static User createPortalUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Patient Portal User' LIMIT 1];
        Account acc = new Account(Name = 'Test Business Account ' + System.currentTimeMillis());
        insert acc;

        Contact c = new Contact(
            FirstName = 'Test',
            LastName = 'PortalContact ' + System.currentTimeMillis(),
            Email = 'contact' + System.currentTimeMillis() + '@example.com',
            AccountId = acc.Id
        );
        insert c;

        User u = new User(
            ContactId = c.Id,
            ProfileId = p.Id,
            LastName = 'portaluser' + System.currentTimeMillis(),
            Username = 'portaluser' + System.currentTimeMillis() + '@test.com',
            Email = 'portaluser' + System.currentTimeMillis() + '@test.com',
            Alias = 'ptlusr',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CommunityNickname = 'nick' + String.valueOf(Crypto.getRandomInteger()),
            IsActive = true
        );
        insert u;
        return u;
    }

    public static Patient__c createPatient(Id userId) {
        Patient__c patient = new Patient__c(
            Name = 'Test Patient',
            Email_Address__c = 'patient@example.com',
            User__c = userId,
            Date_of_Birth__c = Date.newInstance(1990,1,1),
            Funding_Type__c = 'Self-Funding',
            Phone__c = '555-555',
            Address__c = '123 Test St'
        );
        insert patient;
        return patient;
    }

    public static Doctor__c createDoctor() {
        Doctor__c doctor = new Doctor__c(
            Name = 'Dr. Smith',
            Specialization__c = 'General Practitioner',
            Email__c = 'drsmith@example.com',
            Phone__c = '1234567890',
            Working_Days__c = 'Monday;Tuesday;Wednesday;Thursday;Friday',
            Working_Hours_Start__c = Time.newInstance(9,0,0,0),
            Working_Hours_End__c = Time.newInstance(17,0,0,0)
        );
        insert doctor;
        return doctor;
    }

    public static Treatment__c createTreatment() {
        Treatment__c treatment = new Treatment__c(
            Name = 'Initial consultation',
            Category__c = 'General',
            Description__c = 'Initial consultation with the doctor',
            Treatment_Fee__c = 100.00,
            Duration__c = 30
        );
        insert treatment;
        return treatment;
    }

    public static Appointment__c createAppointment(Id patientId, Id doctorId, Id treatmentId) {
        Appointment__c appointment = new Appointment__c(
            Doctor__c = doctorId,
            Patient__c = patientId,
            Treatment__c = treatmentId,
            Date__c = Date.today().toStartOfWeek().addDays(8),
            Start_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        insert appointment;
        return appointment;
    }

    public static Invoice__c createInvoice(Id patientId, Id appointmentId) {
        Invoice__c inv = new Invoice__c(
            Patient__c = patientId,
            Appointment__c = appointmentId,
            Status__c = 'Sent',
            Total_Amount__c = 100,
            Issue_Date__c = Date.today().addDays(-5),
            Due_Date__c = Date.today().addDays(-1),
            Payment_Link__c = 'https://stripe.com/pay/123'
        );
        insert inv;
        return inv;
    }
}
