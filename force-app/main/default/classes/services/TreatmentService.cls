public with sharing class TreatmentService {
    public static List<Treatment__c> getAllTreatments() {
        return [
            SELECT Id, Name, Duration__c 
            FROM Treatment__c 
            ORDER BY Name
        ];
    }
}