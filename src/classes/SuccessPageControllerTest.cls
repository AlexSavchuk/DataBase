@isTest
public class SuccessPageControllerTest {

     @testSetup 
    static void setup() {
        DataBaseSettings__c dbSet = new DataBaseSettings__c();
        dbSet.StorePeriod__c = 30;
        insert dbSet;

        Contact con = new Contact();
        con.Email = 'test@test.test';
        con.Contact_Name__c = 'testContact';
        con.LastName = 'test1';
        con.Address__c = 'test str 11';
        con.Phone = '555111555';
        insert con;

        Id recId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Sold').getRecordTypeId();
        Product__c prd = new Product__c();
        prd.Name = 'unitTest';
        prd.Title__c = 'title   ';
        prd.Description__c = 'description!description!';
        prd.Cost__c = Decimal.valueOf('100');
        prd.Amount__c = 10;
        prd.RecordTypeId = recId;
        prd.Contact__c = con.Id;
        insert prd;
    }

    public static testMethod void testReturnToShop() {
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        Contact con = [SELECT Id, Contact_Name__c FROM Contact WHERE Contact_Name__c = 'testContact' LIMIT 1];
        prd.Contact__c = con.Id;
        prd.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Sold').getRecordTypeId();
        update prd;

        System.currentPageReference().getParameters().put('Id', prd.Id);
        SuccessPageController cnt = new SuccessPageController();
        PageReference tsPage = new PageReference('/apex/productshop');
        PageReference page = cnt.returnToShop();
       
        System.assertEquals(tsPage.getUrl(), page.getUrl());
    }

     public static testMethod void sendMessage() {
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        Contact con = [SELECT Id, Contact_Name__c, Email FROM Contact WHERE Contact_Name__c = 'testContact' LIMIT 1];
        System.currentPageReference().getParameters().put('Id', prd.Id);
        SuccessPageController cnt = new SuccessPageController();

        cnt.sendMessage();

     }
}