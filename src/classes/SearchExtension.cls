public class SearchExtension{
    public String selectedcategory{get;set;}
  
    ApexPages.StandardController sc;
    public String query{get;set;}   
    Integer currentPage = 1;
    Integer PAGE_NUMBER = 1;
    Integer maxsize=1;
    public String searchCategory{get;set;}
    public SearchExtension(){
	
        
    }
    
    public void UpdateSelectedCategory(){
        searchCategory = 'KnowledgeArticlegroup:' + selectedcategory;
    }
    
    
    public PageReference search(){
               PageReference pg=null;
       if(query!= null || query !='')
       {   pg=new PageReference('/apex/SearchbarPOC?query=' + query);
      
            pg.setRedirect(true);
           
           }
         return pg;
    }
    // Returns whether we need to see previous button or not
 public boolean getPrevRequired() {
  return currentPage > 1;
 }
 // Returns whether we need to see next button or not
 public boolean getNextRequired() {
  return currentPage * PAGE_NUMBER < maxSize;
 }
 //Returns current page number
 public Decimal getCurrentPageNumber() {
  return this.currentPage;
 }
 
 //action for next click
 public PageReference next() {
  if(maxSize > this.currentPage * PAGE_NUMBER) {
   this.currentPage = this.currentPage + 1;
  }
  return null;
 }   
  
 //action for previous click
 public PageReference previous() {       
  if(this.currentPage > 1)
   this.currentPage = this.currentPage - 1;
  return null;
 }


}