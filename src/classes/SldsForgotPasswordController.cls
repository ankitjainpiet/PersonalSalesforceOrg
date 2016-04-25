public with sharing class SldsForgotPasswordController {

	@RemoteAction
	public  static String	forgotPassword(String externaluserWrapperstring,String pageurl) {
		ExternaluserWrapper externaluserwrapperobj = (ExternaluserWrapper)Json.deserialize(externaluserWrapperstring,ExternaluserWrapper.class);
       	List<User> userlist =  [select id,Name from User where IsActive=true and email =: externaluserwrapperobj.username];
		if(!userlist.isEmpty()){
			boolean success = Site.forgotPassword(externaluserwrapperobj.username);
	  		if (success) {
	  			return Site.getPathPrefix()  +  page.SldsCommunityLogin.getUrl();
	  		}
	  		else{
	  			throw new CustomException('Password could not be changed successfully');
	  			return pageurl;
	  		}
		}
		else{
			throw new CustomException('No such user exists');
	  		return pageurl;
	  }
  		return pageurl;    
    }
    @RemoteAction
   	public static String redirectToLogin(){
   		return Site.getPathPrefix()  + page.SldsCommunityLogin.getUrl();
   	}
    
	public class ExternaluserWrapper{
		String     username{set;get;}
        
	} 
}