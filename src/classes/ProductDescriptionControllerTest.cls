@isTest
public class ProductDescriptionControllerTest {

    @testSetup 
    static void setup() {
        DataBaseSettings__c dbSet = new DataBaseSettings__c();
        dbSet.StorePeriod__c = 30;
        insert dbSet;

        Product__c prd = new Product__c();
        prd.Name = 'unitTest';
        prd.Title__c = 'title   ';
        prd.Description__c = 'description!description!';
        prd.Cost__c = Decimal.valueOf('100');
        prd.Amount__c = 10;
        insert prd;
    }

    public static testMethod void testGetIMagePositive() {
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];

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

        System.currentPageReference().getParameters().put('Id', prd.Id);
        ProductDescriptionController cnt = new ProductDescriptionController();
        List<String> test = cnt.getImages();
        List<Attachment> attachments = [SELECT Id, Body FROM Attachment WHERE parent.Id = :prd.id];

        System.assertEquals(test.size(), 2);
        System.assertEquals(attachments.size(), 2);
    }

    public static testMethod void testGetIMageNegative() {
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        System.currentPageReference().getParameters().put('Id', prd.Id);
        ProductDescriptionController cnt = new ProductDescriptionController();
        List<String> test = cnt.getImages();
        List<Attachment> attachments = [SELECT Id, Body FROM Attachment WHERE parent.Id = :prd.id];

        System.assert(test.isEmpty());
        System.assert(attachments.isEmpty());
    }

    public static testMethod void testGetProduct() {
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        System.currentPageReference().getParameters().put('Id', prd.Id);
        ProductDescriptionController cnt = new ProductDescriptionController();
        Product__c newprd = cnt.getProduct();

        System.assertEquals(prd.Id, newPrd.Id);

    }

    public static testMethod void testReturnToShop() {
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        System.currentPageReference().getParameters().put('Id', prd.Id);
        ProductDescriptionController cnt = new ProductDescriptionController();
        PageReference tsPage = new PageReference('/apex/productshop');
        PageReference page = cnt.returnToShop();
       
        System.assertEquals(tsPage.getUrl(), page.getUrl());
    }


}