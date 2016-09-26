@isTest
public class BuyingFormControllerTest {

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

        Contact con = new Contact();
        con.Email = 'test@test.test';
        con.Contact_Name__c = 'testContact';
        con.LastName = 'test1';
        con.Address__c = 'test str 11';
        con.Phone = '555111555';
        insert con;
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
        BuyingFormController cnt = new BuyingFormController();
        String test = cnt.getImage();
        List<Attachment> attachments = [SELECT Id, Body FROM Attachment WHERE parent.Id = :prd.id];
        Attachment att = attachments[0];

        System.assertEquals(test, EncodingUtil.Base64Encode(att.Body));
    }

    public static testMethod void testGetIMageNegative() {
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        System.currentPageReference().getParameters().put('Id', prd.Id);
        BuyingFormController cnt = new BuyingFormController();
        String test = cnt.getImage();

        System.assertEquals(test, NULL);
    }

    public static testMethod void testReturnToShop() {
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        System.currentPageReference().getParameters().put('Id', prd.Id);
        BuyingFormController cnt = new BuyingFormController();
        PageReference tsPage = new PageReference('/apex/productshop');
        PageReference page = cnt.returnToShop();
       
        System.assertEquals(tsPage.getUrl(), page.getUrl());
    }

    public static testMethod void testReturnContactsPositive() {
        String email = 'test@test.test';
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        System.currentPageReference().getParameters().put('Id', prd.Id);
        BuyingFormController cnt = new BuyingFormController();
        List<Contact> contacts = cnt.returnContacts(email);

        System.assertEquals(contacts.size(), 1);
        System.assertEquals(contacts[0].Contact_Name__c, 'testContact');
    }

    public static testMethod void testReturnContactsNegative() {
        String email = 'none-test@test.test';
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        System.currentPageReference().getParameters().put('Id', prd.Id);
        BuyingFormController cnt = new BuyingFormController();
        List<Contact> contacts = cnt.returnContacts(email);

        System.assert(contacts.isEmpty());
    }

    public static testMethod void testsearchContactPositive() {
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        System.currentPageReference().getParameters().put('Id', prd.Id);
        BuyingFormController cnt = new BuyingFormController();
        cnt.emailString = 'test@test.test';
        cnt.searchContact();

        System.assertEquals(cnt.contact.Contact_Name__c, 'testContact');
    }

    public static testMethod void testsearchContactNegative() {
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        System.currentPageReference().getParameters().put('Id', prd.Id);
        BuyingFormController cnt = new BuyingFormController();
        Contact tsCon = new Contact();
        cnt.emailString = 'none-test@test.test';
        cnt.searchContact();

        System.assertEquals(tsCon, cnt.contact);
    }

    public static testMethod void testSuccessBuy() {
        Product__c prd = [SELECT Id, Name FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        Product__c newPrd = new Product__c();
        insert newPrd;
        System.currentPageReference().getParameters().put('Id', prd.Id);
        BuyingFormController cnt = new BuyingFormController();
        cnt.newProduct = newPrd;
        cnt.newProduct.Id = prd.Id;
        PageReference tsPage = new PageReference('/apex/successpage');
        PageReference page = cnt.successBuy();
       
        System.assertEquals(tsPage.getUrl() + '?Id=' + prd.Id, page.getUrl());
        System.assertEquals(prd.Id, page.getParameters().get('Id'));
    }

     public static testMethod void testBuyPositive() {
        Product__c prd = [SELECT Id, Name , Amount__c FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE Email = 'test@test.test'];
        System.currentPageReference().getParameters().put('Id', prd.Id);
        BuyingFormController cnt = new BuyingFormController();
        cnt.contact = con;
        cnt.emailString = 'test@test.test';
        cnt.contact.Address__c = 'test str 20';
        cnt.contact.Contact_Name__c = 'testContact';
        cnt.contact.Phone = '223344332';
        PageReference page = cnt.buy();
        Contact newCon = [SELECT Id, Address__c FROM Contact WHERE Email = 'test@test.test'];
        Product__c newPrd = [SELECT Id, Name , Amount__c FROM Product__c WHERE Name = 'unitTest' LIMIT 1];

     
        System.assertEquals('test str 20', newCon.Address__c);
        System.assertEquals(newPrd.Amount__c, 9);
    }

    public static testMethod void testBuyNegative() {
        Product__c prd = [SELECT Id, Name , Amount__c FROM Product__c WHERE Name = 'unitTest' LIMIT 1];
        System.currentPageReference().getParameters().put('Id', prd.Id);
        BuyingFormController cnt = new BuyingFormController();
        Id id = cnt.recordTypeMadeId;
        cnt.contact = new Contact();
        cnt.emailString = 'none-test@test.test';
        cnt.contact.Address__c = 'test str 20';
        cnt.contact.Contact_Name__c = 'newTestContact';
        cnt.contact.Phone = '223344332';
        PageReference page = cnt.buy();
        Contact newCon = [SELECT Id, Contact_Name__c FROM Contact WHERE Email = 'none-test@test.test'];
        Product__c newPrd = [SELECT Id, Name , Amount__c FROM Product__c WHERE (Name = 'unitTest') 
                             AND (RecordType.Name = 'Sold') LIMIT 1];

        System.assertEquals('newTestContact', newCon.Contact_Name__c);
        System.assertEquals(newPrd.Amount__c, 1);

        cnt.emailString = '';
        PageReference page2 = cnt.buy();

        System.assertEquals(page2, NULL);

        prd.Amount__c = 0;
        update prd;
        cnt.product = prd;
        PageReference page3 = cnt.buy();

        System.assertEquals(page3, NULL);


    }


}