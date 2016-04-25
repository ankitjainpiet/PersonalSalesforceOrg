/**
* Author: Hitesh Gupta
* Since: June 04, 2015
* Name: BlackPurlCommunityLoginController
* Description: Apex class which authenticate community User.
**/
global with sharing class CommunityHomeController{
    
    // community user username
    global String username {get; set;}
    
    // community user username
    global String password {get; set;}
    
    // Default Constructor
    global CommunityHomeController() {}
    
    /**
     * Name: login
     * Desc: authenticate user and after login successfully return to home page
     * @return: PageReference - Home page of community
    **/
    global PageReference login() {
        return Site.login(username, password, null); 
    } 
}