global class BatchCheckDiscount implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
         String query = 'SELECT Id, Name, Start_Date__c, End_Date__c, Status__c FROM Discount__c';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Discount__c> scope) {
        for (Discount__c discount : scope) {
            if (discount.Start_Date__c < Datetime.now() && discount.End_Date__c > Datetime.now()) {
                discount.Status__c = 'Active';
            } else if (discount.Start_Date__c > Datetime.now()) {
                discount.Status__c = 'Not Started';
            } else if (discount.End_Date__c < Datetime.now()) {
                discount.Status__c = 'Ended';
            }
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC) {

    }
}