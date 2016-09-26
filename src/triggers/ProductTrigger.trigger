trigger ProductTrigger on Product__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {
        ProductTriggerHandler.validateIncomingDateField(Trigger.new);
        ProductTriggerHandler.bindWithStore(Trigger.new);
    }
}