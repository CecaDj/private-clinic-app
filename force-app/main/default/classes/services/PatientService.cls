public with sharing class PatientService {
    
    //Returns the Id of the Patient record linked to the current Experience Cloud user.
    public static Id getMyPatientId() {
        List<Patient__c> patients = [
            SELECT Id
            FROM Patient__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1
        ];
        return patients.isEmpty() ? null : patients[0].Id;
    }

    
    // Checks if the current user's patient profile is complete. Returns true if all required fields are filled.
    public static Boolean isPatientProfileComplete() {
        List<Patient__c> patients = [
            SELECT Date_of_Birth__c, Funding_Type__c, Phone__c, Address__c
            FROM Patient__c
            WHERE User__c = :UserInfo.getUserId()
            LIMIT 1
        ];

        if (patients.isEmpty()) return false;

        Patient__c p = patients[0];

        return (
            p.Date_of_Birth__c != null &&
            p.Funding_Type__c   != null &&
            p.Phone__c          != null &&
            p.Address__c        != null
        );
    }
}