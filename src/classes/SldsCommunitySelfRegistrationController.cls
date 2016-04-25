public with sharing class SldsCommunitySelfRegistrationController {
	public static String errormessages{Set;get;}
	private static boolean isValidPassword(String password,String confirmPassword) {
        return password == confirmPassword;
    }
    @RemoteAction
   	public static String redirectToLogin(){
   		return Site.getPathPrefix()  + page.SldsCommunityLogin.getUrl();
   	}
	@RemoteAction
	public static String createCommunityExternalUser(String externaluserWrapperstring,String pageurl,String startURL){
		ExternaluserWrapper externaluserwrapperobj = (ExternaluserWrapper)Json.deserialize(externaluserWrapperstring,ExternaluserWrapper.class);
		if (!isValidPassword(externaluserwrapperobj.password,externaluserwrapperobj.confirmPassword)) {
            errormessages = Label.site.passwords_dont_match;
            throw new CustomException(errormessages);
            
            return pageurl;
        }
        
        String profileId = null; // To be filled in by customer.
        String roleEnum = null; // To be filled in by customer.
        String accountId = ''; // To be filled in by customer.
        
        String userName = externaluserwrapperobj.emailid;
        User u = new User();
        u.Username = userName;
        u.Email = externaluserwrapperobj.emailid;
        u.FirstName = externaluserwrapperobj.firstname;
        u.LastName = externaluserwrapperobj.lastname;
        u.CommunityNickname = externaluserwrapperobj.communitynickname;
		u.ProfileId = profileId;
        String userId;
        
        try {
            userId = Site.createExternalUser(u, accountId, externaluserwrapperobj.password);
        } catch(Site.ExternalUserCreateException ex) {
        	throw new CustomException(CustomException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
            List<String> errors = ex.getDisplayMessages();
            System.debug(ex.getMessage());
        }
        if (userId != null) { 
            if (externaluserwrapperobj.password != null && externaluserwrapperobj.password.length() > 1) {
                return   Site.login(userName, externaluserwrapperobj.password, startURL).getUrl();
            }
            else {
                PageReference page = System.Page.CommunitiesSelfRegConfirm;
                page.setRedirect(true);
                return  URL.getSalesforceBaseUrl().toExternalForm() + page.getUrl();
            }
        }    
		return '';
	} 
	public class ExternaluserWrapper{
		String firstname{set;get;}
		String lastname{set;get;}
		String communitynickname{set;get;}
        String     emailid{set;get;}
        String password{set;get;}
        String 	confirmPassword{set;get;}
		
	}
}