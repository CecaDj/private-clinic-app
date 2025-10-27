trigger AppointmentTrigger on Appointment__c (before insert, before update) {
    if (Trigger.isBefore) {
        AppointmentTriggerHandler.beforeInsertOrUpdate(Trigger.new, Trigger.old);
    }
}
