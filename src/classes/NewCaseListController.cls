public class NewCaseListController {

    public List<Case> getNewCases(){
        List<Case> cases=new List<Case>();
        cases=[Select id,CaseNumber from Case where status='New'];
        
        return cases; 
    }
}