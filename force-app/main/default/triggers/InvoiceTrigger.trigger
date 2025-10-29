trigger InvoiceTrigger on Invoice__c (after update) {
    InvoiceTriggerHandler.queueShareEvents(Trigger.new, Trigger.oldMap);
}
