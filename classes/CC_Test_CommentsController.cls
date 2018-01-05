/***************************************************************************************************************************************
 * NAME   : CC_Test_CommentsController
 * DESCRIPTION  : for CC_CommentsController 
 *    
 * @AUTHOR   : Debalina
 * @DATE   : 10-27-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Debalina				  10-27-2017			Initial version  
  ****************************************************************************************************************************************/ 
@isTest
public with sharing class CC_Test_CommentsController {
	public static User userSelfServiceIntake,userAppintake,userCaseManager;
	
	static {
		userSelfServiceIntake = [SELECT Id FROM User where Profile.Name =: 
								  System.label.CC_Self_Service_Intake_Profile AND IsActive = TRUE LIMIT 1];
		userAppintake = [SELECT Id FROM User where Profile.Name =: 
								System.label.CC_App_Intake_Profile AND IsActive = TRUE LIMIT 1];
		userCaseManager = [SELECT Id FROM User where Profile.Name =: 
								System.label.CC_Case_Manager_Profile AND IsActive = TRUE LIMIT 1];
	}
	public CC_Test_CommentsController() {}

	
	static testMethod void testComment(){
		Test.startTest();
            CC_Application__c objApplication;
            String sPageData = '';
            String sReturnValue = '';

        	//System.debug('objApplication:' +objApplication);
            System.runAs(userSelfServiceIntake){
                objApplication = CC_TestDataFactory.createApp();
                CC_TestDataFactory.createCustomSettingRecord();
				sReturnValue = CC_CommentsController.saveCommentsInfo(objApplication.Id,
																	 'CC_Services_Component',
																	 'Related_Application__c',
																	 'Test Comment 1',false);
				sReturnValue = CC_CommentsController.saveCommentsInfo(objApplication.Id,
																	 'CC_Services_Component',
																	 'Related_Application__c',
																	 'Test Comment 2',true);
	            sPageData = CC_CommentsController.loadCommentsInfo(objApplication.Id, 'CC_Services_Component','Related_Application__c',CC_Constants.CC_MODULE_MDT_APPLICATION);
	            sPageData = CC_CommentsController.getCommentAsString(objApplication.Id, 'CC_Services_Component','Related_Application__c', 0 , true);

			}
			
			System.runAs(userAppintake){
				CC_TestDataFactory.createCustomSettingRecord();
				sReturnValue = CC_CommentsController.saveCommentsInfo(objApplication.Id,
																	 'CC_Services_Component',
																	 'Related_Application__c',
																	 'Test Comment 1',false);
				sReturnValue = CC_CommentsController.saveCommentsInfo(objApplication.Id,
																	 'CC_Services_Component',
																	 'Related_Application__c',
																	 'Test Comment 2',true);
	            sPageData = CC_CommentsController.loadCommentsInfo(objApplication.Id, 'CC_Services_Component','Related_Application__c',CC_Constants.CC_MODULE_MDT_APPLICATION);
	            sPageData = CC_CommentsController.getCommentAsString(objApplication.Id, 'CC_Services_Component','Related_Application__c', 0 , true);
			}
        
			System.runAs(userCaseManager){
				CC_TestDataFactory.createCustomSettingRecord();
				sReturnValue = CC_CommentsController.saveCommentsInfo(objApplication.Id,
																	 'CC_Services_Component',
																	 'Related_Application__c',
																	 'Test Comment 1',false);
				sReturnValue = CC_CommentsController.saveCommentsInfo(objApplication.Id,
																	 'CC_Services_Component',
																	 'Related_Application__c',
																	 'Test Comment 2',true);
	            sPageData = CC_CommentsController.loadCommentsInfo(objApplication.Id, 'CC_Services_Component','Related_Application__c',CC_Constants.CC_MODULE_MDT_APPLICATION);
	            sPageData = CC_CommentsController.getCommentAsString(objApplication.Id, 'CC_Services_Component','Related_Application__c', 0 , true);
			}

		Test.stopTest();	
        System.assertEquals('Success',sReturnValue);   


	}
}