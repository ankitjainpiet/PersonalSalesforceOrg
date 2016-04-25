public with sharing class CricketTeamController {
public String leftsidelistjson{set;get;}
public String selectedlistjson{set;get;}
public List<SelectOption> RightSelectedList{set;get;}
public CricketTeamController(){
	List<Contact> allplayers=[Select name from Contact where City__c !='' limit 5];
	leftsidelistjson = JSON.serialize(allplayers);	
	List<Contact> selectedplayers=[Select name from Contact where City__c !=''  limit 5 Offset 5 ];
	selectedlistjson = JSON.serialize(selectedplayers);
	RightSelectedList = new List<SelectOption>();
	RightSelectedList.add(new SelectOption('A','A'));
	RightSelectedList.add(new SelectOption('N','A'));
	
}
@RemoteAction
public static  void reviewMyTeam(String allitems,String selecteditems){
		List<GenericWrapper> allwrapperlist= (List<GenericWrapper>)Json.deserialize(allitems,List<GenericWrapper>.class);
		List<GenericWrapper> selecteditemslist= (List<GenericWrapper>)Json.deserialize(selecteditems,List<GenericWrapper>.class);
	
		System.debug(allitems);

		System.debug(selecteditems);
}

@RemoteAction
public static PageReference submitmyTeam(String teamplayers){
	List<ContactWrapper> contactwrapperlist= (List<ContactWrapper>)Json.deserialize(teamplayers,List<ContactWrapper>.class);
	List<Contact> clist=new List<Contact>();
	boolean flag=false;
	for(ContactWrapper cw : contactwrapperlist){

		if(cw.firstname == '' || cw.lastname == '')
		{
		 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter value for first name and lastname'));
		}
		else{
			Contact contactobj =new Contact(FirstName= cw.firstname,LastName= cw.lastname,BirthDate= Date.valueOf(cw.dob),City__c = cw.city,Speciality__c = cw.speciality,PlayedInternational__c = cw.playedinternational,Last_Played_Stadium_name__c = cw.lastplayedstadiumname); 
			clist.add(contactobj);
			System.debug(contactobj.BirthDate);
		}
	}
	insert clist;
	flag=true;
	if(flag){
	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Record Created Successfully.Thank you!'));
	}	
	return Page.EnrollmentPage;
}
@RemoteAction
public static List<sobject> getPlayersList(){
	List<Contact> allplayers=[Select id,name from Contact where City__c !='' limit 25];
	return allplayers;
	
}
 public class GenericWrapper
    {
    	String Name;
    	Boolean isSelected;
    	
    }
 public class ContactWrapper
    {
        //public properties
        String firstname{get;set;} 
        String lastname{get;set;} 
        Date dob{get;set;}
        String city{get;set;} 
        String speciality{get;set;}
        String playedinternational{get;set;}
        String lastplayedstadiumname{get;set;}
    }

}