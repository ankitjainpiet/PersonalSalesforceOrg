/**
 * ReferenceEdge
 *
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS-IS" BY POINT OF REFERENCE ("POR"),
 * WITH NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE,
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
 * POR SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING,
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. POR IS NOT LIABLE FOR,
 * AND MAKES NO REPRESENTATIONS OR WARRANTIES REGARDING, THE ACTIONS OR OMISSIONS OF
 * ANY THIRD PARTIES (OR THE PRODUCTS OR SERVICES OFFERED BY ANY THIRD PARTIES) INCLUDING,
 * WITHOUT LIMIATION, SALESFORCE.COM. COPY, USE OR DISTRIBUTION PROHIBITED WITHOUT EXPRESS
 * WRITTEN CONSENT FROM COMPANY.
 */
global with sharing class UploadPhotoIconController {
	/**
     * Properties and variables
     */
    private Static FINAL String fixedFileName = 'communityPic.jpg';
	private static final String baseiconurlpath= '/assets/icons/';
    public Account pageContact;
    public Id currentPicture { get; set; }
    public static String showimg{get;set;}
    public static String iconurl{get;set;}
    global UploadPhotoIconController(){
    	String id= ApexPages.currentPage().getparameters().get('id');
        String downloadurl = ''; 
        iconurl = '';
        pageContact=[Select id,icon__c from Account where id = :id ];
        iconurl = pageContact.icon__c;
        List<attachment> currentPictures = [SELECT Id,body FROM Attachment WHERE parentId = :id AND name = :fixedFileName LIMIT 1];
        if(currentPictures.size() != 0) {
            currentPicture = currentPictures.get(0).Id;
        }
    }
    @RemoteAction
    global static  String updateReferenceabilityType(String referenceabilityTypeWrapperstring,String pageurl){
    	ReferenceabilityTypeWrapper referenceabilityTypeWrapperobj=(ReferenceabilityTypeWrapper)Json.deserialize(referenceabilityTypeWrapperstring,ReferenceabilityTypeWrapper.class);
    	String currentPicture =null;
    	System.debug(referenceabilityTypeWrapperobj.iconwrapper + 'referenceabilityTypeWrapperobj.fileinstring');
    	if(referenceabilityTypeWrapperobj.fileinstring !='' && referenceabilityTypeWrapperobj.fileinstring !=null){
    	 	List<attachment> savedPicture = [SELECT Id, name, body FROM Attachment WHERE parentId = :referenceabilityTypeWrapperobj.id AND name = :fixedFileName];
  	 	 	if(savedPicture.size() > 0) {
    	    	delete savedPicture;
    		}
            Attachment a = new Attachment(parentId = referenceabilityTypeWrapperobj.id, name = fixedFileName, body = EncodingUtil.base64Decode(referenceabilityTypeWrapperobj.fileinstring));
	    	insert a;
    		showimg= referenceabilityTypeWrapperobj.fileinstring;
      		currentPicture = a.Id;
    	} 
    	if(referenceabilityTypeWrapperobj.iconwrapper !=null && referenceabilityTypeWrapperobj.iconwrapper.value !=null){
    		List<Account> reflist =[Select id,icon__c from Account where id=:referenceabilityTypeWrapperobj.id  LIMIT 1];
			if(reflist.size() > 0){
				Account refobj = reflist.get(0);
				refobj.icon__c =  baseiconurlpath + referenceabilityTypeWrapperobj.iconwrapper.value;
				update refobj;
    		}
    	}
    	return pageurl;
    }
    
	public class ReferenceabilityTypeWrapper{
		public String id{set;get;}
		public IconWrapper iconwrapper{set;get;}
		public String fileinstring{set;get;}
		public ReferenceabilityTypeWrapper (String id ,iconwrapper iconwrapperobj,String fileinstring){
			this.id= id;
			this.iconwrapper= iconwrapperobj;
			this.fileinstring = fileinstring;
		}
	}
	
	public class IconWrapper{
		public String name;
		String value;
		String cssclass;
		public IconWrapper(String name,String value,String cssclass){
			this.name = name;
			this.value = value;
			this.cssclass = cssclass;
		}
	}
}