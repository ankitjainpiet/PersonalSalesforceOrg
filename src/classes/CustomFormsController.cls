public with sharing class CustomFormsController {
	        public User user{get;set;}
	
	public CustomFormsController(){
	    user = [ Select accountId,SmallPhotoUrl,LanguageLocaleKey from User where id=: UserInfo.getUserId()];
        	
		
	}
}