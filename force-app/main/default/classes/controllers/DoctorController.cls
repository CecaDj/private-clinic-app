public with sharing class DoctorController {
    
     @AuraEnabled(cacheable=true)
    public static List<Doctor__c> getAllDoctors() {
        return DoctorService.getAllDoctors();
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getAvailableSlots(Id doctorId, Date selectedDate, Id treatmentId) {
        return DoctorService.getAvailableSlots(doctorId, selectedDate, treatmentId);
    }
}