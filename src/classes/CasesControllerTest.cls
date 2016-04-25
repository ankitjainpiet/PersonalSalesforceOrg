/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=false)
private class CasesControllerTest {   
    static List<Case> casesList{set;get;}
    public static final String communityid = Label.CommunityId;
    static DealerVU_Community_Configuration__c cs  = new DealerVU_Community_Configuration__c();
    static CasesController  casescontroller;
    public static testMethod void updateSelectedCategoryTest() {
        cs.CommunityId__c = communityid;
        insert cs;
        casescontroller = new CasesController();
        system.debug('********* '+cs.id+', CommunityId__c'+cs.CommunityId__c);
        CasesControllerTest.createCaseData('Open',10);
        System.debug(casescontroller.allcases.size() + 'cntrler');
        System.debug(casesList.size() + 'casesList');
        casescontroller.UpdateSelectedCategory();      
        System.assert(casescontroller.allcases.size() == casesList.size()); 
    	CasesControllerTest.createCaseData('Closed',10);
   		casescontroller.selectedcategory = 'MyClosed';
        casescontroller.UpdateSelectedCategory(); 
        System.debug(casescontroller.allcases.size() + 'allcases size');
        
        System.assert(casescontroller.allcases.size() == casesList.size()); 
    	CasesControllerTest.createCaseData('Closed',10);
   		casescontroller.selectedcategory = 'AllClosed';
        casescontroller.UpdateSelectedCategory(); 
        System.assert(casescontroller.allcases.size() == 2 * casesList.size()); 
		System.debug(casescontroller.allcases.size() + 'allcases size');
		CasesControllerTest.createCaseData('Open',10);
   		casescontroller.selectedcategory = 'AllOpen';
        casescontroller.UpdateSelectedCategory(); 
		System.assert(casescontroller.allcases.size() == 2 * casesList.size()); 
        casescontroller.selectedcategory = 'MyClosed';
        casescontroller.UpdateSelectedCategory(); 
        System.assert(casescontroller.allcases.size() == 2 * casesList.size()); 
       	casescontroller.selectedcategory = 'MyOpen';
        casescontroller.UpdateSelectedCategory(); 
		System.assert(casescontroller.allcases.size() == 2 * casesList.size()); 
    }
    public static testMethod void searchArticleByCaseNumberTest() {
        cs.CommunityId__c = communityid;
        insert cs;
        casescontroller = new CasesController();
        CasesControllerTest.createCaseData('Open',1);
        System.debug(casesList.size() + 'sizeof caseList');
        System.debug(casesList.get(0).id + 'id of case');
        Case searchedcase = [Select caseNumber from Case where id =:casesList.get(0).id];
        String casenumber= searchedcase.caseNumber ;  
        casescontroller.caseNumber =   caseNumber;
        casescontroller.searchArticleById();
        System.assert(casescontroller.allcases.size() == 1); 
    	casescontroller.selectedcategory = 'MyClosed';
        casescontroller.searchArticleById();
        System.assert(casescontroller.allcases.size() == 0); 
		casescontroller.selectedcategory = 'MyOpen';
        casescontroller.searchArticleById();
        System.assert(casescontroller.allcases.size() == 1); 
		casescontroller.selectedcategory = 'AllOpen';
        casescontroller.searchArticleById();
        System.assert(casescontroller.allcases.size() == 1); 
    	casescontroller.selectedcategory = 'AllClosed';
        casescontroller.searchArticleById();
        System.assert(casescontroller.allcases.size() == 0); 
		 
    }  
    public static testMethod void paginationTest() {
		 cs.CommunityId__c = communityid;
        insert cs;
        casescontroller = new CasesController();
        CasesControllerTest.createCaseData('Open',20);
        casescontroller.UpdateSelectedCategory();
        casescontroller.getRecordList();
      	casescontroller.FirstPage();
	    System.assert(casescontroller.allcases.size() == 10);
    	casescontroller.LastPage();
		casescontroller.pageNo = 1;
        casescontroller.go();
        casescontroller.allcases = casescontroller.getRecordList();
        System.assert(casescontroller.allcases.size() == 10);
        casescontroller.next();
 	    casescontroller.previous();
 		 System.debug(casescontroller.getnxt() + 'getnext');
    }
    
   	public static testMethod void saveCaseTest() {
           cs.CommunityId__c = communityid;
     	   insert cs;
     	   casescontroller = new CasesController();
      		integer previouscount =  casescontroller.allcases.size();
          	casescontroller.newcase = new Case(); 
         	casescontroller.newcase.CommunityId =  communityid ;
            casescontroller.newcase.Subject = generateRandomString(10); 
            casescontroller.newcase.Priority = 'High';
          	casescontroller.save();
			casescontroller.UpdateSelectedCategory();
      		System.assert(casescontroller.allcases.size() ==  1 + previouscount); 
    		PageReference pageRef = Page.CustomForms;
		    Test.setCurrentPage(pageRef);
		    ApexPages.currentPage().getParameters().put('trainingcase', 'true');
        	casescontroller.newcase = new Case(); 
         	casescontroller.newcase.CommunityId =  communityid ;
            casescontroller.newcase.Subject = generateRandomString(10); 
            casescontroller.newcase.Priority = 'High';
          	casescontroller.save();
			casescontroller.UpdateSelectedCategory();
        	System.assert(casescontroller.allcases.size() ==  2 + previouscount); 

    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    public static void createCaseData(String status,Integer numberofcases){
        casesList = new List<Case>();    
        for(integer i=0;i< numberofcases;i++){
            Case c=new Case();
            c.CommunityId = communityid ;
            c.Subject = generateRandomString(10); 
            c.Priority = 'High';
            c.status = status;
            casesList.add(c); 
        }  
        insert casesList;
        integer size = [Select count() from Case where communityid =: communityid ];
        System.debug(size);
    }
}