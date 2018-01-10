/***************************************************************************************************************************************
 * NAME   : CC_WaiverConfirmationController
 * DESCRIPTION  : Controller Class for CC_WaiverConfirmation Component
 *
 * @AUTHOR   : Nidhin V K
 * @DATE   : 11-23-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               11-23-2017          Initial version        
 *
 ****************************************************************************************************************************************/
public with sharing class CC_WaiverConfirmationController {
	public class ComponentWrapper {
		public String sAppId;
		public Boolean bIsComplete;
		public String sComments;
		public String sSuggestedProgramId;
		public Boolean bDisableYesRadio;
		public String sTaskToClose;
		public List<CC_PickListValue_Wrapper> lstPrograms;
		Map<String,String> mapLabels;
		public ComponentWrapper() {
			bDisableYesRadio = false;
			lstPrograms = new List<CC_PickListValue_Wrapper>();
			mapLabels = new Map<String,String>();
		}
	}
	
	/* METHOD NAME   : loadData
	 * DESCRIPTION  : load the records on page load
	 *
	 * RETURN TYPE   : list of items include labels, picklists
	 * PARAMETER   :         
	 */
	@AuraEnabled
	public static String loadData(String sAppId){
		try{
			ComponentWrapper wrapper = new ComponentWrapper();
			wrapper.mapLabels = loadLabelAndError();
			wrapper.sAppId = sAppId;
			wrapper.lstPrograms = getAllPrograms(sAppId);
			CC_Application__c objApp = [SELECT 
											Id, CC_Case__c, CC_Individual__c,
											Selected_Program_Value__c, Is_Waiver_App_Complete__c,
											Waiver_Confirmation_Comments__c
										FROM 
											CC_Application__c 
										WHERE 
											Id = :sAppId];
			wrapper.sComments = objApp.Waiver_Confirmation_Comments__c;
			wrapper.sSuggestedProgramId = objApp.Selected_Program_Value__c;
			wrapper.bIsComplete = objApp.Is_Waiver_App_Complete__c;
			for(CC_Document_Detail__c objDocDetail : [SELECT Id FROM CC_Document_Detail__c WHERE Status__c = :System.Label.CC_DOC_DETAIL_STATUS_INVALID AND Application__c = :sAppId]){
				wrapper.bIsComplete = false;
				wrapper.bDisableYesRadio = true;
				return JSON.serialize(new CC_ResponseWrapper(true, JSON.serialize(wrapper)));
			}
			return JSON.serialize(new CC_ResponseWrapper(true, JSON.serialize(wrapper)));
		}catch(Exception ex){
			//throw error no such field exists
			System.debug('Exception on Class : CC_TasksComponentController - loadData, Error : ' +
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
	
	/* METHOD NAME   : getAllPrograms
	 * DESCRIPTION  : return all the programs on page load
	 *
	 * RETURN TYPE   : program picklists
	 * PARAMETER   :         
	 */
	public static List<CC_PickListValue_Wrapper> getAllPrograms(String sAppId){
		List<CC_PickListValue_Wrapper> lstPrograms = new List<CC_PickListValue_Wrapper>();
		lstPrograms.add(new CC_PickListValue_Wrapper(CC_Constants.CC_EMPTY, CC_Constants.CC_EMPTY));
		for(CC_Program_Service__c objProgram : CC_TargetingCriteriaController.getAvailablePrograms(sAppId)){
			if(!objProgram.Name.equals('Other'))//temporary fix. Will remove once the services issues are resolved
				lstPrograms.add(new CC_PickListValue_Wrapper(objProgram.Id, objProgram.Name));
		}
		lstPrograms.add(new CC_PickListValue_Wrapper(CC_Constants.CC_NONE, System.Label.CC_NONE));
		lstPrograms.add(new CC_PickListValue_Wrapper(CC_Constants.CC_ALL_OPTIONS, System.Label.CC_IND_SEL_FOR_ALL_OPTNS));
		return lstPrograms;
	}
	
	/* METHOD NAME   : saveData
	 * DESCRIPTION  : save the records on save and exit
	 *
	 * RETURN TYPE   : 
	 * PARAMETER   :         
	 */
	@AuraEnabled
	public static String saveData(String sJSON){
		try{
			ComponentWrapper objWaiverInfo = (ComponentWrapper) JSON.deserialize(sJSON, ComponentWrapper.class);
			CC_Application__c objApp = new CC_Application__c();
			populateAppData(objWaiverInfo, objApp);
			update objApp;
			return JSON.serialize(new CC_ResponseWrapper(true, NULL, new List<String>{System.Label.CC_MSG_APP_SAVED_SUCCESS}));
		}catch(Exception ex){
			//throw error no such field exists
            System.debug('Exception on Class : CC_TasksComponentController - saveData, Error : ' +
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
	
	/* METHOD NAME   : submitData
	 * DESCRIPTION  : submit the records on submit
	 *
	 * RETURN TYPE   : 
	 * PARAMETER   :         
	 */
	@AuraEnabled
	public static String submitData(String sJSON){
		try{
			List<String> lstMessages = new List<String>();
			ComponentWrapper objWaiverInfo = (ComponentWrapper) JSON.deserialize(sJSON, ComponentWrapper.class);
			//checking the document uploaded is reviewed
			for(CC_Document_Detail__c objDocDetail : [SELECT Id FROM CC_Document_Detail__c WHERE Status__c = NULL AND Application__c = :objWaiverInfo.sAppId]){
				return JSON.serialize(new CC_ResponseWrapper(false, NULL, NULL));
			}	
			CC_Application__c objApp = [SELECT 
											Id, Name, CC_Case__c, CC_Individual__c,
											CC_Individual__r.AccountId, CC_Individual__r.Email, 
											CreatedById, CreatedBy.Profile.Name
										FROM 
											CC_Application__c 
										WHERE 
											Id = :objWaiverInfo.sAppId];
			populateAppData(objWaiverInfo, objApp);
			System.debug('populateAppData objApp>>' + objApp);
			Case objCase = new Case(Id = objApp.CC_Case__c);
			CC_Application_Detail__c objAppDetail;
			if(objWaiverInfo.bIsComplete){
				if(objWaiverInfo.sSuggestedProgramId.equals(CC_Constants.CC_NONE)
					|| objWaiverInfo.sSuggestedProgramId.equals(CC_Constants.CC_ALL_OPTIONS)){
					
					objApp.CC_App_Status__c = System.Label.CC_AppStatus_Terminated;
					String sNetworkId, sNetworkName;
					if(!objApp.CreatedBy.Profile.Name.equals(System.Label.CC_App_Intake_Profile)){
						NetworkMember objMember = [SELECT Id, NetworkId, Network.Name FROM NetworkMember WHERE MemberId = :objApp.CreatedById];
						sNetworkId = objMember.NetworkId;
						sNetworkName = objMember.Network.Name;
						System.debug('objMember>>' + objMember);
					}
					
					//Post Notification
					CC_Utility.postNotificationFeed(objApp.CreatedById, sNetworkId, System.Label.CC_LBL_APP_REJECTED + ' (' + objApp.Name + '): ' + objWaiverInfo.sComments);

					if(String.isNotBlank(sNetworkName) && sNetworkName.equals(System.Label.CC_NETWORK_NAME_SELF_SERVICE)){
						//send mail
						if(String.isNotBlank(objApp.CC_Individual__r.Email))
							sendEmail(objApp);
					}
					update objApp;
					if(String.isNotBlank(objCase.Id)){
						objCase.Status = System.Label.CC_Case_Status_Closed;
						update objCase;
					}
					//close the prev task
					DT_Util.closePreviousAndCreateNewTask(NULL, objWaiverInfo.sTaskToClose);
					lstMessages.add(System.Label.CC_MSG_APP_TERMINATION_SUCCESS);
	        		return JSON.serialize(new CC_ResponseWrapper(true, NULL, lstMessages));
				}
				objCase.ContactId = objApp.CC_Individual__c;
				objCase.AccountId = objApp.CC_Individual__r.AccountId;
				objCase.Status = System.label.CC_Case_Status_Active;
				objCase.OwnerId = System.label.CC_Portal_Master_ID;
				upsert objCase;
				
				objApp.CC_Case__c = objCase.Id;
				objApp.CC_App_Status__c = System.Label.CC_APP_STATUS_REVIEWED;
				
				//create app detail
				objAppDetail = new CC_Application_Detail__c();
				objAppDetail.Waiting_List_Program__c = objWaiverInfo.sSuggestedProgramId;
				objAppDetail.Related_Application__c = objWaiverInfo.sAppId;
				objAppDetail.Status__c = CC_Constants.CC_APP_DTL_STATUS_PENDING;
				objAppDetail.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, CC_Constants.CC_RECORD_TYPE_WAIVER_PROGRAMS);
				insert objAppDetail;
			} else{
				objApp.CC_App_Status__c = System.Label.CC_LBL_RevisionNeeded;
			}
			objApp.Waiver_Confirmation_Comments__c = '';
			update objApp;
			System.debug('Success objApp>>' + objApp);

			//call task f/w
			Map<String,String> mapTask = new Map<String,String>();
			mapTask.put('DT_Master_Record_Id__c', objApp.Id);
			mapTask.put('Application__c', objApp.Id);
			mapTask.put('Contact__c', objApp.CC_Individual__c);
			mapTask.put('DT_Comments__c', objWaiverInfo.sComments);

			DT_TaskResponseWrapper objResponse;
			if(objApp.CC_App_Status__c.equals(System.Label.CC_APP_STATUS_REVIEWED)){
				mapTask.put('Application_Detail__c', objAppDetail.Id);
				mapTask.put('Case__c', objApp.CC_Case__c);
				objResponse = DT_TaskAssignment.executeTaskRules(objAppDetail.Id, mapTask, objWaiverInfo.sTaskToClose);
				objCase = [SELECT CaseNumber FROM Case WHERE Id = :objCase.Id];
				lstMessages.add(System.Label.CC_MSG_APP_SUBMISSION_SUCCESS + ' ' + String.valueOf(objCase.CaseNumber));
			} else{
				objResponse = DT_TaskAssignment.executeTaskRules(objApp.Id, mapTask, objWaiverInfo.sTaskToClose);
				lstMessages.add(System.Label.CC_MSG_APP_REJECTED);
			}
			if(objResponse.success)
	        	return JSON.serialize(new CC_ResponseWrapper(true, NULL, lstMessages));
	        return JSON.serialize(new CC_ResponseWrapper(false, NULL, new List<String>{System.Label.DT_LABEL_CONTACT_ADMIN}));
		}catch(Exception ex){
			//throw error no such field exists
            System.debug('Exception on Class : CC_WaiverConfirmationController - saveData, Error : ' +
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
	
	/* METHOD NAME   : submitData
	 * DESCRIPTION  : submit the records on submit
	 *
	 * RETURN TYPE   : 
	 * PARAMETER   :         
	 */
	@AuraEnabled
	public static void populateAppData(ComponentWrapper objWaiverInfo, CC_Application__c objApp){
		objApp.Id = objWaiverInfo.sAppId;
		objApp.Waiver_Confirmation_Comments__c = objWaiverInfo.sComments;
		objApp.Selected_Program_Value__c = objWaiverInfo.sSuggestedProgramId;
		objApp.Is_Waiver_App_Complete__c = objWaiverInfo.bIsComplete;
	}
	
	/* METHOD NAME   : sendEmail
	 * DESCRIPTION  : send email
	 *
	 * RETURN TYPE   : 
	 * PARAMETER   :         
	 */
	public static void sendEmail(CC_Application__c objApp){
        EmailTemplate objTemplate = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'CC_App_Rejection_Email'];
	        
        String sBody = Messaging.renderStoredEmailTemplate(objTemplate.Id, objApp.CC_Individual__c, objApp.Id).getHtmlBody();
        System.debug('Initial body: ' +sBody);
        sBody = sBody.substringBetween('<DIV>', '</DIV>');
        System.debug('Final body: ' +sBody);
        sBody = sBody.replace('(XXX) XXX-XXXX', CC_Master_Settings__c.getInstance().CC_Customer_Support_Phone_Number__c);
        
		Messaging.SingleEmailMessage objEMail = new Messaging.SingleEmailMessage();
		objEMail.toAddresses = new List<String>{objApp.CC_Individual__r.Email};
		//objEMail.setTemplateId(objTemplate.Id); 
		objEMail.setHtmlBody(sBody); 
		objEMail.setTargetObjectId(objApp.CC_Individual__c);
		objEMail.setWhatId(objApp.Id);
		objEMail.setSaveAsActivity(false);
		objEMail.setTreatTargetObjectAsRecipient(false);
		Messaging.SingleEmailMessage[] lstMessages = new List<Messaging.SingleEmailMessage> {objEMail};
        Messaging.SendEmailResult[] lstResults = Messaging.sendEmail(lstMessages);
    }
    
	/* METHOD NAME   : loadLabelAndError
	 * DESCRIPTION  : load the labels and errors for the page
	 *
	 * RETURN TYPE   : list of items include tasks list, labels, 
	 * PARAMETER   : sOwner        
	 */
	@TestVisible
	private static Map<String, String> loadLabelAndError() {
		Map<String, String> mapLabels = new Map<String, String>();
        mapLabels.put('CC_Save_Exit',System.Label.CC_Save_Exit);
        mapLabels.put('CC_Contact_SubmitButton',System.Label.CC_Contact_SubmitButton);
        mapLabels.put('CC_Back_Button',System.Label.CC_Back_Button);
        mapLabels.put('CC_Next_Button',System.Label.CC_Next_Button);
        mapLabels.put('CC_Tab_Complete_Icon',System.Label.CC_Tab_Complete_Icon);
        mapLabels.put('CC_Tab_Incomplete_Icon',System.Label.CC_Tab_Incomplete_Icon);
        mapLabels.put('CC_Application_Intake_Page',System.Label.CC_Application_Intake_Page);
        mapLabels.put('CC_Is_This_Waiver_Application_Complete',System.Label.CC_Is_This_Waiver_Application_Complete);
        mapLabels.put('CC_Waiver_Prog_Referred_To_Indiviual',System.Label.CC_Waiver_Prog_Referred_To_Indiviual);
        mapLabels.put('CC_LBL_COMMENTS_TO_APP_INITIATOR',System.Label.CC_LBL_COMMENTS_TO_APP_INITIATOR);
        mapLabels.put('CC_LBL_COMMENTS_TO_CAP_REVIEWER',System.Label.CC_LBL_COMMENTS_TO_CAP_REVIEWER);
        mapLabels.put('CC_CRITERIA_NOT_MEETING_REASON',System.Label.CC_CRITERIA_NOT_MEETING_REASON);
        mapLabels.put('CC_ERR_SELECT_A_PROGRAM',System.Label.CC_ERR_SELECT_A_PROGRAM);
        mapLabels.put('CC_ERR_GIVE_COMMENTS',System.Label.CC_ERR_GIVE_COMMENTS);
        mapLabels.put('CC_LBL_WAIVER_CONFIRMATION',System.Label.CC_LBL_WAIVER_CONFIRMATION);
        mapLabels.put('CC_NONE',CC_Constants.CC_NONE);
        mapLabels.put('CC_ALL_OPTIONS',CC_Constants.CC_ALL_OPTIONS);

		return mapLabels;
	}
}