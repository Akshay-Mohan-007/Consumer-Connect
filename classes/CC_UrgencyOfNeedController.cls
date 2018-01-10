/***************************************************************************************************************************************
 * NAME   : CC_UrgencyOfNeedController
 * DESCRIPTION  : for CC_UrgencyComponent 
 *    
 * @AUTHOR : Debalina
 * @DATE   : 12-12-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Debalina				  12-12-2017			Initial version        
 ****************************************************************************************************************************************/

public without sharing class CC_UrgencyOfNeedController {

    public static String sProgramDetailTypeId;
    static{
        sProgramDetailTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_ProgramDetail);
    }
	/*****************************************************************************************************************************************/
	/* getPageData 
    * @params : sAppDetailId - Id of CC_Application_Detail__c containing info about current waiver program
    * @return : JSON String with all data and static values relevant to the page
    *****************************************************************************************************************************************/
	@AuraEnabled
    public static String getPageData(String sAppDetailId){
    	try {
    						    	
    	Map<String,String> mapLabelAndError = loadLabelAndError();

    	CC_Application_Detail__c objCurrentAppDetail;
    	List<CC_Application_Detail__c> lstAppDetail = [ SELECT Id,
    														   Status__c,
    														   Reason__c,
    														   Urgency_Comment__c,
                                                               Waiting_List_Program__c,
    														   Urgency_Request_Date__c
    												    FROM CC_Application_Detail__c
    												    WHERE Id =: sAppDetailId] ;
        
        List<CC_PickListValue_Wrapper> lstReason = new List<CC_PickListValue_Wrapper>(); 
    	if(lstAppDetail.size() == 1){
    		objCurrentAppDetail = lstAppDetail[0];
    		objCurrentAppDetail.Reason__c = String.isNotBlank(objCurrentAppDetail.Reason__c) ?
    										objCurrentAppDetail.Reason__c : '';
    		objCurrentAppDetail.Urgency_Comment__c = String.isNotBlank(objCurrentAppDetail.Urgency_Comment__c) ?
    												 objCurrentAppDetail.Urgency_Comment__c : '';

    		objCurrentAppDetail.Urgency_Request_Date__c = Date.valueOf(objCurrentAppDetail.Urgency_Request_Date__c);
    	
            List<CC_Program_Service__c> lstProgDetails = [SELECT Id, 
                                                                 Master_Program__c,
                                                                 Name 
                                                          FROM CC_Program_Service__c 
                                                          WHERE RecordTypeId =: sProgramDetailTypeId
                                                          AND Master_Program__c =: objCurrentAppDetail.Waiting_List_Program__c];

            lstReason.add(new CC_PickListValue_Wrapper(NULL,System.Label.CC_LBL_SELECT));                                              
            for(CC_Program_Service__c objPD: lstProgDetails){
                lstReason.add(new CC_PickListValue_Wrapper(objPD.Name));
            }                                              
        }											    

        String sJSON =  '{"lstReason":'+JSON.serialize(lstReason)
                		+',"AppDetail":'+JSON.serialize(objCurrentAppDetail)
                		+',"MapLabelError":'+JSON.serialize(mapLabelAndError)
                        + '}';
        return JSON.serialize(new CC_ResponseWrapper(true, sJSON));
    	}catch(Exception ex){
            System.debug('Exception on Class : CC_UrgencyOfNeedController - getPageData, Error : ' +
            ex.getMessage() +
            ' Line Number : ' +
            ex.getLineNumber() +
            ' Cause : ' +
            ex.getCause() +
            ' Type : ' +
            ex.getTypeName());
            return JSON.serialize(new CC_ResponseWrapper(false, NULL, new List<String>{System.Label.DT_LABEL_CONTACT_ADMIN}));
        } 
    }

    /******************************************************************************************************************************************/
	/* loadLabelAndError 
    * @params : N/A 
    * @return : Map of static values needed for the page
  	/*****************************************************************************************************************************************/
	@TestVisible
	private static Map<String,String> loadLabelAndError() {
		Map<String,String> mapLabelAndError = new Map<String, String>();
		String sComments = System.label.CC_Label_Comments;
		String sSubPart = sComments.substring(1);
		sComments = sComments.substring(0, 1) + sSubPart.toLowerCase();
		mapLabelAndError.put('CC_LBL_SELECT',System.label.CC_LBL_SELECT);
		mapLabelAndError.put('CC_LBL_UrgencyHeader',System.label.CC_LBL_UrgencyHeader);
		mapLabelAndError.put('CC_LBL_Reason',System.label.CC_LBL_Reason);
		mapLabelAndError.put('CC_LBL_UrgencyRequestDate',System.label.CC_LBL_UrgencyRequestDate);
		mapLabelAndError.put('CC_Label_Comments',sComments);
		mapLabelAndError.put('CC_MODULE',CC_Constants.CC_MODULE_MDT_CAPACITY_REVIEW);
        mapLabelAndError.put('CC_Err_Urgency_Date_Format',System.Label.CC_Err_Urgency_Date_Format);
        mapLabelAndError.put('CC_Err_Cannot_Be_Future',System.Label.CC_Err_Cannot_Be_Future);
        mapLabelAndError.put('CC_Err_Cannot_Be_Blank',System.Label.CC_Err_Cannot_Be_Blank);
        mapLabelAndError.put('CC_Document_Upload_Header',System.Label.CC_Document_Upload_Header);
		return mapLabelAndError;
	}
    	
    /******************************************************************************************************************************************/
	/* saveAppDetail 
	* @description : updates application detail record 
    * @params : sAppDetailId - Id of CC_Application_Detail__c containing info about current waiver program 
    * @return : Sucess or fail message of update
  	/*****************************************************************************************************************************************/
    @AuraEnabled
    public static String saveAppDetail(String sJSON){
    	try{
    		CC_Application_Detail__c objAppDetail = (CC_Application_Detail__c) JSON.deserialize(sJSON, CC_Application_Detail__c.class);
    		String sAppVisitedPages = [SELECT Id,Visited_Pages__c 
                                   FROM CC_Application_Detail__c WHERE Id =: objAppDetail.Id LIMIT 1].Visited_Pages__c;
    		System.debug('sAppVisitedPages-->'+sAppVisitedPages);
            objAppDetail.Visited_Pages__c = CC_Utility.setTabName(System.label.CC_Page_UrgencyNeed, sAppVisitedPages);
    		
    		System.debug('objAppDetail-->'+objAppDetail);
    		
    		
    		update objAppDetail;
    		return JSON.serialize(new CC_ResponseWrapper(true, NULL, new List<String>{System.Label.CC_MSG_APP_SAVED_SUCCESS}));
    	}catch(Exception ex){
            System.debug('Exception on Class : CC_UrgencyOfNeedController - saveAppDetail, Error : ' +
            ex.getMessage() +
            ' Line Number : ' +
            ex.getLineNumber() +
            ' Cause : ' +
            ex.getCause() +
            ' Type : ' +
            ex.getTypeName());
            return JSON.serialize(new CC_ResponseWrapper(false, NULL, new List<String>{System.Label.DT_LABEL_CONTACT_ADMIN}));
        }
    }

}