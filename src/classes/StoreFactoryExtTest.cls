@isTest
public class StoreFactoryExtTest {

    @testSetup
    static void setup() {
        DataBaseSettings__c dbSet = new DataBaseSettings__c();
        dbSet.StorePeriod__c = 20;
        insert dbSet;
    }

    public static testMethod void testSetStoreByIncomingDate() {
        List<Store__c> strLs = new List<Store__c>();
        for (Integer i=1; i<=4; i++) {
            Store__c str = new Store__c();
            str.Name = 'testStore' + i;
            str.Start_Period__c = Date.newInstance(2015, i, 20);
            str.End_Period__c = Date.newInstance(2015, i, 20).addDays(10);
            strLs.add(str);
        }
        insert strLs;

        List<Product__c> lsProd = new List<Product__c>();
        for (Integer i=1; i<=4; i++) {
            Product__c prd = new Product__c();
            prd.Name__c = 'test'+i;
            prd.Title__c = 'unitTestData';
            prd.Incoming_Date__c = Date.newInstance(2015, i, 20);
            lsProd.add(prd);
        }

        System.assertEquals(lsProd[0].Store__c, NULL);


        StoreFactoryExt.setStoreByIncomingDate(lsProd);
        List<Store__c> strLs2 = [SELECT Id, Name
                                  FROM Store__c 
                                  WHERE Name LIKE '%testStore%' LIMIT 4];

        System.assertEquals(lsProd[0].Store__c, strLs2[0].Id);
        System.assertEquals(lsProd[1].Store__c, strLs2[1].Id);
        System.assertEquals(lsProd[2].Store__c, strLs2[2].Id);
        System.assertEquals(lsProd[3].Store__c, strLs2[3].Id);
    }

    public static testMethod void testCreateNewStore() {
        Store__c str = StoreFactoryExt.createNewStore(Date.today(), 10);

        System.assertEquals('Store ' + String.valueOf(Date.today()), str.Name);
        System.assertEquals(Date.today(), str.Start_Period__c);
        System.assertEquals(Date.today().addDays(10), str.End_Period__c);
    }

    public static testMethod void testGetStorePeriodFromCustomSetting() {
        Integer i = StoreFactoryExt.getStorePeriodFromCustomSetting();

        System.assertEquals(i, 20);
    }

    public static testMethod void testBindWithNewStores() {
        List<Product__c> lsProd = new List<Product__c>();
        for (Integer i=1; i<=4; i++) {
            Product__c prd = new Product__c();
            prd.Name__c = 'test'+i;
            prd.Title__c = 'unitTestData';
            prd.Incoming_Date__c = Date.newInstance(3015, i, 20);
            lsProd.add(prd);
        }

        StoreFactoryExt.bindWithNewStores(lsProd);

        List<Store__c> lsStr = [SELECT Id, Name, Start_Period__c, End_Period__c 
                                FROM Store__c 
                                WHERE (Start_Period__c = :Date.newInstance(3015, 1, 20))
                                OR (Start_Period__c = :Date.newInstance(3015, 2, 20))
                                OR (Start_Period__c = :Date.newInstance(3015, 3, 20))
                                OR (Start_Period__c = :Date.newInstance(3015, 4, 20)) LIMIT 4];

        System.assertEquals(lsProd[0].Store__c, lsStr[0].Id);
        System.assertEquals(lsProd[1].Store__c, lsStr[1].Id);
        System.assertEquals(lsProd[2].Store__c, lsStr[2].Id);
        System.assertEquals(lsProd[3].Store__c, lsStr[3].Id);
    }
}