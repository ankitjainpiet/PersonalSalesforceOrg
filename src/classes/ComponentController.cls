public class ComponentController{
    // total number of records
    private integer totalRecs = 0;
    // offset size
    private integer OffsetSize = 0;
    
    // limit size
    public integer LimitSize{get;set;} 
    
    // width of table
    public Integer tableWidth{get;set;}
    
    // error Status
    public boolean errorStatus{get;set;}
    
    // sobject Name
    public String objectType{get;set;}
    
    // fields required of sobject
    public String fieldName{get;set;}
    
    // list of sobject fields
    public List<String> fieldList{get;set;}
    
    // column name to sort
    public String sortedColumn{get;set;}
        
    // column name the previous sorted
    private String prevSortedColumn{get;set;}
      
    // order to sort
    public String orderByAscDesc{get;set;}
    
    // list of sobjects to display in the form of table
    public List<SObject> sobjects{get;set;} 
    // page number to move dynamically on the page
    public Integer pageNo{get;set;}
    
    /* constructor */
    public ComponentController(){
        sortedColumn = '';
        prevSortedColumn = '';
        
      sobjects   = new   List<SObject>();
    
    }
   
    /* 
    Name: getRecordList
    Description: get the list of records
    return: List<SObject> return the list of sobjects
    */
    public List<SObject> getRecordList()
    {
        String countQuery = 'select count() from '+objectType; 
        totalRecs = Database.countQuery(countQuery);
        fieldList = new List<String>();
        fieldList.addAll(fieldName.split(','));
        String query;
        if(sortedColumn=='')
        {
            query = 'SELECT '+fieldName+' FROM '+objectType+' LIMIT '+LimitSize+' OFFSET '+OffsetSize;
        }
        else
        { 
          
            if(prevSortedColumn == sortedColumn)
            {
                if(orderByAscDesc == 'Asc') 
                {
                   orderByAscDesc = 'Desc';
                }else 
                {
                   orderByAscDesc = 'Asc';
                }
             }
            else
            {
                orderByAscDesc = 'Asc';
            }
            prevSortedColumn = sortedColumn;
            
            query = 'SELECT '+fieldName+' FROM '+objectType+' order by '+sortedColumn+' '+orderByAscDesc+' LIMIT '+LimitSize+' OFFSET '+OffsetSize;
               
            
               
        }
        System.debug(OffsetSize);
        System.debug(totalRecs);
        System.debug('Again '+orderByAscDesc );
        if(OffsetSize>=totalRecs)
        {   
            System.debug('inside');
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Warning,'No Record Found' );
            ApexPages.addmessage(msg);
        }
        else
        {
            sobjects = Database.query(query);
        }
         
        pageNo = OffsetSize/LimitSize+1;
        return sobjects; 
    }
    
    /* first page button action */
    public void FirstPage(){
        OffsetSize = 0;    
    }  
    
    /* next page button action */
    public void next(){
        OffsetSize = OffsetSize + LimitSize;   
    }  
    
    public boolean getprev(){
        if(OffsetSize == 0){
            return true;
        }else{
            return false;
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
        OffsetSize = OffsetSize - LimitSize;
    }
    
    /* Last page button action */
    public void LastPage(){
        OffsetSize = totalrecs - math.mod(totalRecs,LimitSize);
    }
    
    /*sort the record
    this function is used to set the variable sortedColumn
    */
    public void sort(){
    }
    
    /* go to the page number */
    public void go(){
        offsetSize = LimitSize * pageNo - LimitSize;    
    }
}