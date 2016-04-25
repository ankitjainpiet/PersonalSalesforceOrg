public class SearchFilterController{

public String searchCaseNumber {get;set;}
public String searchSubject {get;set;}
public String searchquery {set;get;}
public SearchFilterController(){
                allcases = new List<Case>();
                LimitSize = 10;
				criteria = '';
				 OffsetSize = 0;    
                getRecordList();


}
   private integer totalRecs = 0;
       public String  CaseNumber{set;get;}
    // offset size
    private integer OffsetSize = 0;
    
    // limit size
    public integer LimitSize{get;set;} 
    
    
    // error Status
    public boolean errorStatus{get;set;}
    
    // page number to move dynamically on the page
    public Integer pageNo{get;set;}
    public String criteria{set;get;}
    public Integer LastPageno{get;set;}
    public String countquery{set;get;}
    public User user{get;set;} 
    public Case newcase{set;get;}
    public List<Case> allcases {get;set;}
    String query{set;get;}

     
public String createFilterQuery(){
	searchquery = 'Select  CaseNumber,Subject,CreatedDate ,status from Case ';
	criteria ='';
	if(! String.isBlank(searchCaseNumber)){
	searchquery += 'where caseNumber  =\'' +SearchCaseNumber +  '\'' ;  
	criteria  += 'where caseNumber  =\'' +SearchCaseNumber +  '\'';  
	
	}
	if(!searchquery.contains('where') && !(String.isBlank(searchSubject)) ){
	searchquery += ' where' ; 
	criteria += ' where ' ; 
	
	}
	else
	if(searchquery.contains('where') && !(String.isBlank(searchSubject)) ){
	searchquery += ' and ' ; 
	criteria += ' AND ' ; 
	
	}
	if(!(String.isBlank(searchSubject))){
	searchquery += ' subject like  \'%'  +  searchSubject +'%\''; 
	criteria += ' subject like \'%' +   searchSubject + '%\''; 
	}
	System.debug(searchquery + 'query');
	return searchquery ;
}
 /* 
    Name: getRecordList
    ription: get the list of records
    return: List<SObject> return the list of sobjects
    */
    public List<Case> getRecordList()
    {
         countquery = 'Select  count() from Case  ' + criteria;
          System.debug(searchquery + 'query');
			System.debug(countquery + ' count query');
	
          query =     createFilterQuery() +   ' order by CaseNumber  DESC  ';
          totalRecs =Database.countQuery(countquery);
           LastPageno =  (Integer)Math.ceil((Double) totalRecs/10); 
        	pageNo = OffsetSize/LimitSize+1;
    
         if(OffsetSize>=totalRecs)
        {   
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,'No Record Found' );
            ApexPages.addmessage(msg);
        }
        else
        {
            allcases = Database.query(query +   'LIMIT ' +  LimitSize + ' OFFSET ' + OffsetSize );
	    }
        return allcases; 
    }
    
    /* first page button action */
    public void FirstPage(){
        OffsetSize = 0;    
    }  
    
    /* next page button action */
    public void next(){
        OffsetSize = OffsetSize + LimitSize;
        allcases.clear();
         getRecordList();
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
      public void UpdateSelectedCategory(){
     	getRecordList();
     }
     public void searchArticle(){
     	getRecordList();
     }
     public void clear(){
     	CaseNumber = '';
     	searchSubject = '';
     	getRecordList();
     }
}