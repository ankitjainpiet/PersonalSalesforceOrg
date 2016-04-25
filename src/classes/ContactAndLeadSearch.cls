public class ContactAndLeadSearch {

    public static List<List<sobject>>  searchContactsAndLeads(String name){
    List<List<sObject>> searchList =     [FIND :name IN NAME FIELDS RETURNING Contact(Name),Lead(FirstName,LastName)];
    return searchList;
	}
}