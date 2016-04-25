public class SearchController {
        public String query{get;set;}
      	public User user{get;set;}
        public List<KnowledgeArticleVersion> articleList{get;set;}
        public List<KnowledgeArticleVoteStat> scoreList{get;set;}
        public List<ArticleWrapper> articlewrapper{get;set;}
        public String selectedDealerVuModule{set;get;}
        public String selectedJobRole{set;get;}
		public String selectedLanguage{get;set;}
        public String  OriginalselectedDealerVuModule{set;get;}
        public String  OriginalselectedJobRole{set;get;}
    
    	public String  LanguageLabel{get;set;}
        public String  DealerVuModuleLabel{set;get;}
        public String  JobRoleLabel{set;get;}
   		public Map<String,List<ChildLevelCategory>>	 categoryToSubCategoryMap{set;get;}
   		public Map<String,String> subCategoryToMainCategoryMap{set;get;}
        public Map<String,List<ChildLevelCategory>>	 categoryToSubCategoryMapJOBROLE{set;get;}
   		public Map<String,String> subCategoryToMainCategoryMapJOBROLE{set;get;}
        
        public  SearchController() {
            query = '';
            categoryToSubCategoryMap = new Map<String,List<ChildLevelCategory>>();
            subCategoryToMainCategoryMap = new Map<String,String>(); 
          	categoryToSubCategoryMapJOBROLE = new Map<String,List<ChildLevelCategory>>();
            subCategoryToMainCategoryMapJOBROLE = new Map<String,String>(); 
	        user = [ Select accountId,LanguageLocaleKey,SmallPhotoUrl from User where id=: UserInfo.getUserId()];
            if(user.LanguageLocaleKey == 'en_US'){
            LanguageLabel = 'English';
            }
            else{
            LanguageLabel = 'French';
            	
            }
            DealerVuModuleLabel = 'DealerVu Module';
            JobRoleLabel = 'Job Role';
            if(ApexPages.currentPage().getParameters().get('query') !=null)
                query =   ApexPages.currentPage().getParameters().get('query');
            if(query!= null || query !='')
            {  
                selectedDealerVuModule = 'MODULE__c';
                selectedJobRole = 'JOB_ROLE__c';	
                selectedLanguage = user.LanguageLocaleKey;	
                OriginalselectedJobRole =  'JOB_ROLE' ;
                OriginalselectedDealerVuModule = 'MODULE';
                FilterArticles();		
                createcategory();											    				
            }
            
        }
        public void resetFilter(){
			String qryString = '';
			selectedDealerVuModule = 'MODULE__c';
			selectedJobRole = 'JOB_ROLE__c';	
			selectedLanguage = user.LanguageLocaleKey;	
			OriginalselectedJobRole =  'JOB_ROLE' ;
	  		OriginalselectedDealerVuModule = 'MODULE';
	    	FilterArticles();
	    }        
		public  void FilterArticles(){
			String qryString = '';
		    if(String.isEmpty(query)){
		    	query = '';
		    }
        	if(selectedJobRole.contains('JOB_ROLE') && selectedDealerVuModule.contains('MODULE')){
				 OriginalselectedJobRole   =  'JOB_ROLE';
				 OriginalselectedDealerVuModule = 'MODULE';
				 selectedDealerVuModule = 'MODULE__c';
				selectedJobRole = 'JOB_ROLE__c';	
		  				
			 qryString = 'SELECT   Id,KnowledgeArticleId,title, summary,ArticleNumber, LastPublishedDate FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language = \'' + selectedLanguage  + '\'' + 'and title   LIKE \'%'+String.escapeSingleQuotes(query)+ '%\'  )' ;
			}		 
			 else if(!selectedJobRole.contains('JOB_ROLE') && !selectedDealerVuModule.contains('MODULE')){
	  			if(!selectedJobRole.endsWith('__c')){
	  				OriginalselectedJobRole   =  selectedJobRole;
	  				selectedJobRole = selectedJobRole  + '__c' ;
	  			}
				if(!selectedDealerVuModule.endsWith('__c')){
					OriginalselectedDealerVuModule = selectedDealerVuModule;
	  				selectedDealerVuModule = selectedDealerVuModule + '__c';
				}
				 qryString = 'SELECT   Id,KnowledgeArticleId,title, summary,ArticleNumber, LastPublishedDate FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language =\'' + selectedLanguage  + '\'' + 'and title   LIKE \'%'+String.escapeSingleQuotes(query)+ '%\'  )   WITH DATA CATEGORY  DealerVu_JobRole__c   BELOW ' + selectedJobRole +  '  AND  DealerVu_Module__c     BELOW ' + selectedDealerVuModule  +  '' ;
			 }
			 else if(selectedJobRole.contains('JOB_ROLE') && !selectedDealerVuModule.contains('MODULE')){
			 	if(!selectedDealerVuModule.endsWith('__c')){
  					OriginalselectedDealerVuModule = selectedDealerVuModule;
  					selectedDealerVuModule = selectedDealerVuModule + '__c';
				}
				OriginalselectedJobRole   =  'JOB_ROLE';
  
				 qryString = 'SELECT   Id,KnowledgeArticleId,title, summary,ArticleNumber, LastPublishedDate FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language  = \'' + selectedLanguage  + '\'' + ' and title   LIKE \'%'+String.escapeSingleQuotes(query)+ '%\'  )   WITH DATA CATEGORY  DealerVu_Module__c     BELOW ' + selectedDealerVuModule  +  '' ;
			 }
			 else if(!selectedJobRole.contains('JOB_ROLE') && selectedDealerVuModule.contains('MODULE')){
						if(!selectedJobRole.endsWith('__c')){
	  							OriginalselectedJobRole   =  selectedJobRole;
	  						selectedJobRole = selectedJobRole  + '__c' ;
	  					}
						OriginalselectedDealerVuModule = 'MODULE';
					qryString = 'SELECT   Id,KnowledgeArticleId,title, summary,ArticleNumber, LastPublishedDate FROM KnowledgeArticleVersion WHERE (PublishStatus = \'online\' and Language =  \'' + selectedLanguage  + '\'' + ' and title   LIKE \'%'+String.escapeSingleQuotes(query)+ '%\'  )   WITH DATA CATEGORY DealerVu_JobRole__c    BELOW ' + selectedJobRole +  '' ;
			 }
			 articleList = new List<KnowledgeArticleVersion>();
			 articleList= Database.query(qryString);
			 getArticleWrapper(articleList);
		}
		public List<ArticleWrapper> getArticleWrapper(List<KnowledgeArticleVersion> articleList){
			 Map<String,Integer> scoredata = new Map<String,Integer>();  
			 articlewrapper = new List<ArticleWrapper>();
			String normalizedscorequery='SELECT   ParentId,NormalizedScore from  KnowledgeArticleVoteStat where Channel=\'AllChannels\' order by ParentId ';
			scoreList = new List<KnowledgeArticleVoteStat>();
			scoreList = Database.query(normalizedscorequery);
			for(KnowledgeArticleVoteStat st: scoreList){
				scoredata.put(st.ParentId,st.NormalizedScore.intValue());
			}
			for(KnowledgeArticleVersion art : articleList){
				ArticleWrapper aw = new ArticleWrapper(art.id,art.ArticleNumber, art.title,art.summary, art.LastPublishedDate,scoredata.get(art.KnowledgeArticleId)); 
				articlewrapper.add(aw);
	        } 
			return articlewrapper;
		}
			    
        public class ArticleWrapper{
        public String Id{set;get;}
        public String title{set;get;}
        public  String summary{set;get;}
        public DateTime LastPublishingDate{set;get;}
        public Integer rating{set;get;}
        public String articlenumber { get;set;}
        public ArticleWrapper(String Id,String articlenumber,String title,String summary,DateTime LastPublishingDate,Integer rating){
            this.articlenumber =articlenumber;
            this.Id = Id;
            this.summary = summary;
            this.title = title;
            this.LastPublishingDate = LastPublishingDate;
            this.rating = rating;
        }
            
       }
       
       /*
       The below code is for showing Data Category for Heirarchial way
    					 **/

		public List<JSONCategory> categories{get;set;}
		public void createcategory(){
				categories  = new List<JSONCategory>();
			    categories  = (List<JSONCategory>)System.JSON.deserialize(JSON.serialize(getDescribeDataCategoryGroupStructureResults()), List<JSONCategory>.class);  
			    System.debug(categories);
			    
			    for(JSONCategory JC : categories){
			    	System.debug(JC.name);
			    	if(JC.name == 'DealerVu_Module' ){
			    		categoryToSubCategoryMap.put(JC.name, new List<ChildLevelCategory>());
				    	for(TopLevelCategory TLC : JC.topCategories){
				    		for(ChildLevelCategory CLC : TLC.childCategories){
				    			categoryToSubCategoryMap.get(JC.name).add(CLC); 
				    			subCategoryToMainCategoryMap.put(CLC.Label, JC.name);
				    		}
				    	}
			    	}
			    	if(JC.name == 'DealerVu_JobRole' ){
			    		System.debug('inside jobrole');
			    		categoryToSubCategoryMapJOBROLE.put(JC.name, new List<ChildLevelCategory>());
				    	for(TopLevelCategory TLC : JC.topCategories){
				    		for(ChildLevelCategory CLC : TLC.childCategories){
				    			categoryToSubCategoryMapJOBROLE.get(JC.name).add(CLC); 
				    			subCategoryToMainCategoryMapJOBROLE.put(CLC.Label, JC.name);
				    		}
				    	}
			    	}
			    	
			    }
			    System.debug(subCategoryToMainCategoryMapJobRole + '-------------');
	}

public List<DescribeDataCategoryGroupStructureResult> getDescribeDataCategoryGroupStructureResults(){
		List<DescribeDataCategoryGroupResult> describeCategoryResult;
		List<DescribeDataCategoryGroupStructureResult> describeCategoryStructureResult;
		try {
			//Making the call to the describeDataCategoryGroups to
			//get the list of category groups associated
			List<String> objType = new List<String>();
			objType.add('KnowledgeArticleVersion');
			describeCategoryResult = Schema.describeDataCategoryGroups(objType);
			 
			//Creating a list of pair objects to use as a parameter
			//for the describe call
			List<DataCategoryGroupSobjectTypePair> pairs = new List<DataCategoryGroupSobjectTypePair>();
			 
			//Looping throught the first describe result to create
			//the list of pairs for the second describe call
			for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
			   DataCategoryGroupSobjectTypePair p = new DataCategoryGroupSobjectTypePair();
			   p.setSobject(singleResult.getSobject());
			   p.setDataCategoryGroupName(singleResult.getName());
			   pairs.add(p);
			 }
         
			//describeDataCategoryGroupStructures()
			describeCategoryStructureResult = Schema.describeDataCategoryGroupStructures(pairs, false);

	         //Getting data from the result
	         for(DescribeDataCategoryGroupStructureResult singleResult : describeCategoryStructureResult){
	            //Get name of the associated Sobject
	
	            //Get the name of the data category group
	            singleResult.getName();
	
	            //Get the top level categories
	            DataCategory [] toplevelCategories =  singleResult.getTopCategories();
	            
	            //Recursively get all the categories
	            List<DataCategory> allCategories = getAllCategories(toplevelCategories);
	
	            for(DataCategory category : allCategories) {
	               //Get the name of the category
	               category.getName();
	
	            }
	         }
   		   } 
   		   catch (Exception e){
   		 	}
			System.debug(categoryToSubCategoryMap);
	      	return describeCategoryStructureResult;
	   }
    
	   public  DataCategory[] getAllCategories(DataCategory [] categories){
	      if(categories.isEmpty()){
	         return new DataCategory[]{};
	      } else {
	         DataCategory [] categoriesClone = categories.clone();
	         DataCategory category = categoriesClone[0];
	         DataCategory[] allCategories = new DataCategory[]{category};
	         categoriesClone.remove(0);
	         categoriesClone.addAll(category.getChildCategories());
	         allCategories.addAll(getAllCategories(categoriesClone));
	         return allCategories;
	      }
	   }
	   


public class JSONCategory{
    	public String label{set;get;}
    	public String name{set;get;}
    	public List<TopLevelCategory> topCategories{set;get;}
    }
    
    public class TopLevelCategory{
    	public List<ChildLevelCategory> childCategories{set;get;}
    }
    
    @TestVisible
    public class ChildLevelCategory{
    	public List<ChildLevelCategory> childCategories{set;get;}
    	public String label{set;get;}
    	public String name{set;get;}
    }
}