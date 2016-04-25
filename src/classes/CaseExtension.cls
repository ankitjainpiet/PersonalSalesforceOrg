public class CaseExtension {

    public List<Case> allresolvedcases { get; set; }
        
    
     public  String[] panels {get;set;}
        public List<Case> allcases {get;set;}
        
    public CaseExtension() {
            String CommunityId  = DealerVU_Community_Configuration__c.getOrgDefaults().CommunityId__c;
           
            allcases=[ Select  CaseNumber,Subject,CreatedDate ,Priority from Case where OwnerId = :UserInfo.getUserId() and communityId=: CommunityId   and status != 'Closed' ];
         allresolvedcases=[ Select  CaseNumber,Subject,CreatedDate ,Priority from Case where OwnerId = :UserInfo.getUserId() and communityId=: CommunityId   and status = 'Closed' ];
         panels = new String [ ] {Label.Create_New_Case , Label.User_Guides,Label.Custom_Forms_and_Training }; 
    }
   
}