trigger RawMaterialTrigger on Raw_Material__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {
        RawMaterialTriggerHandler.validateIncomingDateField(Trigger.new);
        RawMaterialTriggerHandler.bindWithStore(Trigger.new);
    }

}