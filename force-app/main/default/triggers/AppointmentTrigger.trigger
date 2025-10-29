trigger AppointmentTrigger on Appointment__c (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        AppointmentTriggerHandler.beforeInsertOrUpdate(Trigger.new, Trigger.old);
    }

    if (Trigger.isAfter) {
        AppointmentTriggerHandler.queueShareEvents(Trigger.new, Trigger.oldMap);    
    }
}
