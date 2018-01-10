/***************************************************************************************************************************************
 * NAME   : CC_ApplicationDocumentUpload_Validator
 * DESCRIPTION  : Application Document Upload Validation method.
 *    
 * @AUTHOR   : Akshay Mohan
 * @DATE   : 11-11-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Akshay Mohan				11-11-2017			Initial version        
 ****************************************************************************************************************************************/

public class CC_ApplicationDocumentUpload_Validator implements CC_DocumentValidator_Interface{

    public String checkRequiredDocs(String sRecordId,String sDocListJSON){
    	System.debug('In checkRequiredDocs');
    	System.debug('sRecordId: ' + sRecordId);
    	System.debug('sDocListJSON: ' + sDocListJSON);
    	CC_Application__c objApp = [SELECT CC_Does_Individual_have_Auth_Rep__c, CC_individual_have_LegalGuardian__c, CC_Where_does_the_individual_live__c
    								FROM CC_Application__c WHERE ID =: sRecordId];
    	System.debug('objApp: ' + objApp);
    	Set<String> setDocs = (Set<String>) JSON.deserialize(sDocListJSON, Set<String>.class);
    	System.debug('setDocs: ' + setDocs);
    	Set<String> setReqDocKeys = new Set<String>();
    	if(objApp.CC_Does_Individual_have_Auth_Rep__c)
    		setReqDocKeys.add('AR_Proof');
    	if(objApp.CC_individual_have_LegalGuardian__c)
    		setReqDocKeys.add('LG_Proof');
    	if(objApp.CC_Where_does_the_individual_live__c == System.Label.CC_Application_Living_Currently_PF || 
    		objApp.CC_Where_does_the_individual_live__c == System.Label.CC_Application_Living_Currently_ICF ||
    		objApp.CC_Where_does_the_individual_live__c == System.Label.CC_Application_Living_Currently_NH)
    		setReqDocKeys.add('LS_WhereDoYouLive');
    	System.debug('setReqDocKeys: ' + setReqDocKeys);

    	Boolean bFound;
    	List<CC_FileUpload_Controller.RequiredDocumentWrapper> lstReqDocs = new List<CC_FileUpload_Controller.RequiredDocumentWrapper>();
    	for(CC_Document_Validation__mdt objVal : [SELECT Needed_Document__c,Document_Types__c,Mandatory__c FROM CC_Document_Validation__mdt
    													WHERE DeveloperName IN :setReqDocKeys]){
    		bFound = false;
    		for(String sDocType : objVal.Document_Types__c.split(','))
    			if(setDocs.contains(sDocType)){
    				bFound=true;
    				break;
    			}

    		lstReqDocs.add(new CC_FileUpload_Controller.RequiredDocumentWrapper(objVal.Needed_Document__c, objVal.Document_Types__c,
    																				objVal.Mandatory__c,bFound));
    	}
    		
    	System.debug('lstReqDocs: ' + lstReqDocs);
        return JSON.serialize(lstReqDocs);
    }

    public String getDocUploadPicklistValues(String sModule){
    	System.debug('In getDocUploadPicklistValues');
    	System.debug('sModule: ' + sModule);
    	CC_Module__mdt objModule = [SELECT Document_Types__c FROM CC_Module__mdt WHERE DeveloperName =:sModule];
    	System.debug('objModule: ' + objModule);
    	List<String> lstValues = objModule.Document_Types__c.split(',');
    	System.debug('lstValues: ' + lstValues);
    	return JSON.serialize(CC_Utility.getPicklistValuesWrapper(System.Label.CC_Select_Document_Type,lstValues));
    }

    public void setPageVisited(String sRecordId){
        CC_Application__c objApp = [SELECT ID,Visited_Pages__c FROM CC_Application__c WHERe Id = :sRecordId];
        objApp.Visited_Pages__c = CC_Utility.setTabName(System.label.CC_Documents_Tab, objApp.Visited_Pages__c);
        System.debug('objApp: ' + objApp);
        update objApp;
    }
        
}