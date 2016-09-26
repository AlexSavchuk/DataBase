public with sharing class ProductDescriptionController {
    public Id posId { get; set; }

    public ProductDescriptionController() {
        posId = System.currentPagereference().getParameters().get('Id');
    }
   
    public Product__c getProduct() {
        Product__c product = [SELECT Id, Name, Name__c, Title__c, Description__c, Amount__c,
                              (SELECT Id FROM Attachments)
                              FROM Product__c
                              WHERE Id = :posId];
        return product;
    }

    public List<String> getImages() {
        List<Attachment> images = [SELECT Id, Body FROM Attachment WHERE ParentId = :posId];
        List<String> img = new List<String>();
        if (!images.isEmpty()) {
            for (Attachment att : images) {
                img.add(EncodingUtil.Base64Encode(att.Body));
            }
        }
        return img;
    }
    
    public PageReference returnToShop() {
        PageReference openVfpage = Page.ProductShop;
        openVfpage.setRedirect(true);
        return openvfpage;
    }
}