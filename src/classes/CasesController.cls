public class CasesController {
    
    private integer totalRecs = 0;
       public String  searchsubject{set;get;}
    // offset size
    private integer OffsetSize = 0;
    
    // limit size
    public integer LimitSize{get;set;} 
    
    
    // error Status
    public boolean errorStatus{get;set;}
    
    // page number to move dynamically on the page
    public Integer pageNo{get;set;}
    
    public Integer LastPageno{get;set;}
    public String selectedcategory {get;set;}
    public String countquery{set;get;}
    public User user{get;set;} 
    public Case newcase{set;get;}
    public String caseNumber{get;set;} 
    public List<Case> allcases {get;set;}
    public Attachment myAttachment {get;set;} 
    String profilename {set;get;}
    public  List<SelectOption> options {get;set;}
    String CommunityId  = DealerVU_Community_Configuration__c.getOrgDefaults().CommunityId__c;
    String query{set;get;}
    public CasesController() {
                allcases = new List<Case>();
                LimitSize = 10;
                newcase = new Case();
                myAttachment = new Attachment(); 
                caseNumber='';
                selectedcategory = 'All';
                user= [Select accountId,communityNickName,Phone,email,profileId from User where id =: UserInfo.getUserId() ];
                System.debug(LimitSize + 'limiy');
                allcases.clear();
                options = new List<SelectOption>();
                options.add(new SelectOption('All',Label.All_Cases));
                options.add(new SelectOption('MyOpen',Label.My_Open_Cases));
                options.add(new SelectOption('MyClosed',Label.My_Closed_Case));
                Profile profile= [Select  name from Profile where id = :user.profileId];
                System.debug(profile);
                profilename = profile.name;
                if(! profilename.equals('DealerVu Customer Community User') ){
                options.add(new SelectOption('AllOpen', 'All Open Cases'));
                options.add(new SelectOption('AllClosed','All Closed Cases'));
                }
                UpdateSelectedCategory();
                     
    }
 
    /* 
    Name: getRecordList
    ription: get the list of records
    return: List<SObject> return the list of sobjects
    */
    public List<Case> getRecordList()
    {
        
        System.debug('getter called');
        System.debug(OffsetSize + 'offset size');
         totalRecs =Database.countQuery(countquery);
         LastPageno =  (Integer)Math.ceil((Double) totalRecs/10);
         if(OffsetSize>=totalRecs)
        {   
            System.debug('inside');
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,'No Record Found' );
            ApexPages.addmessage(msg);
        }
        else
        {
            System.debug(query);
            allcases = Database.query(query +   'LIMIT ' +  LimitSize + ' OFFSET ' + OffsetSize );
            System.debug(query + ' ki query' );
        }
         
        pageNo = OffsetSize/LimitSize+1;
        return allcases; 
    }
    
    /* first page button action */
    public void FirstPage(){
        OffsetSize = 0;    
    }  
    
    /* next page button action */
    public void next(){
        System.debug('before change offset in next' + offsetSize);
        
        OffsetSize = OffsetSize + LimitSize;
        System.debug('After change offset in next' + offsetSize);
       
        System.debug('---------------next method');  
       System.debug(totalRecs + 'totalRecs');
        System.debug(OffsetSize + 'offset');
        System.debug(LimitSize + 'Limit');
        allcases.clear();
         getRecordList();
     //   allcases = Database.query(query);
      //  System.debug(query); 
    }  
    
    public boolean getprev(){
         System.debug(offsetSize);
               if(offsetSize != 0){
                    return false;
               }
               else{
                return true;
               }
                      
    }
    
    public boolean getnxt(){
        if((OffsetSize + LimitSize) > totalRecs){
            return true;
        }else{
            return false;
        }
    }
    
    /* previous page button action */
    public void previous(){
        System.debug('offset in previous' + offsetSize);
       if(offsetSize >= 10){
        OffsetSize = OffsetSize - LimitSize;
              getRecordList();
   
       }
      
    }
    
    /* Last page button action */
    public void LastPage(){
        OffsetSize = totalrecs - math.mod(totalRecs,LimitSize);
    }
    
    /* go to the page number */
    public void go(){
        offsetSize = LimitSize * pageNo - LimitSize;    
    }
    
    public void searchArticleById(){
        Case c= null;
        List<Case> blankcases= new List<Case>();
        allcases.clear();
        String status;
        if(selectedcategory =='MyOpen'){
                    query = 'Select  CaseNumber,Subject,CreatedDate ,status from Case where OwnerId = \'' +  UserInfo.getUserId() + '\' and  communityId=\'' +CommunityId+  '\' and CaseNumber =\'' +caseNumber +  '\'    and status!=\'Closed\'  order by CaseNumber DESC ';
                    countquery = 'Select  count() from Case where OwnerId = \'' +  UserInfo.getUserId() + '\' and  communityId=\'' +CommunityId+  '\' and CaseNumber =\'' +caseNumber +  '\'    and status!=\'Closed\'';
                    
        }
        if(selectedcategory =='AllOpen'){
                    query = 'Select  CaseNumber,Subject,CreatedDate ,status from Case where   communityId=\'' +CommunityId+  '\' and CaseNumber =\'' +caseNumber +  '\'    and status!=\'Closed\'  order by CaseNumber  ';
                    countquery = 'Select  count() from Case where   communityId=\'' +CommunityId+  '\' and CaseNumber =\'' +caseNumber +  '\'    and status!=\'Closed\' ';
       
        }
        
        if(selectedcategory =='MyClosed' ){
                    query = 'Select  CaseNumber,Subject,CreatedDate ,status from Case where OwnerId = \'' +  UserInfo.getUserId() + '\' and  communityId=\'' +CommunityId+  '\' and CaseNumber =\'' +caseNumber +  '\'    and status=\'Closed\'  order by CaseNumber DESC  ';
                    countquery = 'Select  count() from Case where OwnerId = \'' +  UserInfo.getUserId() + '\' and  communityId=\'' +CommunityId+  '\' and CaseNumber =\'' +caseNumber +  '\'    and status=\'Closed\' ';
                       
        }
        if(selectedcategory =='AllClosed' ){
                    query = 'Select  CaseNumber,Subject,CreatedDate ,status from Case where  communityId=\'' +CommunityId+  '\' and CaseNumber =\'' +caseNumber +  '\'    and status=\'Closed\'  order by CaseNumber DESC ';
                    countquery = 'Select  count() from Case where  communityId=\'' +CommunityId+  '\' and CaseNumber =\'' +caseNumber +  '\'    and status=\'Closed\'  ';
        
        }
        if(selectedcategory == 'All'){
             if(! profilename.equals('DealerVu Customer Community User') ){
               
            query = 'Select  CaseNumber,Subject,CreatedDate ,status from Case where  communityId=\'' +CommunityId+  '\' and CaseNumber =\'' +caseNumber +  '\'     order by CaseNumber DESC ';
            countquery = 'Select  count() from Case where   communityId=\'' +CommunityId+  '\' and CaseNumber =\'' +caseNumber +  '\'  ';
             }
             else
             {
                query = 'Select  CaseNumber,Subject,CreatedDate ,status from Case where OwnerId = \'' +  UserInfo.getUserId() + '\' and  communityId=\'' +CommunityId+  '\' and CaseNumber =\'' +caseNumber +  '\'     order by CaseNumber DESC ';
                countquery = 'Select  count() from Case where OwnerId = \'' +  UserInfo.getUserId() + '\' and  communityId=\'' +CommunityId+  '\' and CaseNumber =\'' +caseNumber +  '\'  ';
             }
        }
       // blankcases = [ Select  CaseNumber,Subject,CreatedDate ,status from Case where OwnerId = :UserInfo.getUserId() and communityId=: CommunityId and CaseNumber =: caseNumber  order by CaseNumber LIMIT : LimitSize OFFSET :OffsetSize];
        if(blankcases.size() > 0 ){
            allcases.add(blankcases.get(0));
        }
            getRecordList();
            totalRecs = allcases.size(); 
            LastPageno =  (Integer)Math.ceil((Double) totalRecs/10);
             pageNo = OffsetSize/LimitSize+1;
    }
    
    
    public void UpdateSelectedCategory(){
        caseNumber='';
        if(selectedcategory =='MyOpen'){
            allcases.clear();
            countquery = 'Select  count() from Case where OwnerId =\''  +  UserInfo.getUserId()  + '\' and  communityId=\'' +CommunityId+  '\'   and status!=\'Closed\'  ';
            query = 'Select  CaseNumber,Subject,CreatedDate ,status from Case where OwnerId =\''  +  UserInfo.getUserId()  + '\' and  communityId=\'' +CommunityId+  '\'   and status!=\'Closed\'  order by CaseNumber  DESC  ';
            allcases= Database.query(query);
            totalRecs = Database.countQuery(countquery); 
            LastPageno =  (Integer)Math.ceil((Double) totalRecs/10);
             pageNo = OffsetSize/LimitSize+1;
            
       
        }
        else if(selectedcategory == 'MyClosed'){
                    allcases.clear();
                    countquery = 'Select  count() from Case where OwnerId =\''  +  UserInfo.getUserId()  + '\' and  communityId=\'' +CommunityId+  '\'   and status=\'Closed\'  ';
                    query = 'Select  CaseNumber,Subject,CreatedDate ,status from Case where OwnerId = \'' +  UserInfo.getUserId() + '\' and  communityId=\'' +CommunityId+  '\'  and status=\'Closed\'   order by CaseNumber  DESC ';
                     allcases= Database.query(query);
                    totalRecs = Database.countQuery(countquery); 
                    System.debug(totalRecs + 'total records');
                    LastPageno =  (Integer)Math.ceil((Double) totalRecs/10);
                    pageNo = OffsetSize/LimitSize+1;
        
        }
        else if(selectedcategory == 'AllClosed'){
            allcases.clear();
            countquery = 'Select  count() from Case where  communityId=\'' +CommunityId+  '\'   and status=\'Closed\'  ';
            query = 'Select  CaseNumber,Subject,CreatedDate ,status from Case where communityId=\'' +CommunityId+  '\'  and status=\'Closed\'   order by CaseNumber  DESC  ' ;
             allcases= Database.query(query );
            totalRecs = Database.countQuery(countquery); 
            System.debug(totalRecs + 'total records');
            LastPageno =  (Integer)Math.ceil((Double) totalRecs/10);
            pageNo = OffsetSize/LimitSize+1;
        
        }
        else if(selectedcategory == 'AllOpen')  
           { 
                    allcases.clear();
                    countquery = 'Select  count() from Case where  communityId=\'' +CommunityId+  '\'   and status!=\'Closed\'  ';
                    query = 'Select  CaseNumber,Subject,CreatedDate ,status from Case where  communityId=\'' +CommunityId+  '\'   and status!=\'Closed\'    order by CaseNumber  DESC ';
                    allcases= Database.query(query);
                    totalRecs = Database.countQuery(countquery);
                    LastPageno =  (Integer)Math.ceil((Double) totalRecs/10);
                    pageNo = OffsetSize/LimitSize+1;
           
           } 
        else{
                allcases.clear();
                     if(! profilename.equals('DealerVu Customer Community User') ){
                    countquery = 'Select  count() from Case where  communityId=\'' +CommunityId+  '\'';
                     query = 'Select  CaseNumber,Subject,CreatedDate ,status from Case where  communityId=\'' +CommunityId+  '\' order by CaseNumber DESC ' ;
                     }
                     else{
                            countquery = 'Select  count() from Case where OwnerId =\''  +  UserInfo.getUserId()  + '\' and  communityId=\'' +CommunityId+  '\' ';
                            query = 'Select  CaseNumber,Subject,CreatedDate ,status from Case where OwnerId = \'' +  UserInfo.getUserId() + '\' and  communityId=\'' +CommunityId+  '\'  order by CaseNumber  DESC ';   
                     }
                    System.debug(query);
               allcases= Database.query(query);
                totalRecs = Database.countQuery(countquery); 
                System.debug(totalRecs + 'total records');
                LastPageno =  (Integer)Math.ceil((Double) totalRecs/10);
                pageNo = OffsetSize/LimitSize+1;
        
        }
       // return allcases; 
    }
     public PageReference save(){
        newcase.communityId = CommunityId;
        if(!String.isEmpty(ApexPages.currentPage().getParameters().get('trainingcase'))){
            newcase.status = 'Training';
            System.debug('training case');
        }
        else{
            newcase.status= 'L1';
        }
        insert newcase; 
        if(myAttachment.body != null ){ 
            myAttachment.ParentId = newcase.Id;
            myAttachment.IsPrivate = false;
            insert myAttachment;
        }
        PageReference pf= page.Mycases;
        return pf;
    }
            
   
}