@isTest
public class ProductShopControllerTest {

    @testSetup 
    static void setup() {
        DataBaseSettings__c dbSet = new DataBaseSettings__c();
        dbSet.StorePeriod__c = 30;
        insert dbSet;

        Id recId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Made').getRecordTypeId();
        Product__c prd = new Product__c();
        prd.Name = 'unitTest';
        prd.Title__c = 'title   ';
        prd.Description__c = 'description!description!';
        prd.Cost__c = Decimal.valueOf('100');
        prd.Amount__c = 10;
        prd.RecordTypeId = recId;
        insert prd;

        Attachment attach = new Attachment();
        attach.Name = 'Unit Test Attachment 1';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body 1');
        attach.Body = bodyBlob;
        attach.parentId = prd.Id;
        insert attach;

        Attachment attach2 = new Attachment();
        attach2.Name = 'Unit Test Attachment 2';
        Blob bodyBlob2 = Blob.valueOf('Unit Test Attachment Body 2');
        attach2.Body = bodyBlob2;
        attach2.parentId = prd.Id;
        insert attach2;
    }

    public static testMethod void testRefreshPageSize() {
         Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
         ProductShopController cnt = new ProductShopController();

         System.assertEquals(10, cnt.size);

         cnt.size = 20;
         PageReference page = cnt.refreshPageSize();

         System.assertEquals(20, cnt.setCon.getPageSize());
    }

    public static testMethod void testGetProductsPositive() {
        ProductShopController cnt = new ProductShopController();
        List<ProductShopController.ProductWrapper> listPrd = cnt.getProducts();

        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        List<Attachment> atch = [SELECT Id, ParentId, Body FROM Attachment WHERE ParentId = :prd.Id];

        System.assertEquals(1, listPrd.size());
        System.assertEquals(atch, cnt.atch);
    }

    public static testMethod void testGetProductsNegative() {
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        prd.RecordTypeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Sold').getRecordTypeId();
        update prd;

        ProductShopController cnt = new ProductShopController();
        List<ProductShopController.ProductWrapper> listPrd = cnt.getProducts();

        System.assert(listPrd.isEmpty());
    }
}