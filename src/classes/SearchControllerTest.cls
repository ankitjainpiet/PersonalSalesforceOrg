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
@isTest
private class SearchControllerTest {

    public static testMethod void resetFilterTest() {
    	SearchController searchController = new SearchController();
        searchController.createcategory();
        Test.startTest();
        insertArticle();
        searchController.FilterArticles();
       System.assert( searchController.articlewrapper.size() == 1 );
    	//System.debug(searchController.articlewrapper.size());
    	searchController.resetFilter();
        searchController.FilterArticles();
       	System.assert( searchController.articlewrapper.size() == 1 );
        searchController.selectedDealerVuModule = 'Part_Sales_and_Management';
	    searchController.FilterArticles();
        searchController.selectedJobRole =  'JOB_ROLE';
        searchController.FilterArticles();
        System.assert( searchController.articlewrapper.size() == 0 );
         searchController.selectedJobRole = 'Accountant_Controller';
        searchController.FilterArticles();
        Test.stopTest(); 
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
      public static void insertArticle(){
    	Test__kav T = new Test__kav(Title = 'B'  + generateRandomString(10),UrlName = generateRandomString(10));
        insert T;
   		Test__DataCategorySelection categorySelection = new  Test__DataCategorySelection();
        SYstem.debug(T.id + '---t. id');
        Test__kav newT = [Select KnowledgeArticleId from Test__kav where id =: T.id ]  ;
        SYstem.debug(newT.KnowledgeArticleId + 'knowldgearticleid');
          categorySelection.ParentId = T.id;
        categorySelection.DataCategoryGroupName = 'DealerVu_Module';
        categorySelection.DataCategoryName = 'Reports';
        insert categorySelection;
     	KbManagement.PublishingService.publishArticle(newT.KnowledgeArticleId, true);
      
      }


}