/***************************************************************************************************************************************
 * NAME   : CC_AlternateProgramsController
 * DESCRIPTION  : for CC_UrgencyComponent 
 *    
 * @AUTHOR : Debalina
 * @DATE   : 12-14-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Debalina				  12-14-2017			Initial version        
 ****************************************************************************************************************************************/

public without sharing class CC_AlternateProgramsController {

    public class CompWrapper{
        public String sId;
        public String sProgramName;
        public String sUrgencyReason;
        public String sStatus;
        public String sCategory;
        public String sAppNumber;
    }
/*****************************************************************************************************************************************/
	/* getPageData 
    * @params : sAppDetailId - Id of CC_Application_Detail__c containing info about current waiver program
    * @return : JSON String with all data and static values relevant to the page
    *****************************************************************************************************************************************/
	@AuraEnabled
    public static String getPageData(String sAppDetailId){
        List<CompWrapper> lstAlternateProg = new List<CompWrapper>();
        Map<String,String> mapLabelAndError = loadLabelAndError();

    	try {
        String sWaiverProgramTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, System.label.CC_RT_Waiver_AppDetail);
        List<CC_Application_Detail__c> lstCurrentAppDetail = [SELECT Related_Application__r.CC_Case__r.Id
                                                             FROM CC_Application_Detail__c 
                                                             WHERE Id =: sAppDetailId];
        if(lstCurrentAppDetail.size() == 1){
            String sCaseId = lstCurrentAppDetail[0].Related_Application__r.CC_Case__r.Id;
            List<CC_Application_Detail__c> lstAppDetail = [ SELECT Id,
                                                               Status__c,
                                                               Reason__c,
                                                               Related_Application__r.Name,
                                                               Waiting_List_Program__r.Name,
                                                               Enrolled_Program__r.Program_Detail__r.Name
                                                        FROM CC_Application_Detail__c
                                                        WHERE Related_Application__r.CC_Case__r.Id =:sCaseId
                                                        AND RecordTypeId =: sWaiverProgramTypeId];
        
            for(CC_Application_Detail__c objAppDetail: lstAppDetail){
                if(objAppDetail.Id != sAppDetailId){
                    CompWrapper objWrap = new CompWrapper();
                    objWrap.sId = objAppDetail.Id;
                    objWrap.sAppNumber = objAppDetail.Related_Application__r.Name;
                    objWrap.sProgramName = objAppDetail.Waiting_List_Program__r.Name;
                    objWrap.sUrgencyReason = String.isNotBlank(objAppDetail.Reason__c)?
                                             objAppDetail.Reason__c : CC_Constants.CC_NO_DATA;
                    objWrap.sStatus = objAppDetail.Status__c;
                    objWrap.sCategory =  String.isNotBlank(objAppDetail.Enrolled_Program__r.Program_Detail__r.Name)?
                                         objAppDetail.Enrolled_Program__r.Program_Detail__r.Name : CC_Constants.CC_NO_DATA;
                    lstAlternateProg.add(objWrap);
                }
            }
        }
    	
        								    
        String sJSON = '{"lstAlternatePrograms":'+JSON.serialize(lstAlternateProg)
                        +',"MapLabelError":'+JSON.serialize(mapLabelAndError)
                        + '}';
        return JSON.serialize(new CC_ResponseWrapper(true, sJSON));
        
    	}catch(Exception ex){
            System.debug('Exception on Class : CC_AlternateProgramsController - getPageData, Error : ' +
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
        mapLabelAndError.put('CC_Urgency',System.label.CC_Urgency);
        mapLabelAndError.put('CC_Label_Program_Name',System.Label.CC_Label_Program_Name);
        mapLabelAndError.put('CC_LBL_Category',System.Label.CC_LBL_Category);
        mapLabelAndError.put('CC_LBL_Allocation_Status',System.Label.CC_LBL_Allocation_Status);
        mapLabelAndError.put('CC_LBL_NO_RECORD_EXIST',System.Label.CC_LBL_NO_RECORD_EXIST);
        mapLabelAndError.put('CC_LBL_Application',System.label.CC_LBL_Application);
        return mapLabelAndError;
    }	

}