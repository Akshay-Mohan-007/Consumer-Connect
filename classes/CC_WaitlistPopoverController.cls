/***************************************************************************************************************************************
 * NAME   : CC_WaitlistPopoverController
 * DESCRIPTION  : Waitlist popover grid  Controller
 *    
 * @AUTHOR   : Akshay Mohan
 * @DATE   : 18-Dec-2017
 * 
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Akshay Mohan				18-Dec-2017			Initial version   
 ****************************************************************************************************************************************/
public class CC_WaitlistPopoverController {
	private static String sClassName = 'CC_WaitlistPopoverController' ;
	
	public class WaitlistWrapper{
		public String sName, sUrgency;
		public WaitlistWrapper(CC_Application_Detail__c objProgram){
			sName = objProgram.Related_Application__r.CC_Individual__r.LastName;
			if(String.isNotBlank(objProgram.Related_Application__r.CC_Individual__r.FirstName))
				sName+=', '+objProgram.Related_Application__r.CC_Individual__r.FirstName;
			sUrgency = objProgram.Waiting_List_Program__r.Name;
		}
	}
	

	/* loadData 
    * Gets the data required to load the Component
    * @params : sProgramId, Record Id for Program 
    * @params : sProgramDetailID, Program Detail Id
    * 
    * @return : a JSON of the page data
    */
	@AuraEnabled
	public static String loadData(String sProgramId, String sProgramDetailID) {
		CC_ResponseWrapper wrapResponse = new CC_ResponseWrapper();
        String sMethodName = 'loadData';
		try{
			
	        System.debug('sProgramId: ' + sProgramId);
	        System.debug('sProgramDetailID: ' + sProgramDetailID);
			List<WaitlistWrapper> lstWaitList = loadWaitlist(sProgramId,sProgramDetailID);
			System.debug('lstWaitList: ' + lstWaitList);
			String sQuery = 'SELECT Id,Name FROM CC_Program_Service__c WHERE ';
			if(String.isNotBlank(sProgramId))
				sQuery+=' Master_Program__c= : sProgramId ';
			else
				sQuery+=' ID =: sProgramId ';
			System.debug('sQuery: ' + sQuery);
			
			List<CC_PickListValue_Wrapper> lstProgramDetails = new List<CC_PickListValue_Wrapper>();
			lstProgramDetails.add(new CC_PickListValue_Wrapper(null,System.Label.CC_Waitlisted_Popover_Select));
			for(CC_Program_Service__c objProgramDetail : Database.query(sQuery))
				lstProgramDetails.add(new CC_PickListValue_Wrapper(objProgramDetail.Id,objProgramDetail.Name));
			System.debug('lstProgramDetails: '+lstProgramDetails);
			
			Map<String,String> mapLabels = new Map<String,String>();
			mapLabels.put('CC_Waitlisted_Popover_Header',System.Label.CC_Waitlisted_Popover_Header);
			mapLabels.put('CC_Waitlisted_Popover_Filter_Section',System.Label.CC_Waitlisted_Popover_Filter_Section);
			mapLabels.put('CC_Waitlisted_Popover_Results_Section',System.Label.CC_Waitlisted_Popover_Results_Section);
			mapLabels.put('CC_LBL_Program_Name',System.Label.CC_LBL_Program_Name);
			mapLabels.put('CC_LBL_Category',System.Label.CC_LBL_Category);
			mapLabels.put('CC_INDIVIDUAL_NAME',System.Label.CC_INDIVIDUAL_NAME);
			mapLabels.put('CC_Waitlisted_Popover_No_Individuals',System.Label.CC_Waitlisted_Popover_No_Individuals);
			mapLabels.put('CC_SEARCH',System.Label.CC_SEARCH);

			wrapResponse.response= '{"lstWaitList" : '+JSON.serialize(lstWaitList)+
									', "lstProgramDetails" : '+JSON.serialize(lstProgramDetails)+
									+', "mapLabels": '+JSON.serialize(mapLabels)+'}';
			wrapResponse.success= true;
		}catch(Exception e){
			DT_Error_Log.BusinessException(
	                sClassName+': '+sMethodName+'('+sProgramId+','+sProgramDetailID+')',
	                System.Label.DT_ERROR_TYPE_VF_CONTROLLER,
	                e.getMessage(),
	                e.getStackTraceString(),
	                sClassName,
	                sMethodName,
	                DT_Constants.DT_EMPTY,
	                DT_Constants.DT_EMPTY);
	        wrapResponse.success= false;
	        wrapResponse.response = e.getMessage();
		}
		return JSON.serialize(wrapResponse);
	}
    
    /* refreshGrid 
    * Gets the data required to load the Component
    * @params : sProgramId, Record Id for Program 
    * @params : sProgramDetailID, Program Detail Id
    * 
    * @return : a JSON of the waitlist grid
    */
	@AuraEnabled
	public static String refreshGrid(String sProgramId, String sProgramDetailID) {
		CC_ResponseWrapper wrapResponse = new CC_ResponseWrapper();
        String sMethodName = 'refreshGrid';
		try{
			System.debug('sProgramId: ' + sProgramId);
	        System.debug('sProgramDetailID: ' + sProgramDetailID);
			List<WaitlistWrapper> lstWaitList = loadWaitlist(sProgramId,sProgramDetailID);
			System.debug('lstWaitList: ' + lstWaitList);
			wrapResponse.response='{"lstWaitList" : '+JSON.serialize(lstWaitList)+'}';
			wrapResponse.success= true;
		}catch(Exception e){
			DT_Error_Log.BusinessException(
	                sClassName+': '+sMethodName+'('+sProgramId+','+sProgramDetailID+')',
	                System.Label.DT_ERROR_TYPE_VF_CONTROLLER,
	                e.getMessage(),
	                e.getStackTraceString(),
	                sClassName,
	                sMethodName,
	                DT_Constants.DT_EMPTY,
	                DT_Constants.DT_EMPTY);
	        wrapResponse.success= false;
	        wrapResponse.response = e.getMessage();
		}
        
		
		return JSON.serialize(wrapResponse);
    }
    
    /* loadWaitlist 
    * Gets the data required to load the Component
    * @params : sProgramId, Record Id for Program 
    * @params : sProgramDetailID, Program Detail Id
    * 
    * @return : a List<WaitlistWrapper>
    */
	public static List<WaitlistWrapper> loadWaitlist(String sProgramId, String sProgramDetailID) {
        String sWaitlistedStatus = System.Label.CC_PGM_STATUS_WAITLISTED;
		String sQuery='SELECT Related_Application__r.CC_Individual__r.FirstName, Related_Application__r.CC_Individual__r.LastName'
							+', Waiting_List_Program__r.Name, Reason__c FROM CC_Application_Detail__c WHERE Status__c = :sWaitlistedStatus AND ';
		if(String.isNotBlank(sProgramDetailID)){
			sQuery+=' Program_Detail__c = :sProgramDetailID ';
		}else if(String.isNotBlank(sProgramId)){
			sQuery+=' Waiting_List_Program__c = :sProgramId ';
		}
		System.debug('sQuery: ' + sQuery);
		List<WaitlistWrapper> lstWaitList = new List<WaitlistWrapper>();
		for(CC_Application_Detail__c objProgram : Database.query(sQuery))
			lstWaitList.add(new WaitlistWrapper(objProgram));
        return lstWaitList;
    }
}