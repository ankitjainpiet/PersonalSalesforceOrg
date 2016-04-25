public with sharing class SLDSChangePasswordController {

	@RemoteAction
	public  static String	changePassword(String externaluserWrapperstring) {
		ExternaluserWrapper externaluserwrapperobj = (ExternaluserWrapper)Json.deserialize(externaluserWrapperstring,ExternaluserWrapper.class);
        return Site.changePassword(externaluserwrapperobj.newPassword, externaluserwrapperobj.verifyNewPassword, externaluserwrapperobj.oldpassword).getUrl();    
    }
    @RemoteAction
   	public static String redirectToLogin(){
   		return Site.getPathPrefix()  + page.SldsCommunityLogin.getUrl();
   	}
    public class ExternaluserWrapper{
		
    	String     newPassword{set;get;}
        String verifyNewPassword{set;get;}
         String oldpassword{set;get;}
        
	} 
<<<<<<< HEAD
}
=======
}
>>>>>>> c9ae441995b5eadb029ce72dd456e341b9e959da
