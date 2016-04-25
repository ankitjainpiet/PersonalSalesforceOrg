global with sharing class SldsCommunityLoginController {
	
	@RemoteAction
	public static String loginCommunityExternalUser(String externaluserWrapperstring,String pageurl,String startURL){
		ExternaluserWrapper externaluserwrapperobj = (ExternaluserWrapper)Json.deserialize(externaluserWrapperstring,ExternaluserWrapper.class);
		return Site.login(externaluserwrapperobj.emailid, externaluserwrapperobj.password, null).getUrl();
		
	}
	 // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
        return new PageReference( '/SldsCommunityLogin');
    }
   	
   	@RemoteAction
   	public static String redirectToSignup(){
   		return Site.getPathPrefix()  + page.SldsCommunitySelfRegistration.getUrl();
   	}
   	@RemoteAction
   	public static String redirectToForgotpassword(){
   		return Site.getPathPrefix()  + page.SldsForgorPassword.getUrl();
   	}
   	
	public class ExternaluserWrapper{
		
    	String     emailid{set;get;}
        String password{set;get;}
        
	}
}