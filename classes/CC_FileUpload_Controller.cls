/***************************************************************************************************************************************
 * NAME   : CC_FileUpload_Controller
 * DESCRIPTION  : File Upload Controller
 *    
 * @AUTHOR   : Akshay Mohan
 * @DATE   : 11-06-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Akshay Mohan				11-06-2017			Initial version      
 * Sourav Ghosh				01-05-2018			Added one custom label in label map  
 ****************************************************************************************************************************************/

 public with sharing class CC_FileUpload_Controller {

 	public class DocumentWrapper{
 		public String sId, sDocName, sComments, sStatus, sReviewComments,sDocDate,sDocId,sContentId;
 		public Boolean bReviewed;
 		//for dummy record
 		public DocumentWrapper(){}

 		public DocumentWrapper(String sContentVersionId,String sContentDocumentId, CC_Document_Detail__c objDocumentDetail){
 			sId = objDocumentDetail.Id;
 			sDocName = objDocumentDetail.Document_Type__c;
 			sComments = objDocumentDetail.Comments__c;
 			sStatus = objDocumentDetail.Status__c;
 			sReviewComments = objDocumentDetail.Review_Comments__c;
 			sDocDate = objDocumentDetail.CreatedDate.format(System.Label.CC_Date_Format);
 			String sSiteName = Site.getBaseUrl();
 			if(String.isNotBlank(sSiteName))
 				sDocId = sSiteName+'/sfc/servlet.shepherd/version/download/'+sContentVersionId;
 			else
 				sDocId = '/sfc/servlet.shepherd/version/download/'+sContentVersionId;
 			sContentId = sContentDocumentId;
 			if(String.isBlank(sStatus))
 				bReviewed = false;
 			else
 				bReviewed = true;
 		}

 		public CC_Document_Detail__c getDocument(){
 			return new CC_Document_Detail__c(Id= sId, Document_Type__c= sDocName, Comments__c = sComments,
 												Status__c= sStatus, Review_Comments__c = sReviewComments );
 		}
 	}

 	public class RequiredDocumentWrapper{
 		public String sRequired,sDocTypes;
 		public Boolean bUploaded,bMandatory;

 		public RequiredDocumentWrapper(String sRequired,String sDocTypes,Boolean bMandatory,Boolean bUploaded){
 			this.sRequired = sRequired;
 			this.sDocTypes = sDocTypes;
 			this.bMandatory = bMandatory;
 			this.bUploaded = bUploaded;
 		}
 	}

 	
    /* loadData 
    * Gets the data required to load the File Upload Component
    * @params : sRecordId, Record Id for master object for which the Document component is 
    * @params : sLookupField, lookup field from document detail which needs to be used to load the documents
    * @params : sValidator, Validator class that will do document business logic 
    * @params : sModule, Module name to load picklist values
    * 
    * @return : a JSON of the page data
    */
	@AuraEnabled
	public static String loadData(String sRecordId, String sLookupField,String sValidator,String sModule) {
		System.debug('In loadData');
		System.debug('sRecordId: '+sRecordId);
		System.debug('sLookupField: '+sLookupField);
		
		List<DocumentWrapper> lstDocs = loadDocuments(sRecordId,sLookupField);
		Set<String> setDocTypes = new Set<String>();
		for(DocumentWrapper wrapDoc : lstDocs)
			setDocTypes.add(wrapDoc.sDocName);

		Type objType = Type.forName(sValidator);
		CC_DocumentValidator_Interface validator = (CC_DocumentValidator_Interface) objType.newInstance();
		


		String sRequiredDocsJSON = validator.checkRequiredDocs(sRecordId, JSON.serialize(setDocTypes));
		String sPicklistJSON = validator.getDocUploadPicklistValues(sModule);
		//load the page labels
		Map<String,String> mapLabels = new Map<String,String>();
		mapLabels.put('CC_Label_Document_Type',System.Label.CC_Label_Document_Type);
		mapLabels.put('CC_Label_Date',System.Label.CC_Label_Date);
		mapLabels.put('CC_Label_Comments',System.Label.CC_Label_Comments);
		mapLabels.put('CC_Label_Status',System.Label.CC_Label_Status);
		mapLabels.put('CC_Label_Review_Comments',System.Label.CC_Label_Review_Comments);
		mapLabels.put('CC_Label_What_Is_Needed',System.Label.CC_Label_What_Is_Needed);
		mapLabels.put('CC_Label_Type_of_Document_Accepted',System.Label.CC_Label_Type_of_Document_Accepted);
		mapLabels.put('CC_Label_Save',System.Label.CC_Label_Save);
		mapLabels.put('CC_Confirm_Header',System.Label.CC_Confirm_Header);
		mapLabels.put('CC_Document_Not_Uploaded_Warning',System.Label.CC_Document_Not_Uploaded_Warning);
		mapLabels.put('CC_Confirm_No',System.Label.CC_Confirm_No);
		mapLabels.put('CC_Confirm_Yes',System.Label.CC_Confirm_Yes);
		mapLabels.put('CC_Label_Cancel',System.Label.CC_Label_Cancel);
		mapLabels.put('CC_Confirm_Delete',System.Label.CC_Confirm_Delete);
		mapLabels.put('CC_Document_Delete_Warning',System.Label.CC_Document_Delete_Warning);
		mapLabels.put('CC_Error_Document_Missing',System.Label.CC_Error_Document_Missing);
		mapLabels.put('CC_Document_Not_Uploaded',System.Label.CC_Document_Not_Uploaded);
		mapLabels.put('CC_Documents_Not_Required',System.Label.CC_Documents_Not_Required);
        mapLabels.put('CC_Error_Status_missing',System.Label.CC_Error_Status_missing);
        mapLabels.put('CC_Error_ReviewComments_missing',System.Label.CC_Error_ReviewComments_missing);
        mapLabels.put('CC_Error_DocName_missing',System.Label.CC_Error_DocName_missing);
        mapLabels.put('CC_DOC_DETAIL_STATUS_INVALID',System.Label.CC_DOC_DETAIL_STATUS_INVALID);

		return '{ "lstDocs" : '+JSON.serialize(lstDocs)+
				', "mapLabels" : '+JSON.serialize(mapLabels)+
				', "lstDocTypes" : '+sPicklistJSON+
				', "lstReqDocs" : '+sRequiredDocsJSON+
				', "wrapDummyDoc" : '+JSON.serialize(new DocumentWrapper())+
                ',  "lstStatus" : '+JSON.serialize(CC_Utility.getPicklistValuesWrapper(CC_Constants.CC_DOCUMENT_DETAIL,
                                                CC_Constants.CC_DOC_DETAIL_STATUS, System.Label.CC_Select_Status)) + '}';
	
    }
	/* refreshDocumentGrid 
    * Gets the files uploaded for a flow
    * @params : sRecordId, Record Id for master object for which the Document component is 
    * @params : sLookupField, lookup field from document detail which needs to be used to load the documents
    * @params : sValidator, Validator class that will do document business logic 
    * 
    * @return : a JSON of the files uploaded
    */
	@AuraEnabled
	public static String refreshDocumentGrid(String sRecordId, String sLookupField,String sValidator) {
		System.debug('In refreshDocumentGrid');
		System.debug('sRecordId: '+sRecordId);
		System.debug('sLookupField: '+sLookupField);
		deleteOrphanDocuments(sRecordId, sLookupField);

		List<DocumentWrapper> lstDocs = loadDocuments(sRecordId,sLookupField);
		Set<String> setDocTypes = new Set<String>();
		for(DocumentWrapper wrapDoc : lstDocs)
			setDocTypes.add(wrapDoc.sDocName);

		Type objType = Type.forName(sValidator);
		CC_DocumentValidator_Interface validator = (CC_DocumentValidator_Interface) objType.newInstance();
		String sRequiredDocsJSON = validator.checkRequiredDocs(sRecordId, JSON.serialize(setDocTypes));
		
		
		return '{ "lstDocs" : '+JSON.serialize(lstDocs)+
					', "lstReqDocs" : '+sRequiredDocsJSON+
					', "wrapDummyDoc" : '+JSON.serialize(new DocumentWrapper())+'}';
	}
	
	/* loadDocuments 
    * Gets the files uploaded for a flow
    * @params : sRecordId, Record Id for master object for which the Document component is 
    * @params : sLookupField, lookup field from document detail which needs to be used to load the documents
    * 
    * @return : List of Document wrapper.
    */
	public static List<DocumentWrapper> loadDocuments(String sRecordId, String sLookupField) {
		String sQuery = 'SELECT ID, Comments__c, Document_Type__c, Review_Comments__c, Status__c, CreatedDate FROM CC_Document_Detail__c '
						+' WHERE '+sLookupField+' =:sRecordId';
		//load the Document detail reocrds for the record ID passed
		Map<String,CC_Document_Detail__c> mapDocuments = new Map<String,CC_Document_Detail__c>();
		for(CC_Document_Detail__c objDoc : Database.query(sQuery))
			mapDocuments.put(objDoc.ID,objDoc);
		System.debug('mapDocuments: ' + mapDocuments);

		List<DocumentWrapper> lstDocs = new List<DocumentWrapper>();
		Set<String> setDocuments= mapDocuments.keySet();
		System.debug('setDocuments: ' +setDocuments);
		if(setDocuments.isEmpty())
			return lstDocs;
		Map<String,String> mapContentDocs = new Map<String,String>();

		//load the ContentDocumentId for the document details
		for(ContentDocumentLink doc : [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :setDocuments])
			mapContentDocs.put(doc.ContentDocumentId,doc.LinkedEntityId);
		Set<String> setContentDocs = mapContentDocs.keySet();
		System.debug('setContentDocs: ' +setContentDocs);

		//based on map create document wrapper
		for(ContentVersion docVer: [SELECT ID, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :setContentDocs])
			lstDocs.add(new DocumentWrapper(docVer.ID,docVer.ContentDocumentId,mapDocuments.get(mapContentDocs.get(docVer.ContentDocumentId))));
		System.debug('lstDocs: ' + lstDocs);
		return lstDocs;
	}

	public class FoundDoc{
		public String sDocDetailId;
		public Boolean bFound;
		public FoundDoc(String sDocDetailId,Boolean bFound){
			this.sDocDetailId = sDocDetailId;
			this.bFound = bFound;
		}
	}
	/* deleteOrphanDocuments 
    * Delete Document details without a file
    * @params : sRecordId, Record Id for master object for which the Document component is 
    * @params : sLookupField, lookup field from document detail which needs to be used to load the documents
    * 
    * @return : N/A
    */
    public static void deleteOrphanDocuments(String sRecordId, String sLookupField) {
		String sQuery = 'SELECT ID, Comments__c, Document_Type__c, Review_Comments__c, Status__c, CreatedDate FROM CC_Document_Detail__c '
						+' WHERE '+sLookupField+' =:sRecordId';
		Set<String> setDocuments = new Set<String>();
		for(CC_Document_Detail__c objDoc : Database.query(sQuery))
			setDocuments.add(objDoc.ID);
		System.debug('setDocuments: ' + setDocuments);

		Set<String> setFoundFiles = new Set<String>();
		Map<String,FoundDoc> mapFoundDocs = new Map<String,FoundDoc>(),mapFoundFiles = new Map<String,FoundDoc>() ;
		//load the ContentDocumentId for the document details
		if(setDocuments.isEmpty())
			return;
		for(ContentDocumentLink doc : [SELECT ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :setDocuments]){
			if(!mapFoundFiles.containsKey(doc.LinkedEntityId))
				mapFoundFiles.put(doc.LinkedEntityId,new FoundDoc(doc.LinkedEntityId,false));
			mapFoundDocs.put(doc.ContentDocumentId,mapFoundFiles.get(doc.LinkedEntityId));
			setFoundFiles.add(doc.LinkedEntityId);
		}
		Set<String> setFoundDocs = mapFoundDocs.keySet();
		System.debug('setFoundDocs: ' + setFoundDocs);
		System.debug('setFoundFiles: ' + setFoundFiles);

		//prepare list for orphan doc details to be deleted
		List<sObject> lstDelete = new List<sObject>();
		for(String sDocDetailId : setDocuments)
			if(!setFoundFiles.contains(sDocDetailId))
				lstDelete.add(new CC_Document_Detail__c(Id = sDocDetailId));

		// check for multiple documents under 1 doc detail
		for(ContentDocument doc : [SELECT ID FROM ContentDocument WHERE ID IN :setFoundDocs ORDER BY CreatedDate DESC]){
			if(!mapFoundDocs.get(doc.Id).bFound)
				mapFoundDocs.get(doc.Id).bFound = true;
			else
				lstDelete.add(new ContentDocument(Id = doc.Id));
		}

		System.debug('lstDelete: ' + lstDelete);
		delete lstDelete;
	}
	/* saveDocumentDetail 
    * saves document detail
    * @params : sRecordId, Record Id for master object for which the Document component is 
    * @params : sLookupField, lookup field from document detail which needs to be used to save the documents
    * @params : sJSON, JSON of document wrapper
    * 
    * @return : List of Document wrapper.
    */
	@AuraEnabled
	public static String saveDocumentDetail(String sRecordId, String sLookupField,String sJSON) {
		System.debug('In saveDocumentDetail');
		System.debug('sRecordId: '+sRecordId);
		System.debug('sLookupField: '+sLookupField);
		System.debug('sJSON: '+sJSON);

		DocumentWrapper wrapDoc = (DocumentWrapper)JSON.deserialize(sJSON,DocumentWrapper.class);
		System.debug('wrapDoc: ' + wrapDoc);

		CC_Document_Detail__c objDoc = wrapDoc.getDocument();
		objDoc.put(sLookupField,sRecordId);
		System.debug('objDoc: ' + objDoc);
		upsert objDoc;
		if(String.isNotBlank(wrapDoc.sId) && String.isNotBlank(wrapDoc.sContentId))
			deleteOldDocuments(wrapDoc.sId,wrapDoc.sContentId);
		return objDoc.Id;
	}

	/* deleteDocumentDetail 
    * Deletes the document detail list
    * @params : sJSON,  JSON of list of Record Id for document detail
    * 
    * @return : void
    */
	@AuraEnabled
	public static void deleteDocumentDetail(String sJSON) {
		System.debug('In deleteDocumentDetail');
		System.debug('sJSON: ' + sJSON);
		List<String> lstRecords = (List<String>)JSON.deserialize(sJSON, List<String>.class);
		System.debug('lstRecords: ' + lstRecords);
		List<sObject> lstDocs = new List<sObject>();
		//get all files for deletion
		for(ContentDocumentLink doc : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :lstRecords])
			lstDocs.add(new ContentDocument(Id= doc.ContentDocumentId));
		//get all document detail objects to be deleted.
		for(String sRecordId : lstRecords)
			lstDocs.add(new CC_Document_Detail__c(Id = sRecordId));
		System.debug('lstDocs: ' + lstDocs);
		if(!lstDocs.isEmpty())
			delete lstDocs;
	}

	/* deleteOldDocuments 
    * Deletes old documents under Document Detail
    * @params : sJSON,  JSON of list of Record Id for document 
    * 
    * @return : void
    */
	@AuraEnabled
	public static void deleteOldDocuments(String sDocDetailID, String sLatestId) {
		System.debug('In deleteOldDocuments');
		System.debug('sDocDetailID: ' + sDocDetailID);
		System.debug('sLatestId: ' + sLatestId);
		
		Set<String> setOldFileIds = new Set<String>();
		List<ContentDocument> lstOldFiles = new List<ContentDocument>();
		for(ContentDocumentLink doc : [SELECT ContentDocumentId FROM ContentDocumentLink 
										WHERE LinkedEntityId = :sDocDetailID AND ContentDocumentId != :sLatestId])
			if(!setOldFileIds.contains(doc.ContentDocumentId)){
				System.debug('Adding ID: '+doc.ContentDocumentId);
				setOldFileIds.add(doc.ContentDocumentId);
				lstOldFiles.add(new ContentDocument(Id = doc.ContentDocumentId));
			}
		System.debug('lstOldFiles: '+ lstOldFiles);
		delete lstOldFiles;
	}

	/* setPageVisited 
    * Sets the page is visited
    * @params : sRecordId, Record Id for master object for which the Document component is 
    * @params : sValidator, Validator class that will do document business logic 
    * 
    * @return : N/A
    */
	@AuraEnabled
	public static void setPageVisited(String sRecordId,String sValidator) {
		Type objType = Type.forName(sValidator);
		CC_DocumentValidator_Interface validator = (CC_DocumentValidator_Interface) objType.newInstance();
		validator.setPageVisited(sRecordId);
	}
}