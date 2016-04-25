public class ContactSearch {
    public static List<Contact> searchForContacts(String lastname,String postalcode){
        List<Contact> contactlist = new List<Contact>();
        contactlist = [Select id,Name from Contact where lastname =:lastname and MailingPostalCode =: postalcode];
    	return contactlist;
    }
}