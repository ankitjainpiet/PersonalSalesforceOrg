public class HeaderComponentController {

        public User user{get;set;}
        public String query{get;set;}  
        
        public HeaderComponentController(){
                user = [ Select accountId,SmallPhotoUrl from User where id=: UserInfo.getUserId()];
        }
        
        public PageReference searchArticle(){
            PageReference pg =new PageReference('/apex/SearchResultsPage?query=' + query);
           pg.setRedirect(true);
          return pg;

        }
        
        
   }