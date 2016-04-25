public with sharing class PaginationStandardSetController {
 Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public Integer gotoPageNumber{Set;get;}
    public ApexPages.StandardSetController setCon {
        get{
            if(setCon == null){
                size = 10;
                string queryString = 'Select CaseNumber,Subject,CreatedDate,status from Case order by CaseNumber DESC';
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                setCon.setPageSize(size);
                noOfRecords = setCon.getResultSize();
            }
            return setCon;
        }set;
    }
     
    Public List<Case> getCases(){
        List<Case> caseList = new List<Case>();
        for(Case a : (List<Case>)setCon.getRecords())
            caseList.add(a);
        return caseList;
    }
     
    public pageReference refresh() {
        setCon = null;
        getCases();
        setCon.setPageNumber(1);
        return null;
    }
public Integer totalPages {
        get {
            totalPages = setCon.getResultSize() / setCon.getPageSize();
            if(Math.mod(setCon.getResultSize(),setCon.getPageSize()) != 0){
            	totalPages+=1;
            }
            return totalPages;
        }

        set;
    }

}