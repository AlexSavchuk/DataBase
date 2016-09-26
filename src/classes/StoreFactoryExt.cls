public with sharing class StoreFactoryExt {

    public static void setStoreByIncomingDate(List<SObject> newRecords) {
        //let's query appropriate Stores from the DB
        String dynamicSOQLQuery = 'SELECT Id, Name, Start_Period__c, End_Period__c FROM Store__c WHERE ';
        String queryFilter = '';
        for (SObject record : newRecords) {
            Date incomingDate = (Date) record.get('Incoming_Date__c');
            if (!String.isBlank(queryFilter)) {
                queryFilter += ' OR ';
            }
            queryFilter += '(Store__c.Start_Period__c <= ' + String.valueOf(incomingDate) + 
            ' AND Store__c.End_Period__c >= ' + String.valueOf(incomingDate) + ' )';
        }

        dynamicSOQLQuery = dynamicSOQLQuery + queryFilter + ' LIMIT 50000';
        //go through all Stores found by condition
        for (Store__c existedStore : (List<Store__c>) Database.query(dynamicSOQLQuery)) {
            for (SObject record : newRecords) {
                if (record.get('Store__c') == NULL//to prevent double set
                        && existedStore.Start_Period__c <= (Date) record.get('Incoming_Date__c')
                        && existedStore.End_Period__c >= (Date) record.get('Incoming_Date__c')) {

                    record.put('Store__c', existedStore.Id);
                    System.debug('The selected store is ' + existedStore.Name);
                }
            }
        }

    }

    public static void bindWithNewStores(List<SObject> newRecords) {
        Integer storePeriod = getStorePeriodFromCustomSetting();
        List<Store__c> newStores = new List<Store__c>();
        Map<Date, Store__c> dateToStoreMap = new Map<Date, Store__c>();

        for (SObject record : newRecords) {
            Store__c newStore = createNewStore((Date) record.get('Incoming_Date__c'), storePeriod);
            newStores.add(newStore);
        }

        //avoid Stores with overlapping
        for (Store__c newStore : newStores) {
            for (SObject record : newRecords) {
                if (dateToStoreMap.get((Date) record.get('Incoming_Date__c')) == NULL//to prevent double set
                    && newStore.Start_Period__c <= (Date) record.get('Incoming_Date__c')
                    && newStore.End_Period__c >= (Date) record.get('Incoming_Date__c')) {

                    dateToStoreMap.put((Date) record.get('Incoming_Date__c'), newStore);
                }
            }
        }

        Set<Store__c> storesSort = new Set<Store__c>(dateToStoreMap.values()); 
        List<Store__c> storesToInsert = new List<Store__c>(storesSort);

        try {
            insert storesToInsert;
        }
        catch(DmlException dmlEx) {
            System.debug('ERROR: ' + dmlEx.getMessage());
        }

        //now we can bind our new records with the new Stores from DB
        for (SObject record : newRecords) {
            record.put('Store__c', dateToStoreMap.get((Date) record.get('Incoming_Date__c')).Id);
        }

    }

    public static Store__c createNewStore(Date incomingDate, Integer period) {
        Store__c newStore = new Store__c(
            Name = 'Store ' + String.valueOf(incomingDate),
            Start_Period__c = incomingDate,
            End_Period__c = incomingDate.addDays(period)
        );

        return newStore;
    }

    public static Integer getStorePeriodFromCustomSetting() {
        DataBaseSettings__c settings = DataBaseSettings__c.getInstance();
        return (Integer) settings.StorePeriod__c;
    }

}