public without sharing class PatientTriggerHandler {
    
     //Determines when Patient__c records need to be shared with the assigned portal user.
    public static void queueShareEvents(List<Patient__c> newList, Map<Id, Patient__c> oldMap) {
        if (UserInfo.getUserType() == 'PowerCustomerSuccess') return;

        List<ShareEvent__e> events = new List<ShareEvent__e>();

        for (Patient__c p : newList) {
            if (p.User__c == null) continue;

            if (Trigger.isInsert ||
                (Trigger.isUpdate && 
                 (p.User__c != oldMap.get(p.Id).User__c || 
                  p.OwnerId != oldMap.get(p.Id).OwnerId))) {

                events.add(new ShareEvent__e(
                    RecordId__c = p.Id,
                    ObjectName__c = 'Patient__c'
                ));
            }
        }

        if (!events.isEmpty()) EventBus.publish(events);
    }
}
