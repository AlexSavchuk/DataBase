public with sharing class ProductTriggerHandler {

    public static void validateIncomingDateField(List<Product__c> newProducts) {
        for (Product__c pr : newProducts) {
            if (pr.Incoming_Date__c == NULL) {
                pr.Incoming_Date__c = Date.today();
            }
        }
    }

    public static void bindWithStore(List<Product__c> newProducts) {

        List<Product__c> productToBind = new List<Product__c>();

        for (Product__c pr : newProducts) {
            if (pr.Store__c == NULL) {//if User did not set a Store manually
                productToBind.add(pr);//put such records into one array
            }
        }

        if (!productToBind.isEmpty()) {//try to find appropriate Store for these records
            StoreFactoryExt.setStoreByIncomingDate(productToBind);
        }

        //if there are still Raw Materials without appropriated Store -
        //just create the new one
        List<Product__c> prWithoutStore = new List<Product__c>();
        for (Product__c pr : newProducts) {
            if (pr.Store__c == NULL) {
                prWithoutStore.add(pr);
            }
        }

        if (!prWithoutStore.isEmpty()) {
            StoreFactoryExt.bindWithNewStores(prWithoutStore);
        }

    }
}