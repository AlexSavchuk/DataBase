@isTest
public class ProductTriggerHandlerTest {

    @testSetup
    static void setup() {
        DataBaseSettings__c dbSet = new DataBaseSettings__c();
        dbSet.StorePeriod__c = 30;
        insert dbSet;
    }

    public static testMethod void testValidateIncomingDateField() {
        List<Product__c> lsProd = new List<Product__c>();
        for (Integer i=0; i<=4; i++) {
            Product__c prd = new Product__c();
            prd.Name__c = 'test'+i;
            prd.Title__c = 'unitTestData';
            lsProd.add(prd);
        }
        insert lsProd;

        ProductTriggerHandler.validateIncomingDateField(lsProd);
        List<Product__c> prdLs = [SELECT Id, Name, Incoming_Date__c, Title__c
                                  FROM Product__c 
                                  WHERE Title__c = 'unitTestData' LIMIT 4];

        System.assertEquals(prdLs[0].Incoming_Date__c, Date.today());
        System.assertEquals(prdLs[1].Incoming_Date__c, Date.today());
        System.assertEquals(prdLs[2].Incoming_Date__c, Date.today());
        System.assertEquals(prdLs[3].Incoming_Date__c, Date.today());

    }

    public static testMethod void testBindWithStore() {
        List<Product__c> lsProd = new List<Product__c>();
        for (Integer i=0; i<=4; i++) {
            Product__c prd = new Product__c();
            prd.Name__c = 'test'+i;
            prd.Title__c = 'unitTestData';
            prd.Incoming_Date__c = Date.today();
            lsProd.add(prd);
        }

        ProductTriggerHandler.bindWithStore(lsProd);

        System.assert(lsProd[0].Store__c != NULL);
        System.assert(lsProd[1].Store__c != NULL);
        System.assert(lsProd[2].Store__c != NULL);
        System.assert(lsProd[3].Store__c != NULL);
    }
}