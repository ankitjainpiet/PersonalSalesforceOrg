trigger ClosedOpportunityTrigger on Opportunity (before insert,before update) {
        List<Task> tasks = new List<Task>();
    for(Opportunity opportunity: Trigger.new){
        if(opportunity.StageName ==  'Closed Won'){
        	 Task tsk = new Task(whatID = opportunity.ID,subject='Follow Up Test Task'); 
            tasks.add(tsk);  
        }
        
    }
            	insert tasks; 

}