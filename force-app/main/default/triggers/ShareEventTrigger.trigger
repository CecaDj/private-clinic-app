trigger ShareEventTrigger on ShareEvent__e (after insert) {
    ShareEventTriggerHandler.handleEvents(Trigger.new);
}
