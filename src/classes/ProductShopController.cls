public with sharing class ProductShopController {

    public Integer size { get; set; }
    public Integer noOfRecords { get; set; }
    public String stringForSearch { get; set; }
    public List<Discount__c> userDiscounts { get; set; }
    public Boolean dicountChecker { get; set; }
    public List<SelectOption> paginationSizeOptions { get; set; }
    Map<ID, Attachment> mapAttachment = new Map<Id, Attachment>();
    public List<Attachment> atch { get; set; }
    public Id recordTypeMadeId {
        get {
            if (recordTypeMadeId == NULL) {
                recordTypeMadeId = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get('Made').getRecordTypeId();
            }
            return recordTypeMadeId;
        } 
        set;
    }

    public ProductShopController() {
        size = 10;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('5', '5'));
        paginationSizeOptions.add(new SelectOption('10', '10'));
        paginationSizeOptions.add(new SelectOption('20', '20'));
        paginationSizeOptions.add(new SelectOption('50', '50'));
        paginationSizeOptions.add(new SelectOption('100', '100'));

        User user = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        userDiscounts = [SELECT Id, Name, Discount_code__c, Static_discount__c, Percentes_of_discount__c 
                         FROM Discount__c WHERE Contact__c = :user.ContactId];
        dicountChecker = userDiscounts.isEmpty() ? false : true;
    }

     public ApexPages.StandardSetController setCon {
        get {
            if (setCon == NULL) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator([
                    SELECT Id, Name, Name__c, Title__c, Description__c, Cost__c, Amount__c 
                    FROM Product__c
                    WHERE RecordtypeId = :recordTypeMadeId AND Amount__c > 0
                ]));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }
        set;
    }

    public void doQuery() {
        String search = '%' + stringForSearch + '%';
        if (stringForSearch != NULL && stringForSearch != '') {
            setCon = new ApexPages.StandardSetController(Database.getQueryLocator([
                    SELECT Id, Name, Name__c, Title__c, Description__c, Cost__c, Amount__c 
                    FROM Product__c
                    WHERE RecordtypeId = :recordTypeMadeId 
                    AND Amount__c > 0 
                    AND Name__c LIKE :search
                ]));
            setCon.setPageSize(size);
            noOfRecords = setCon.getResultSize();
        } else {
        setCon = new ApexPages.StandardSetController(Database.getQueryLocator([
                    SELECT Id, Name, Name__c, Title__c, Description__c, Cost__c, Amount__c 
                    FROM Product__c
                    WHERE RecordtypeId = :recordTypeMadeId AND Amount__c > 0
                ]));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
        }

    }
    
     public PageReference refreshPageSize() {
         setCon.setPageSize(size);
         return NULL;
    }

    public List<ProductWrapper> getProducts() {
        List<ProductWrapper> prod = new List<ProductWrapper>();
        Set<ID> allIds = new Set<ID>();
        for (Product__c prd : (List<Product__c>) setCon.getRecords()) {
            allIds.add(prd.Id);
        }
        atch = [SELECT Id, ParentId, Body FROM Attachment WHERE ParentId IN:AllIds];
        for (Attachment ath : atch) {
            if (!mapAttachment.containsKey(ath.ParentId)) {
                mapAttachment.put(ath.ParentId, ath);
            }
        }
        for (Product__c prd : (List<Product__c>) setCon.getRecords()) {
            prod.add(new ProductWrapper(prd, mapAttachment, userDiscounts));
        }
        return prod;
    }

    public class ProductWrapper {
        public Product__c obj { get; set; }
        public String image { get; set; }
        public Decimal discount { get; set; }

        public ProductWrapper(Product__c product, Map<Id, Attachment> imageToProduct, List<Discount__c> discounts) {
            this.obj = product;
            this.image = getImageFromAttachment(product, imageToProduct);
            this.discount = getDiscount(discounts, product);
        }

        private String getImageFromAttachment(Product__c product, Map<Id, Attachment> imageToProduct) {
            Attachment images = imageToProduct.get(product.Id);
            if (images != NULL) {
                return EncodingUtil.Base64Encode(images.Body);
            }
            return NULL;
        }

        public Decimal getDiscount(List<Discount__c> discounts, Product__c product) {
            Decimal resultPrice;
            if (!discounts.isEmpty()) {
                for (Discount__c disc : discounts) {
                    Decimal st = disc.Static_discount__c == NULL ? 0 : disc.Static_discount__c;
                    Decimal pr = disc.Percentes_of_discount__c == NULL ? 0 : disc.Percentes_of_discount__c;
                    resultPrice = (product.Cost__c - st) * ((100 - pr)/100);
                }
                return resultPrice = product.Cost__c - resultPrice;
            }
            return 0;
        }
    }
}