/***************************************************************************************************************************************
 * NAME   : CC_DocumentValidator_Interface
 * DESCRIPTION  : All Document Validation Utility Interface.
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

global interface CC_DocumentValidator_Interface {
	
	String checkRequiredDocs(String sRecordId,String sDocListJSON);
	String getDocUploadPicklistValues(String sModule);
	void setPageVisited(String sRecordId);
}