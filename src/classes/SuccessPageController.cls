public with sharing class SuccessPageController {
    public Product__c product { get; set; }
    public Id posId { get; set; }
    public Contact contact { get; set; }
    public User user { get; set; }
    public Id recordTypeSoldId { 
        get {
            if (recordTypeSoldId == NULL) {
                recordTypeSoldId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Sold').getRecordTypeId();
            }
                return recordTypeSoldId ;
        } 
        set;
        }

    public SuccessPageController() {
        posId = System.currentPagereference().getParameters().get('Id');
        product = [SELECT Id, Name, Name__c, Contact__c, SoldDiscount__c 
                   FROM Product__c 
                   WHERE Id = :posId AND recordTypeId = :recordTypeSoldId];
        contact = [SELECT Id, Name, Contact_Name__c, Email FROM Contact WHERE Id = :product.Contact__c];
        user = [SELECT Id, Name FROM User WHERE ContactId = :contact.Id];
    }

    public void sendAllMessages() {
        sendEmailMessage();
        sendChatterMessage();
        sendFeedMessage();
    }

    public void sendEmailMessage() {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(contact.Email);
        mail.setToAddresses(sendTo);
        mail.setReplyTo('databaseshop@support.com');
        mail.setSenderDisplayName('Data Base Shop');
        mail.setSubject('Buying confirmation');
        String body = 'Dear ' + contact.Name + ', ';
        body += 'Congratulationt you are buying -' + Product.Name__c + ' product';
        body += 'Your discount on Product is -' + String.valueof(Product.SoldDiscount__c);
        mail.setHtmlBody(body);
        mails.add(mail);
        Messaging.sendEmail(mails);
    }

    public void sendChatterMessage() {
        ConnectApi.ChatterMessages.sendMessage('Congratulationt you are buying -' + Product.Name__c + ' product', user.Id);
    }

    public void sendFeedMessage() {
        FeedItem post = new FeedItem();
        post.ParentId = contact.Id;
        post.Body = 'Congratulationt you are buying -' + Product.Name__c + ' product';
        insert post;

    }

    public PageReference returnToShop() {
        PageReference openVfpage = Page.ProductShop;
        openVfpage.setRedirect(true);
        return openvfpage; 
    }
}