public with sharing class DealerVuController {
	private static final String namespace = '';
    public static Map<String, String> Contact_JSON_TO_FIELDS_MAPPING = new Map<String, String>{ 'ContactId' => 'Id',
                                                                                                'ContactName' => 'LastName' ,
                                                                                                'ContactFirstName' => 'FirstName',
                                                                                                'ContactMailingCity' => 'MailingCity',
                                                                                                'ContactState' => 'MailingState',
                                                                                                'ContactCountry' => 'MailingCountry',
                                                                                                'ContactMobilePhone' => 'MobilePhone',
                                                                                                'AccountNumber' => 'Account.AccountNumber',
                                                                                                'AccountBillingCity'=> 'Account.BillingCity',
                                                                                                'AccountBillingCountry' => 'Account.BillingCountry'
                                                                                                  };
    public class ContactWrapper{
        String ContactId{set;get;}
        String ContactName{set;get;}
        String ContactFirstName{set;get;}
        String ContactMailingCity{set;get;}
        String ContactState{set;get;}
        String ContactCountry{set;get;}
        String ContactMobilePhone{set;get;}
        String AccountNumber{set;get;}
        String AccountBillingCity{set;get;}
        String AccountBillingCountry{set;get;}
        
        public ContactWrapper(String ContactId,String ContactName,String ContactFirstName,String ContactMailingCity,
        String ContactState,String ContactCountry,String ContactMobilePhone,String AccountNumber,       String AccountBillingCity,
        String AccountBillingCountry){
            this.ContactId =    ContactId;
            this.ContactName = ContactName;
            this.ContactFirstName = ContactFirstName;
            this.ContactMailingCity = ContactMailingCity;
            this.ContactState = ContactState;
            this.ContactCountry = ContactCountry;
            this.ContactMobilePhone = ContactMobilePhone;
            this.AccountNumber = AccountNumber;
            this.AccountBillingCity = AccountBillingCity;
            this.AccountBillingCountry = AccountBillingCountry;
            
        }
    }
   /**
     * Name: getInitialData
     * Desc:  method which returns all contacts with some info of corresponding account
     * @param:
     * @return:	String  - Serialized List of ContactWrapper
    **/
    @RemoteAction
    public static String getInitialData(){
        String objectname = 'Contact';
        String querystring= 'Select ';
        String fieldstoretrieve = '';
        for(String jsonfieldname : Contact_JSON_TO_FIELDS_MAPPING.keySet()){
            fieldstoretrieve+= Contact_JSON_TO_FIELDS_MAPPING.get(jsonfieldname) + ', ';
        }
        fieldstoretrieve = fieldstoretrieve.substring(0,fieldstoretrieve.length()-2);
        querystring += fieldstoretrieve;
        querystring += ' from ' + namespace + ' ';
        querystring+=  objectname;
        List<Contact> contactobjlist= Database.query(querystring);
        List<ContactWrapper> contactwrapperobjlist= new List<ContactWrapper>();
        for(Contact contactobj : contactobjlist){
            ContactWrapper contactwrapperobj = new ContactWrapper((String)contactobj.Id,contactobj.LastName,contactobj.FirstName,contactobj.MailingCity,contactobj.MailingState,contactobj.MailingCountry, contactobj.MobilePhone,contactobj.Account.AccountNumber,contactobj.Account.BillingCity,contactobj.Account.BillingCountry);
            contactwrapperobjlist.add(contactwrapperobj);
        }
        String contactwrapperlistjson=Json.serialize(contactwrapperobjlist);
        return contactwrapperlistjson;
    }
}