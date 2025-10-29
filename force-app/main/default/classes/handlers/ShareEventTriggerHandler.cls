public without sharing class ShareEventTriggerHandler {

    // Processes events and routes them to the sharing service.
    // This enables sharing of Patient, Appointment, and Invoice records.
    public static void handleEvents(List<ShareEvent__e> events) {
        if (events == null || events.isEmpty()) return;

        Map<String, List<String>> objectToIds = new Map<String, List<String>>();

        for (ShareEvent__e evt : events) {
            if (String.isBlank(evt.RecordId__c) || String.isBlank(evt.ObjectName__c)) continue;

            if (!objectToIds.containsKey(evt.ObjectName__c)) {
                objectToIds.put(evt.ObjectName__c, new List<String>());
            }
            objectToIds.get(evt.ObjectName__c).add(evt.RecordId__c);
        }

        if (objectToIds.isEmpty()) return;

        // Process each object type
        for (String objectName : objectToIds.keySet()) {
            try {
                PortalSharingService.shareRecords(objectToIds.get(objectName), objectName);
            } catch (Exception e) {
                System.debug('Error processing ShareEvent for ' + objectName + ': ' + e.getMessage());
            }
        }
    }
}
