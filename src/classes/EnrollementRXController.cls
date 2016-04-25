public with sharing class EnrollementRXController {
	//operator used for rendering condition	
	public static final String EQUALS_TO = 'equals';
	public static final String NOT_EQUALS_TO = 'not equals to';
	public static final String CONTAINS = 'contains';
	public static final String DOES_NOT_CONTAINS = 'does not contains';
	public static final String STARTS_WITH = 'starts with';
	public static final String ENDS_WITH = 'ends with';
	public static final String INCLUDES = 'includes'; 
	public static final String EXCLUDES = 'excludes'; 
	public static final String LESS_THAN = 'less than';
	public static final String GREATER_THAN = 'greater than';
	public static final String LESS_THAN_EQUALS = 'less than equals';
	public static final String GREATER_THAN_EQUALS = 'greater than equals';
	
	public static final String TYPE_AHEAD_FLD = 'TYPE AHEAD';
	public static final String LOOKUP_FLD = 'LOOKUP';
	public static final String IDFIELD = 'ID';
	public static final String PICKLISTFLD = 'PICKLIST';
	public static final String DATEFLD = 'DATE';
	public static final String DATETIMEFLD = 'DATETIME';
	public static final String REFERENCEFLD = 'REFERENCE';
	public static final String IDFLD = 'ID';
	public static final String TEXTFLD = 'STRING';
	public static final String TEXTAREAFLD = 'TEXTAREA';
	public static final String DOUBLEFLD = 'DOUBLE';
	public static final String NUMBERFLD = 'NUMBER';
	public static final String CURRENCYFLD = 'CURRENCY';
	public static final String CHECKBOXFLD = 'BOOLEAN'; 
	public static final String EMAILFLD = 'EMAIL'; 
	public static final String MULTIPICKLISTFLD = 'MULTIPICKLIST'; 
	public static final String PERCENTFLD = 'PERCENT'; 
	public static final String TIMEFLD = 'TIME'; 
	public static final String URLFLD = 'URL'; 
	public static final String PHONEFLD = 'PHONE';
	public static final String ENCRYPTEDSTRINGFLD = 'ENCRYPTEDSTRING';
	public static final String UPLOADFLD = 'UPLOAD';
	public static final String RICH_TEXT_AREA = 'RICHTEXTAREA';
	 public String objectFieldListString {get;set;}
	// Private Data Members of the NewEditPortalPageController Class
	private Map < String, Schema.SObjectType > GlobalDescribeMap = null; // Global Describe Map to Store Database schema.
	 private Map<String, Schema.SObjectField> objFieldMap = null;
    private String packageName;
    private List<ObjectFieldWrapper> objectFieldList = null;
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
	public EnrollementRXController(){
		GlobalDescribeMap = Schema.getGlobalDescribe();
        List<FieldObjectWrapper> fieldList = null;
        objectFieldList = new List<ObjectFieldWrapper>();
        for(String globalDesc : GlobalDescribeMap.keySet()) {
        	fieldList = new List<FieldObjectWrapper>();
    		objFieldMap = GlobalDescribeMap.get(globalDesc).getDescribe().fields.getMap(); // Getting All Fields Map of Object.
    		if(objFieldMap != null && !objFieldMap.isEmpty()) {
    			for(String field : objFieldMap.keySet()) {
    				if(objFieldMap.get(field).getDescribe().isAccessible()) { // Checking if Object is Accessible
    					// Add Field to the Object Related list
						if(!objFieldMap.get(field).getDescribe().getName().contains('Address') ){
						fieldList.add(new FieldObjectWrapper(objFieldMap.get(field).getDescribe().getLabel(), objFieldMap.get(field).getDescribe().getName(), 
										(String.valueOf(objFieldMap.get(field).getDescribe().getType()) == 'TEXTAREA' && objFieldMap.get(field).getDescribe().isHtmlFormatted() ? RICH_TEXT_AREA : String.valueOf(objFieldMap.get(field).getDescribe().getType())), 
										false, (String.valueOf(objFieldMap.get(field).getDescribe().getType()) == 'PICKLIST' && objFieldMap.get(field).getDescribe().isDependentPicklist()), (String.valueOf(objFieldMap.get(field).getDescribe().getType()) == 'PICKLIST' && objFieldMap.get(field).getDescribe().isDependentPicklist() ? String.valueOf(objFieldMap.get(field).getDescribe().getController()) : null), false, objFieldMap.get(field).getDescribe().isCalculated()));
						}
    				}
    			}
    		}
    		fieldList.sort();
        	objectFieldList.add(new ObjectFieldWrapper(GlobalDescribeMap.get(globalDesc).getDescribe().getLabel(), GlobalDescribeMap.get(globalDesc).getDescribe().getName(), fieldList));
        }
        // Sorting Object List
        objectFieldList.sort();
        objectFieldListString = JSON.serialize(objectFieldList);
    }
    @RemoteAction
    public static String save(String mapperobjwrapper,String pageurl){
    	FieldMappingWrapper fieldmappingwrapperobj = (FieldMappingWrapper)Json.deserialize(mapperobjwrapper,FieldMappingWrapper.class);
       	FieldMappingWrapper__c fieldmappingwrapperobject = new FieldMappingWrapper__c();
       	fieldmappingwrapperobject.targetobject__c = fieldmappingwrapperobj.targetobject;
       	fieldmappingwrapperobject.searchingobject__c= fieldmappingwrapperobj.searchingobject;
		fieldmappingwrapperobject.searchingfield__c = fieldmappingwrapperobj.searchingfield;
         fieldmappingwrapperobject.mapping__c = Json.serialize(fieldmappingwrapperobj.mapping);
       	insert fieldmappingwrapperobject;
    	
    	return JSON.serialize(pageurl);
    }
	@RemoteAction
	public static String  getLookUpDetails(String searchString,String targetObject){
		 String querystring='select AccountId,Birthdate,Email,Name from Contact where (name like \'' + '%' +  searchString + '%\''  + '  ) ' +  '';
		List<Contact> contactresults = new List<Contact>();
		List<objectmapper> objectmapperlist = new List<objectmapper>();
		contactresults = Database.query(querystring);
		for(Contact c: contactresults){
			objectmapper obj= new objectmapper(c.AccountId,c.Name,c.Birthdate,c.email);
			objectmapperlist.add(obj);
		}
		String searchresults= Json.serialize(objectmapperlist);
		return searchresults;
	}
	@RemoteAction
	public static String getLookUpFields(String objectName){
		Set<String>	rleatedobjectnames = new Set<String>();
		String objectnames='';
		 Map < String, Schema.SObjectType > GlobalDescribeMap =  Schema.getGlobalDescribe();
		Map<String, Schema.SObjectField> objFieldMap  = GlobalDescribeMap.get(objectName).getDescribe().fields.getMap();
		if(objFieldMap != null && !objFieldMap.isEmpty()) {
    			for(String field : objFieldMap.keySet()) {
    				if(objFieldMap.get(field).getDescribe().isAccessible()) { // Checking if Object is Accessible
    					for(Schema.SObjectType reference : objFieldMap.get(field).getDescribe().getReferenceTo()) {
    						if(reference.getDescribe().getName() != objectName && !reference.getDescribe().getName().contains('Address')){
    							
    							rleatedobjectnames.add(reference.getDescribe().getName());
    						}
						}
    					// Add Field to the Object Related list
    				}
    			}
    		}
    		objectnames = JSON.serialize(rleatedobjectnames);
			return objectnames;
	}
	
	@RemoteAction
	public static String getFields(String objectname){
		Set<String>	fieldnames = new Set<String>();
		String fieldnamesjson='';
		List<FieldNameTypeWrapper> fieldnametypelist = new List<FieldNameTypeWrapper>();
		 Map < String, Schema.SObjectType > GlobalDescribeMap =  Schema.getGlobalDescribe();
		Map<String, Schema.SObjectField> objFieldMap  = GlobalDescribeMap.get(objectName).getDescribe().fields.getMap();
		if(objFieldMap != null && !objFieldMap.isEmpty()) {
    			for(String field : objFieldMap.keySet()) {
    				if(objFieldMap.get(field).getDescribe().isAccessible()) { // Checking if Object is Accessible
    						if(objFieldMap.get(field).getDescribe().getName() != objectName && !objFieldMap.get(field).getDescribe().getName().contains('Address')){
    							fieldnames.add(objFieldMap.get(field).getDescribe().getName());
    							FieldNameTypeWrapper fieldnameobj = new FieldNameTypeWrapper();
    							fieldnameobj.fieldname = objFieldMap.get(field).getDescribe().getName();
    							Schema.DisplayType fieldtype= objFieldMap.get(field).getDescribe().getType();
    							fieldnameobj.fieldtype= fieldtype.name();
    							fieldnametypelist.add(fieldnameobj);
    							
    						}
						// Add Field to the Object Related list
    				}
    			}
    		}
    		fieldnamesjson = JSON.serialize(fieldnametypelist);
			return fieldnamesjson;
	}
	
	public class FieldMappingWrapper{
		String targetobject;
		String  searchingobject;
		String   searchingfield;
         List<MappingWrapper>  mapping;
	}
	public class FieldNameTypeWrapper{
		String fieldname{set;get;}
		String fieldtype{set;get;}
	}
	public class MappingWrapper{
		String sourceobject;
		String targetobject;
		 String  sourcefield;
		  String targetfield;
		  boolean isDisabled;
		  String targetfieldtype;
	}
	public class objectmapper{
		String accountId{set;get;}
		String name{Set;get;}
		Date birthdate{set;get;}
		String email{get;set;}
		public objectmapper(String accountId,String name,Date  birthdate,String email){
			this.accountId = accountId;
			this.name = name;
			this.email = email;
			this.birthdate = birthdate;
		}
	}
	
}