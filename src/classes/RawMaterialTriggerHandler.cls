public with sharing class RawMaterialTriggerHandler {

    public static void validateIncomingDateField(List<Raw_Material__c> newRawMaterials) {
        for (Raw_Material__c rm : newRawMaterials) {
            if (rm.Incoming_Date__c == NULL) {
                rm.Incoming_Date__c = Date.today();
            }
        }
    }

    public static void bindWithStore(List<Raw_Material__c> rawMaterials) {

        List<Raw_Material__c> rawToBind = new List<Raw_Material__c>();

        for (Raw_Material__c rm : rawMaterials) {
            if (rm.Store__c == NULL) {//if User did not set a Store manually
                rawToBind.add(rm);//put such records into one array
            }
        }

        if (!rawToBind.isEmpty()) {//try to find appropriate Store for these records
            StoreFactoryExt.setStoreByIncomingDate(rawToBind);
        }

        //if there are still Raw Materials without appropriated Store -
        //just create the new one
        List<Raw_Material__c> rmWithoutStore = new List<Raw_Material__c>();
        for (Raw_Material__c rm : rawMaterials) {
            if (rm.Store__c == NULL) {
                rmWithoutStore.add(rm);
            }
        }

        if (!rmWithoutStore.isEmpty()) {
            StoreFactoryExt.bindWithNewStores(rmWithoutStore);
        }

    }
}