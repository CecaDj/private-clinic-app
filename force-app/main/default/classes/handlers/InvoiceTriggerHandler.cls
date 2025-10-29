public without sharing class InvoiceTriggerHandler {

    // Determines when Invoice__c records need to be shared with the patient portal user.
    public static void queueShareEvents(List<Invoice__c> newList, Map<Id, Invoice__c> oldMap) {
        if (UserInfo.getUserType() == 'PowerCustomerSuccess') return;

        List<ShareEvent__e> events = new List<ShareEvent__e>();

        for (Invoice__c inv : newList) {
            if (inv.Patient__c == null) continue;

            if (inv.Status__c == 'Sent' ||
                inv.Patient__c != oldMap.get(inv.Id).Patient__c ||
                inv.OwnerId != oldMap.get(inv.Id).OwnerId) {

                events.add(new ShareEvent__e(
                    RecordId__c = inv.Id,
                    ObjectName__c = 'Invoice__c'
                ));
            }
        }

        if (!events.isEmpty()) EventBus.publish(events);
    }
}
