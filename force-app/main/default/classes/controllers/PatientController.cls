public with sharing class PatientController {

     //Returns the Patient record Id linked to the current Experience Cloud user.
    @AuraEnabled(cacheable = true)
    public static Id getMyPatientId() {
        return PatientService.getMyPatientId();

    }

    // Checks whether the current user's patient profile is complete. Returns true if all required fields are filled.
    @AuraEnabled(cacheable = true)
    public static Boolean isPatientProfileComplete() {
        return PatientService.isPatientProfileComplete();
        
    }
}