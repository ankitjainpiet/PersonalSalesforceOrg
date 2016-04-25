public with sharing class ObjectSchemaController {
public Set<String>  sobjnames{set;get;}
public String generatedquery{set;get;}
public String selectedsobject{set;get;}
public Set<String> fieldnames{set;get;}
public Map<String,String> sobjidmap{Set;get;}
public String selectedfieldsjsonmap{Set;get;}
public  List<Sobject> caseList{set;get;}
public	 List<String> fieldslist{Set;get;}
  // limit size
public integer LimitSize{get;set;} 
public ObjectSchemaController(){
     sobjnames =	Schema.getGlobalDescribe().keySet();
     selectedfieldsjsonmap = '';	
     caseList = new List<Sobject>();
}
 	Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public Integer gotoPageNumber{Set;get;}
    public ApexPages.StandardSetController setCon { get{
            if(generatedquery == null || generatedquery == '' ){
                size = 10;
                string queryString = 'Select Name, Type, BillingCity, BillingState, BillingCountry from Account order by Name';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            else{
            	   size = 10;
            	 setCon = new ApexPages.StandardSetController(Database.getQueryLocator(generatedquery));
          	      setCon.setPageSize(size);
                	noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
     public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
  
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
  
    public void first() {
        setCon.first();
    }
  
    public void last() {
        setCon.last();
    }
  
    public void previous() {
        setCon.previous();
        
    }
  
    public void next() {
        setCon.next();
    }
    Public List<Sobject> getSobject(){
        for(Sobject a : (List<Sobject>)setCon.getRecords())
            caseList.add(a);
        return caseList;
    }
     
    public pageReference refresh() {
        setCon = null;
        getSobject();
        setCon.setPageNumber(1);
        return null;
    }
public Integer totalPages {
        get {
        	if(setCon !=null){
            totalPages = setCon.getResultSize() / setCon.getPageSize();
            if(Math.mod(setCon.getResultSize(),setCon.getPageSize()) != 0){
            	totalPages+=1;
            }
        	}
            return totalPages;
        }

        set;
    }
public void findFields(){
	System.debug(selectedsobject + 'getfields');
	  Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
       Map <String, Schema.SObjectField> fieldMap = schemaMap.get(selectedsobject).getDescribe().fields.getMap();
		fieldnames = fieldMap.keySet();
	
}
public void FetchSelectedFields(){
	String commasepearatedfields='';
	  System.debug(selectedsobject);
	  Map<Integer, String> b = (Map<Integer,String>) JSON.deserialize(selectedfieldsjsonmap, Map<Integer,String>.class);
	 	 System.debug(b.values());
	    fieldslist= b.values(); 
		for(String s:fieldslist){
			commasepearatedfields += s + ',';
		}
	 commasepearatedfields = commasepearatedfields.substring(0,commasepearatedfields.length() -1);
		generatedquery= 'select ' + commasepearatedfields + ' from ' +  selectedsobject;
		System.debug(generatedquery);
		queryPagination();

}
public void queryPagination(){
	           size = 10;
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(generatedquery));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
     			getSobject();
                
}
}