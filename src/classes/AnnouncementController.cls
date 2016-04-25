public with sharing class AnnouncementController {
    public List<KnowledgeArticleVersion> announcementlist {get;set;}
    public AnnouncementController(){
        announcementlist =[SELECT Title,LastPublishedDate,Summary FROM KnowledgeArticleVersion WHERE PublishStatus='Online' AND Language = 'en_US' WITH DATA CATEGORY DealerVu_Announcement__c BELOW All__c ];        
    }
}