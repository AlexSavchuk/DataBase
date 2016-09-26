@isTest
public class RawMaterialTriggerHandlerTest {

    @testSetup
    static void setup() {
        DataBaseSettings__c dbSet = new DataBaseSettings__c();
        dbSet.StorePeriod__c = 30;
        insert dbSet;
    }

    public static testMethod void testValidateIncomingDateField() {
        List<Raw_Material__c> lsRaw = new List<Raw_Material__c>();
        for (Integer i=0; i<=4; i++) {
            Raw_Material__c raw = new Raw_Material__c();
            raw.Name__c = 'test'+i;
            raw.Title__c = 'unitTestData';
            lsRaw.add(raw);
        }
        insert lsRaw;

        RawMaterialTriggerHandler.validateIncomingDateField(lsRaw);
        List<Raw_Material__c> prdLs = [SELECT Id, Name, Incoming_Date__c, Title__c
                                  FROM Raw_Material__c 
                                  WHERE Title__c = 'unitTestData' LIMIT 4];

        System.assertEquals(prdLs[0].Incoming_Date__c, Date.today());
        System.assertEquals(prdLs[1].Incoming_Date__c, Date.today());
        System.assertEquals(prdLs[2].Incoming_Date__c, Date.today());
        System.assertEquals(prdLs[3].Incoming_Date__c, Date.today());

    }

    public static testMethod void testBindWithStore() {
        List<Raw_Material__c> lsRaw = new List<Raw_Material__c>();
        for (Integer i=0; i<=4; i++) {
            Raw_Material__c raw = new Raw_Material__c();
            raw.Name__c = 'test'+i;
            raw.Title__c = 'unitTestData';
            raw.Incoming_Date__c = Date.today();
            lsRaw.add(raw);
        }

        RawMaterialTriggerHandler.bindWithStore(lsRaw);

        System.assert(lsRaw[0].Store__c != NULL);
        System.assert(lsRaw[1].Store__c != NULL);
        System.assert(lsRaw[2].Store__c != NULL);
        System.assert(lsRaw[3].Store__c != NULL);
    }
}