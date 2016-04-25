public with sharing class ENrollmentRxAdminpanelExecutorController {
	public static String searchingfield{set;get;}
	public static String fieldstoretrieve{Set;get;}
	public static  String searchingobject{Set;get;}
	public static  String targetfieldnames{set;get;}
	public class MappingWrapper{
		String sourceobject;
		String targetobject;
		 String  sourcefield;
		  String targetfield;
	}
	public class objectmapper{
		String id{set;get;}
		String name{Set;get;}
		public objectmapper(String id,String name){
			this.id = id;
			this.name = name;
			
		}
	}
	public class LookupWrapper{
		String id{Set;get;}
		String name{set;get;}
		
	}
	public  class DataMapWrapper{
		String fieldname{set;get;}
		String fielddata{set;get;}
		public DataMapWrapper(String field,String fielddata){
			this.fieldname = field;
			this.fielddata = fielddata;
		}
		
	}
	public class ObjectFieldWrapper implements Comparable{
		public String objectName {get;set;} // Object Label
		public String objectAPIName {get;set;} // Object API Name
		public List<FieldObjectWrapper> fieldList {get;set;} // Field List.
		
		public ObjectFieldWrapper(String objectName, String objectAPIName, List<FieldObjectWrapper> fieldList) {
			this.objectName = objectName;
			this.objectAPIName = objectAPIName;
			this.fieldList = fieldList;
		}
		
		public Integer compareTo(Object compareTo) {
	        ObjectFieldWrapper compareItem = (ObjectFieldWrapper)compareTo;
	        if (objectName == compareItem.objectName) return 0;
	        if (objectName > compareItem.objectName) return 1;
	        return -1;        
   		}
	}
	
	
	public class FieldObjectWrapper implements Comparable{
		private String fieldName; // Field Name
		private String fieldAPIName; // Field API Name
		private String fieldDisplayType; // Field Type
		private Boolean isChecked; // Is Checked or Not
		private Boolean isBackendDependentField; // Is Picklist is Backend Dependent or Not ? 
		private String backendControllingFieldName; // Is isBackendDependentField true then controlling field name;
		private boolean isDisabled;
		private boolean isFormulaField;
		
		public FieldObjectWrapper(String fieldName, String fieldAPIName, String fieldDisplayType, Boolean isChecked, Boolean isBackendDependentField, String backendControllingFieldName, boolean isDisabled, boolean isFormulaField) {
			this.fieldName = fieldName;
			this.fieldAPIName = fieldAPIName;
			this.fieldDisplayType = fieldDisplayType;
			this.isChecked = isChecked;
			this.isBackendDependentField = isBackendDependentField;
			this.backendControllingFieldName = backendControllingFieldName;
			this.isDisabled = isDisabled;
			this.isFormulaField = isFormulaField;
		}
		
		public Integer compareTo(Object compareTo) {
	        FieldObjectWrapper compareItem = (FieldObjectWrapper)compareTo;
	        if (fieldName == compareItem.fieldName) return 0;
	        if (fieldName > compareItem.fieldName) return 1;
	        return -1;        
   		}
	}
	public ENrollmentRxAdminpanelExecutorController(){
		if(ApexPages.currentPage().getParameters().get('id') != null){
			String id = ApexPages.currentPage().getParameters().get('id');
			String targetobject='';
			if(id.startsWith('003')){
				targetobject = 'Contact';
			}
			fieldstoretrieve='';
			targetfieldnames = '';
			searchingfield='';
			List<FieldMappingWrapper__c> fieldmappinglist = 	[Select searchingfield__c,searchingobject__c,mapping__c from FieldMappingWrapper__c where targetobject__c = :targetobject];
			for(FieldMappingWrapper__c fieldobject : fieldmappinglist){
				Set<MappingWrapper> mappingwrapperobjlist = (Set<MappingWrapper>)Json.deserialize(fieldobject.mapping__c,Set<MappingWrapper>.class);
				searchingfield = fieldobject.searchingfield__c;
				System.debug(mappingwrapperobjlist);
				searchingobject = fieldobject.searchingobject__c;
				for(MappingWrapper mappingwrapperobj: mappingwrapperobjlist){
					if(!fieldstoretrieve.contains(mappingwrapperobj.targetfield)){
					fieldstoretrieve += mappingwrapperobj.targetfield + ',';
					}
					targetfieldnames += mappingwrapperobj.sourcefield + ',';
					
				}
			}
			fieldstoretrieve = fieldstoretrieve.substring(0,fieldstoretrieve.length() -1);
			targetfieldnames = targetfieldnames.substring(0,targetfieldnames.length() -1);
		}
		
	}
	@RemoteAction
	public static  String save(String wrapper,String pagerurl,String id,String lookupwrapperstring,String sourceobject){
		String targetobject;
		LookupWrapper wrapperobj = (LookupWrapper)Json.deserialize(lookupwrapperstring,LookupWrapper.class);
		List<DataMapWrapper> fieldmappingwrapperobj = (List<DataMapWrapper>)Json.deserialize(wrapper,List<DataMapWrapper>.class);
       	if(id.startsWith('003')){
				targetobject = 'Contact';
		}
		String soql= 'Select id from ' + targetobject  +  '  where id = \''  + id + '\'' ;
		List<Sobject> sobjectlist = Database.query(soql);
		Sobject singleobj = sobjectlist.get(0);
		for(DataMapWrapper d: fieldmappingwrapperobj){
			String fieldname= d.fieldname;
			singleobj.put(fieldname,d.fielddata);
		}
		singleobj.put('AccountId',wrapperobj.id);
		update singleobj;
		return JSON.serialize(pagerurl);
	}
	@RemoteAction
	public static String  getLookUpDetails(String searchString,String searchingfields,String searchingobj){
		 String querystring='select Id,Name from ' + searchingobj + ' where (' + searchingfields + ' like \'' + '%' +  searchString + '%\''  + '  )';
		List<Sobject> contactresults = new List<Sobject>();
		List<objectmapper> objectmapperlist = new List<objectmapper>();
		contactresults = Database.query(querystring);
		for(Sobject c: contactresults){
			objectmapper obj= new objectmapper(c.id,(String)c.get('Name'));
			objectmapperlist.add(obj);
		}
		String searchresults= Json.serialize(objectmapperlist);
		return searchresults;
	}
	@RemoteAction
	public static String  getFieldstoPopulate(String fieldstoretrievejson,String searchingobjectjson,String id){
		//String soqlstring2 = 'Select id from'  + targetobject;
		String soqlstring = 	'Select' + '  ' +  fieldstoretrievejson + '  from  ' +  searchingobjectjson + ' where   id = \'' + id + '\'' ;
		List<Sobject> objlist =  Database.query(soqlstring);
		Map<String,String> fielddatamap = new Map<String,String>();
		List<String> templist = fieldstoretrievejson.split(',');
		Set<String> fieldnames = new Set<String>(templist);
		List<DataMapWrapper> datamapperlist = new List<DataMapWrapper>();
		Map<String,DataMapWrapper> mapfielddata = new Map<String,DataMapWrapper>();
		for(Sobject obj : objlist){
			for(String s: fieldnames){
				DataMapWrapper datamapperobj = new DataMapWrapper(s,(String)obj.get(s));
				mapfielddata.put(s,datamapperobj);
				datamapperlist.add(datamapperobj);
			}
		}
		String newmapjson = Json.serialize(mapfielddata);
		String mapjson = Json.serialize(datamapperlist);
		return mapjson;
	}
}