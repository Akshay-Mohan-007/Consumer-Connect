/***************************************************************************************************************************************
 * NAME   : CC_IndividualSummary_Controller
 * DESCRIPTION  : Individual Summary Controller
 *    
 * @AUTHOR   : Akshay Mohan
 * @DATE   : 23-Nov-2017
 * 
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Akshay Mohan				23-Nov-2017			Initial version   
 * Nidhin					12-Dec-2017			added a line of code to populate task open date   
 * Sourav   				19-Dec-2017			added a method to split phone no
 ****************************************************************************************************************************************/
public class CC_IndividualSummary_Controller {

	public class IndividualSummarryWrapper{
		public String sIndivName, sCaseActionDate, sSSN, sDOB, sAge, sGender, sRAddress, sMAddress, sPPhone, sSPhone, sEmail, 
						sLGName, sARName, sCaseManager, sCMA , sCaseSupervisor, sCase, sCaseStatus, sPExt, sSExt;
		public List<ProgramDetailWrapper> lstPrograms;
		
		public IndividualSummarryWrapper(Contact objContact,Case objCase){
			Time tTemp = Time.newInstance(0, 0, 0, 0);
			sIndivName = objContact.Name;
			sSSN = String.isNotBlank(objContact.CC_SSN__c)? objContact.CC_SSN__c : CC_Constants.CC_NO_DATA;
			sDOB = DateTime.newInstance(objContact.Birthdate, tTemp).format(CC_Constants.CC_OUTPUT_DATE_FORMAT);
			sAge = String.valueOf(objContact.Age__c);
			sGender = objContact.CC_Gender__c;
			sRAddress = objContact.Formatted_Physical_Address__c;
			sMAddress = objContact.Formatted_Mailing_Address__c;
			sPPhone = String.isNotBlank(objContact.Phone)?getPhnNo(objContact.Phone,false):CC_Constants.CC_NO_DATA;
			sSPhone = String.isNotBlank(objContact.OtherPhone)?getPhnNo(objContact.OtherPhone,false):CC_Constants.CC_NO_DATA;
			sPExt =  String.isNotBlank(objContact.Phone)?getPhnNo(objContact.Phone,true):CC_Constants.CC_NO_DATA;
			sSExt =	 String.isNotBlank(objContact.OtherPhone)?getPhnNo(objContact.OtherPhone,true):CC_Constants.CC_NO_DATA;
			sEmail = objContact.Email;

			if(objCase == null){
				sCaseActionDate = CC_Constants.CC_NO_DATA;
				sCMA = CC_Constants.CC_NO_DATA;
				sCaseManager = CC_Constants.CC_NO_DATA;
				sCaseSupervisor = CC_Constants.CC_NO_DATA;
				sCase = CC_Constants.CC_NO_DATA;
				sCaseStatus = CC_Constants.CC_NO_DATA;
			}else{
				if(objCase.Action_Date__c == null)
					sCaseActionDate = CC_Constants.CC_NO_DATA;
				else
					sCaseActionDate = objCase.Action_Date__c.format(CC_Constants.CC_OUTPUT_DATE_FORMAT);
				sCMA = CC_Constants.CC_NO_DATA;
				sCaseManager = CC_Constants.CC_NO_DATA;
				sCaseSupervisor = CC_Constants.CC_NO_DATA;
				sCase = objCase.CaseNumber;
				sCaseStatus = CC_Constants.CC_NO_DATA;
			}

			
		}
		public IndividualSummarryWrapper(Contact objContact, Case objCase,List<CC_Application__c> lstApps){
			this(objContact,objCase);
			lstPrograms = new List<ProgramDetailWrapper>();
			LatestWrapper wrapLG = new LatestWrapper(CC_Constants.CC_NO_DATA), wrapAR = new LatestWrapper(CC_Constants.CC_NO_DATA);
			for(CC_Application__c objApp : lstApps){
				System.debug('objApp: ' + objApp);
				if(objApp.Application_Details__R.isEmpty())
					lstPrograms.add(new ProgramDetailWrapper(objApp));
				else
					for(CC_Application_Detail__c objProgram : objApp.Application_Details__R)
						lstPrograms.add(new ProgramDetailWrapper(objApp,objProgram));

				parseRepsForLatest(objApp.Contacts__r,wrapLG,wrapAR);
				System.debug('wrapLG: ' + wrapLG);
				System.debug('wrapAR: ' + wrapAR);
			}
			sLGName = wrapLG.sName;
			sARName = wrapAR.sName;
		}
		public IndividualSummarryWrapper(Contact objContact, Case objCase,String sLGName, String sARName){
			this(objContact,objCase);
			this.sLGName = sLGName;
			this.sARName = sARName;
		}

	}

	public class ProgramDetailWrapper{
		public String sProgramName, sAppStatus, sLOCEndDate, sProgramStatus, sAppDate, sLastActionDate;
		public ProgramDetailWrapper(CC_Application__c objApp){
			sProgramName = CC_Constants.CC_NO_DATA;
			sAppStatus = objApp.CC_App_Status__c;
			sLOCEndDate = CC_Constants.CC_NO_DATA;
			sProgramStatus = CC_Constants.CC_NO_DATA;
			sAppDate = CC_Utility.formatDateTime(objApp.Submitted_Date__c);
			sLastActionDate = CC_Utility.formatDateTime(objApp.LastModifiedDate);
			
		}
		public ProgramDetailWrapper(CC_Application__c objApp,CC_Application_Detail__c objProgram){
			sProgramName = objProgram.Waiting_List_Program__r.Name;
			sAppStatus = objApp.CC_App_Status__c;
			sLOCEndDate = CC_Constants.CC_NO_DATA;
			sProgramStatus = CC_Constants.CC_NO_DATA;
			sAppDate = CC_Utility.formatDateTime(objApp.Submitted_Date__c);
			sLastActionDate = CC_Utility.formatDateTime(objApp.LastModifiedDate);
			
		}

	}

	/* loadData 
    * Gets the data required to load the Component
    * @params : sContactId, Record Id for Individual whose details are required 
    * @params : sTaskId, Task Id for which summary is being done
    * @params : bLoadPrograms, boolean flag to signal loading of programs 
    * 
    * @return : a JSON of the page data
    */
	@AuraEnabled
	public static String loadData(String sContactId, String sTaskId, Boolean bLoadPrograms) {
		System.debug('In loadData');
		System.debug('sContactId: ' + sContactId);
		System.debug('sTaskId: ' + sTaskId);
		System.debug('bLoadPrograms: ' + bLoadPrograms);

		String sSiteName = Site.getName(),sSiteURL,sComponentName;
		Boolean bStarted;
		System.debug('sSiteName: ' + sSiteName);
		
		DT_Task__c objTask;
		if(String.isBlank(sContactId)){
			objTask = [SELECT DT_Rule_Version__r.DT_Navigation__r.Case_Manager_URL__c, DT_Rule_Version__r.DT_Navigation__r.Component_Name__c,
								DT_Rule_Version__r.DT_Navigation__r.Self_Service_URL__c, DT_Rule_Version__r.DT_Navigation__r.DT_Parameters__c,
								Contact__c, Application__c, Case__c,DT_Status__c,Application_Detail__c
						FROM DT_Task__c WHERE ID = :sTaskId];
			System.debug('objTask: ' + objTask);
			bStarted = System.Label.DT_Task_Status_In_Progress == objTask.DT_Status__c;
			System.debug('bStarted: ' + bStarted);

			List<CC_PickListValue_Wrapper> lstParams = new List<CC_PickListValue_Wrapper>();
			for(String sParam : objTask.DT_Rule_Version__r.DT_Navigation__r.DT_Parameters__c.split(';')){
				System.debug('sParam: ' + sParam);
				List<String> lstParam = sParam.split(':');
				lstParams.add(new CC_PickListValue_Wrapper(lstParam[0],lstParam[1]));
			}
			System.debug('lstParams: ' + lstParams);

			sContactId = objTask.Contact__c;
			sObject objGeneric = objTask;
			if(String.isNotBlank(sSiteName)){
				sSiteURL ='/';
				if(sSiteName == System.Label.CC_SITE_NAME_SELF_SERVICE)
					sSiteURL += objTask.DT_Rule_Version__r.DT_Navigation__r.Self_Service_URL__c+'?';
				else if(sSiteName == System.Label.CC_SITE_NAME_SERVICE_PROVIDER)
					sSiteURL += objTask.DT_Rule_Version__r.DT_Navigation__r.Case_Manager_URL__c+'?';
				
				for(CC_PickListValue_Wrapper wrapURL : lstParams){
					try{
						sSiteURL += wrapURL.sKey+'='+objGeneric.get(wrapURL.sValue)+'&';
					}catch(SObjectException e){
						sSiteURL += wrapURL.sKey+'='+wrapURL.sValue+'&';
					}
				}
				sSiteURL=sSiteURL.removeEnd('&');
			}else{
				sComponentName = objTask.DT_Rule_Version__r.DT_Navigation__r.Component_Name__c;
				sSiteURL='{';
				for(CC_PickListValue_Wrapper wrapURL : lstParams){
						try{
							sSiteURL += '"'+wrapURL.sKey+'": "'+objGeneric.get(wrapURL.sValue)+'",';
						}catch(SObjectException e){
							sSiteURL += '"'+wrapURL.sKey+'": "'+wrapURL.sValue+'",';
						}
				}
				sSiteURL=sSiteURL.removeEnd(',')+'}';
			}
			System.debug('sSiteURL: ' + sSiteURL);
			System.debug('sComponentName: ' + sComponentName);
			
		} 
		
		List<CC_Application__c> lstApps = [SELECT CC_Individual__r.Name, CC_Individual__r.CC_SSN__c, CC_Individual__r.Birthdate, CC_Individual__r.Age__c, 
												CC_Individual__r.CC_Gender__c, CC_Individual__r.Formatted_Mailing_Address__c, CC_Individual__r.Formatted_Physical_Address__c, 
												CC_Individual__r.OtherPhone, CC_Individual__r.Phone, CC_Individual__r.Email, 
												CC_Case__r.Action_Date__c, CC_Case__r.CaseNumber,
												Name,CC_App_Status__c,Submitted_Date__c,LastModifiedDate,
												(SELECT Name,LastModifiedDate,CC_Contact_Type__c FROM Contacts__r),
												(SELECT Id,Waiting_List_Program__r.Name FROM Application_Details__R WHERE RecordType.Name= :CC_Constants.CC_RECORD_TYPE_WAIVER_PROGRAMS)
											FROM CC_Application__c
											WHERE CC_Individual__c=:sContactId];
		System.debug('lstApps: ' + lstApps);
		IndividualSummarryWrapper wrapIndivData;
		if(bLoadPrograms)
			wrapIndivData = new IndividualSummarryWrapper(lstApps[0].CC_Individual__r, lstApps[0].CC_Case__r, lstApps);
		else{
			String sLGName, sARName,sLGCombinedAr = getARLG(lstApps);
			System.debug('sLGCombinedAr: ' + sLGCombinedAr);
			sLGName = sLGCombinedAr.split(';;')[0];
			sARName = sLGCombinedAr.split(';;')[1];
			wrapIndivData = new IndividualSummarryWrapper(lstApps[0].CC_Individual__r, lstApps[0].CC_Case__r, sLGName,sARName);
		}
		
		return '{ "wrapIndivData" : '+JSON.serialize(wrapIndivData)+
				', "sSiteURL" : '+JSON.serialize(sSiteURL)+
				', "sComponentName" : '+JSON.serialize(sComponentName)+
				', "bStarted" : '+JSON.serialize(bStarted)+
				', "mapLabels" : '+JSON.serialize(loadLabels())+'}';
	}

	public class LatestWrapper{
		String sName;
		DateTime dtModified;
		public LatestWrapper(String sName){
			this.sName = sName;
		}
	}

	/* assignTaskToSelf 
    * Assigns task to logged in user
    * @params : sTaskId, Task Id which needs to be assigned
    * 
    * @return : N/A
    */
	@AuraEnabled
	public static String assignTaskToSelf(String sTaskId) {
		System.debug('In loadData');
		System.debug('sTaskId: ' + sTaskId);
		DT_Task__c objTask = [SELECT ID,DT_Status__c,Owner.Name FROM DT_Task__c WHERe ID = :sTaskId];//new DT_Task__c(Id = sTaskId, ,OwnerId = UserInfo.getUserId());
		System.debug('objTask: ' + objTask);
		if(objTask.DT_Status__c != DT_Constants.DT_TASK_STATUS_NEW)
			return System.Label.CC_Error_Task_Already_Assigned +' '+ objTask.Owner.Name;
		objTask.DT_Status__c = DT_Constants.DT_TASK_STATUS_IN_PROGRESS;
		objTask.DT_Open_Date__c = DateTime.now();//added by Nidhin
		objTask.OwnerId = UserInfo.getUserId();
		update objTask;
		return 'Success';
	}

	/* getARLG 
    * Gets the latest legal guardian and authorized representative from list of applications
    * @params : lstApps, List of applications
    * 
    * @return : a ';;'' separated string of Legal Guardian and Authorized Representative
    */
	private static String getARLG(List<CC_Application__c> lstApps) {
		
		LatestWrapper wrapLG = new LatestWrapper(CC_Constants.CC_NO_DATA), wrapAR = new LatestWrapper(CC_Constants.CC_NO_DATA);
		for(CC_Application__c objApp : lstApps){
			System.debug('objApp: ' + objApp);
			parseRepsForLatest(objApp.Contacts__r,wrapLG,wrapAR);
			System.debug('wrapLG: ' + wrapLG);
			System.debug('wrapAR: ' + wrapAR);
		}
		
		return wrapLG.sName+';;'+wrapAR.sName;
	}

	private static void parseRepsForLatest(List<Contact> lstContacts,LatestWrapper wrapLG, LatestWrapper wrapAR){
		for(Contact objContact : lstContacts){
				if(objContact.CC_Contact_Type__c.contains(System.Label.CC_Contact_Type_Representative) && 
						objContact.CC_Contact_Type__c.contains(System.Label.CC_Contact_Type_Legal_Guardian)){
					doLatestCheckChange(wrapLG,objContact.Name,objContact.LastModifiedDate);
					doLatestCheckChange(wrapAR,objContact.Name,objContact.LastModifiedDate);
				}else if(objContact.CC_Contact_Type__c.contains(System.Label.CC_Contact_Type_Representative))
					doLatestCheckChange(wrapAR,objContact.Name,objContact.LastModifiedDate);
				else if(objContact.CC_Contact_Type__c.contains(System.Label.CC_Contact_Type_Legal_Guardian))
					doLatestCheckChange(wrapLG,objContact.Name,objContact.LastModifiedDate);					
			}
	}

	private static void doLatestCheckChange(LatestWrapper wrapIndiv,String sName,DateTime dtModifiedDate){
		if(CC_Utility.isLatest(wrapIndiv.dtModified, dtModifiedDate)){
			wrapIndiv.dtModified = dtModifiedDate;
			wrapIndiv.sName = sName;
		}
	}

	private static String getPhnNo(String sPhnNo, Boolean isExtNeeded){
		String sReturnVal;
		System.debug('***sPhnNo'+sPhnNo);
		List<String> lstPhnParts = sPhnNo.split('\\+');
		System.debug('***List'+lstPhnParts);

		if(!lstPhnParts.isEmpty()){
			if(!isExtNeeded)	
				sReturnVal = lstPhnParts[0];
			else if(lstPhnParts.size() == 1)
				sReturnVal = CC_Constants.CC_NO_DATA;
			else if(lstPhnParts.size() > 1)
				sReturnVal = lstPhnParts[1];
			else
				sReturnVal= null;
		}
		else{
			sReturnVal = CC_Constants.CC_NO_DATA;
		}
		return sReturnVal;
	}
    
    
    @TestVisible
    private static Map<String,String> loadLabels() {
        Map<String,String> mapLabels = new Map<String,String>();
        mapLabels.put('CC_Individual_Summary',System.Label.CC_Individual_Summary);
        mapLabels.put('CC_IndividualInformation',System.Label.CC_IndividualInformation);
        mapLabels.put('CC_IndividualName',System.Label.CC_IndividualName);
        mapLabels.put('CC_Last_Case_Action_Date',System.Label.CC_Last_Case_Action_Date);
        mapLabels.put('CC_LBL_SSN',System.Label.CC_LBL_SSN);
        mapLabels.put('CC_LBL_DOB',System.Label.CC_LBL_DOB);
        mapLabels.put('CC_Age',System.Label.CC_Age);
        mapLabels.put('CC_LBL_Gender',System.Label.CC_LBL_Gender);
        mapLabels.put('CC_Residence_Address',System.Label.CC_Residence_Address);
        mapLabels.put('CC_Mailing_Address',System.Label.CC_Mailing_Address);
        mapLabels.put('CC_Primary_Phone',System.Label.CC_Primary_Phone);
        mapLabels.put('CC_Secoandry_Phone',System.Label.CC_Secoandry_Phone);
        mapLabels.put('CC_Email',System.Label.CC_Email);
        mapLabels.put('CC_Contact_Type_Legal_Guardian',System.Label.CC_Contact_Type_Legal_Guardian);
        mapLabels.put('CC_Label_Authorized_Rep',System.Label.CC_Label_Authorized_Rep);
        mapLabels.put('CC_Label_CaseManagementAgency',System.Label.CC_Label_CaseManagementAgency);
        mapLabels.put('CC_Label_CaseManager',System.Label.CC_Label_CaseManager);
        mapLabels.put('CC_Label_CaseSupervisor',System.Label.CC_Label_CaseSupervisor);
        mapLabels.put('CC_Case_Number',System.Label.CC_Case_Number);
        mapLabels.put('CC_Case_Status',System.Label.CC_Case_Status);
        mapLabels.put('CC_Waiver_Prog_Information',System.Label.CC_Waiver_Prog_Information);
        mapLabels.put('CC_LBL_WAIVER_PROGRAM',System.Label.CC_LBL_WAIVER_PROGRAM);
        mapLabels.put('CC_Application_Status',System.Label.CC_Application_Status);
        mapLabels.put('CC_Label_LocEndDate',System.Label.CC_Label_LocEndDate);
        mapLabels.put('CC_Program_Status',System.Label.CC_Program_Status);
        mapLabels.put('CC_Application_Date',System.Label.CC_Application_Date);
        mapLabels.put('CC_Last_Action_Date',System.Label.CC_Last_Action_Date);
        mapLabels.put('CC_LBL_NO_RECORD_EXIST',System.Label.CC_LBL_NO_RECORD_EXIST);
        mapLabels.put('CC_START', System.Label.CC_START);
		mapLabels.put('CC_CONTINUE', System.Label.CC_CONTINUE);
		mapLabels.put('CC_Primary_Phone_Ext',System.Label.CC_Primary_Phone_Ext);
        mapLabels.put('CC_Secondary_Phone_Ext',System.Label.CC_Secondary_Phone_Ext);
		
		
        
        
         return mapLabels;
    }
}