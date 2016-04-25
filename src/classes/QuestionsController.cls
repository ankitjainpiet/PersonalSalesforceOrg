public class QuestionsController {
    public  List<ConnectApi.FeedItem> questionslist {get;set;}
 
    public class QuestionWrapper{
        public ConnectApi.FeedBody feedbody {get;set;}
        public ConnectApi.FeedElementCapabilities capibility{get;set;}
	    public QuestionWrapper(ConnectApi.FeedBody feedbody, ConnectApi.FeedElementCapabilities capibility ){
        this.feedbody = feedbody;
             this.capibility = capibility;
    	}
      
	}
    public QuestionsController(){
     	// Create a list of feed items.
     	   questionslist =new List<ConnectApi.FeedItem>();
     	
     	 ConnectApi.FeedElementPage feedItemPage =  ConnectApi.ChatterFeeds.getFeedElementsFromFeed('0DB280000008P0gGAE', ConnectApi.FeedType.Home, 10, ConnectApi.FeedDensity.AllUpdates, null, 3, ConnectApi.FeedSortOrder.CreatedDateDesc, ConnectApi.FeedFilter.AllQuestions);
        List<ConnectApi.FeedItem> feeditems = new List<ConnectApi.FeedItem>();
        
        for(ConnectApi.FeedElement feedelement : feedItemPage.elements){
            if(feedelement.feedElementType == ConnectApi.FeedElementType.FeedItem){
                feeditems.add((ConnectApi.FeedItem)feedelement);
            }
        }
        // Create a list of feed item IDs.
        List<String> feedItemIds = new List<String>();
        for (ConnectApi.FeedItem aFeedItem : feeditems){
            feedItemIds.add(aFeedItem.id); 
        }

		// Get info about the feed items in the list.
		ConnectApi.BatchResult[] batchResults = ConnectApi.ChatterFeeds.getFeedElementBatch('0DB280000008P0gGAE', feedItemIds);
    
		for (ConnectApi.BatchResult batchResult : batchResults) {
        if (batchResult.isSuccess()) {
            // Operation was successful. 
            // Print the header for each feed item.  
                ConnectApi.FeedItem aFeedItem;
            if(batchResult.getResult() instanceof ConnectApi.FeedItem) {
               aFeedItem = (ConnectApi.FeedItem) batchResult.getResult();
            }
            System.debug('SUCCESS');
            
            //Feeditem aFeeditem = [Select body,capabilities from FeedItem where NetworkScope='0DB280000008P0gGAE'];
            QuestionWrapper questionwrapper=new QuestionWrapper(aFeedItem.body,aFeeditem.capabilities);
                    questionslist.add(aFeedItem); 
             
            System.debug(aFeeditem);
        }
        else {
            // Operation failed. Print errors.
            System.debug('FAILURE');
            System.debug(batchResult.getErrorMessage());
        }
        /***
         * questionslist =[SELECT ID, CreatedDate, CreatedById, CreatedBy.FirstName, CreatedBy.LastName, ParentId, Parent.Name, Body,
                     (SELECT ID, FieldName, OldValue, NewValue FROM FeedTrackedChanges ORDER BY ID DESC) 
                    FROM FeedItem 
                    WHERE  NetworkScope='0DB280000008P0gGAE' and CreatedDate > LAST_MONTH 
                    ORDER BY CreatedDate DESC, Id DESC   LIMIT 20 ];

		 **/
	         

	}
           
    }
}