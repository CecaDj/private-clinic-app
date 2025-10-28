public with sharing class TreatmentController {

    @AuraEnabled(cacheable=true)
    public static List<Treatment__c> getAllTreatments() {
        return TreatmentService.getAllTreatments();
    }
}