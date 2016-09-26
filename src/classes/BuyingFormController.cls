public with sharing class BuyingFormController {

    public Id posId { get; set; }
    public String emailString { get; set; }
    public String promoCode { get; set; }
    public Contact contact { get; set; }
    public List<Discount__c> userDiscounts { get; set; }
    public Boolean dicountChecker { get; set; }
    public Decimal discount { get; set; }
    public Product__c product { get; set; }
    public Product__c newProduct { get; set; }
    public Id recordTypeMadeId { 
        get {
            if (recordTypeMadeId == NULL) {
                recordTypeMadeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Made').getRecordTypeId();
            }
            return recordTypeMadeId;
        }
        set;
    }

    public Id recordTypeSoldId { 
        get {
            if (recordTypeSoldId == NULL) {
                recordTypeSoldId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Sold').getRecordTypeId();
            }
            return recordTypeSoldId ;
        } 
        set;
    }

    public BuyingFormController() {
        posId = System.currentPagereference().getParameters().get('Id');
        emailString = '';
        discount = 0;
        Product__c newProduct = new Product__c();
        product = [SELECT Id, Name, Name__c, Title__c, Description__c, Cost__c, Store__c, Amount__c, RecordtypeId 
                   FROM Product__c WHERE Id = :posId];
        User user = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        userDiscounts = [SELECT Id, Name, Discount_code__c, Static_discount__c, Percentes_of_discount__c 
                         FROM Discount__c WHERE Contact__c = :user.ContactId];
        dicountChecker = userDiscounts.isEmpty() ? true : false;
        discount();
    }

       public String getImage() {
        List<Attachment> images = [SELECT Id, Body FROM Attachment WHERE ParentId = :posId];
        List<String> img = new List<String>();
        if (!images.isEmpty()) {
            for (Attachment att : images) {
                img.add(EncodingUtil.Base64Encode(att.Body));
            }
            return img[0];
        }
        return NULL;
    }

    public PageReference returnToShop() {
        PageReference openVfpage = Page.ProductShop;
        openVfpage.setRedirect(true);
        return openVfpage; 
    }

    public List<Contact> returnContacts(String email) {
        List<Contact> contacts = new List<Contact>();
        contacts = [SELECT Id, Name, Contact_Name__c, Address__c, Phone FROM Contact WHERE Email = :email];
        return contacts;
    }

    public void searchContact() {
        if (!String.isBlank(emailString)) {
            List<Contact> contacts = returnContacts(emailString);
            if (!contacts.isEmpty()) {
                contact = contacts[0];
            } else {
                contact = new Contact();
            }
        }
    }

    public PageReference successBuy() {
        PageReference openVfpage = Page.SuccessPage;
        openVfpage.setRedirect(true);
        openVfpage.getParameters().put('Id', newProduct.Id);
        return openVfpage; 
    }

    public void discount() {
        for (Discount__c disc : [SELECT Id, Name, Discount_code__c, Static_discount__c, Percentes_of_discount__c
                                 FROM Discount__c]) {
            if (!String.isBlank(promoCode) && promoCode == disc.Discount_code__c) {
                Decimal st = disc.Static_discount__c == NULL ? 0 : disc.Static_discount__c;
                Decimal pr = disc.Percentes_of_discount__c == NULL ? 0 : disc.Percentes_of_discount__c;
                discount += product.Cost__c - (product.Cost__c - st) * ((100 - pr)/100);
            }
        }
        if (!userDiscounts.isEmpty()) {
            for (Discount__c discn : userDiscounts) {
                Decimal st = discn.Static_discount__c == NULL ? 0 : discn.Static_discount__c;
                Decimal pr = discn.Percentes_of_discount__c == NULL ? 0 : discn.Percentes_of_discount__c;
                discount += product.Cost__c - (product.Cost__c - st) * ((100 - pr)/100);
            }
        }
    }

    public PageReference buy() {
        if (String.isBlank(emailString)) {
            return NULL;
        }
        List<Contact> contacts = returnContacts(emailString);
        if (!contacts.isEmpty()) {
            contacts[0].Contact_Name__c = contact.Contact_Name__c;
            contacts[0].Address__c = contact.Address__c;
            contacts[0].Phone = contact.Phone;
            try {
                update contacts[0];
            } catch(Exception e) {
                ApexPages.addMessages(e);
                return NULL;
            }
        } else {
            Contact cont = new Contact();
            cont.Email = emailString;
            cont.LastName = contact.Contact_Name__c;
            cont.Contact_Name__c = contact.Contact_Name__c;
            cont.Address__c = contact.Address__c;
            cont.Phone = contact.Phone;
            try {
                insert cont;
            } catch(Exception e) {
                ApexPages.addMessages(e);
                return NULL;
            }
        }

        if (product.Amount__c > 0) {
            newProduct = product.clone(false, true, true, true);
            newProduct.Amount__c = 1;
            newProduct.RecordTypeId = recordTypeSoldId;
            newProduct.Contact__c = contact.Id;
            newProduct.SoldDiscount__c = discount;
            newProduct.Cost__c = product.Cost__c - discount;
            product.Amount__c --; 
            system.debug('record Id is   '+ recordTypeSoldId);
            insert newProduct;
            update product;
            return successBuy();
        }
        return NULL;

    }
    
}