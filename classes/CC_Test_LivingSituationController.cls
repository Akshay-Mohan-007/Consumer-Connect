/***************************************************************************************************************************************
 * NAME         : CC_Test_LivingSituationController
 * DESCRIPTION  : for CC_LivingSituationController & component  
 *    
 * @AUTHOR   : Debalina
 * @DATE     : 11-15-2017    
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Debalina               11-15-2017         Initial version        
 *
 ****************************************************************************************************************************************/

@isTest
public class CC_Test_LivingSituationController {

	public static User userSelfServiceIntake,userAppintake,userCaseManager;
	

	public CC_Test_LivingSituationController() {}
	static {
		userSelfServiceIntake = [SELECT Id FROM User where Profile.Name =: 
								  System.label.CC_Self_Service_Intake_Profile AND IsActive = TRUE LIMIT 1];
		userAppintake = [SELECT Id FROM User where Profile.Name =: 
								System.label.CC_App_Intake_Profile AND IsActive = TRUE LIMIT 1];
		userCaseManager = [SELECT Id FROM User where Profile.Name =: 
								System.label.CC_Case_Manager_Profile AND IsActive = TRUE LIMIT 1];
	}

	static testmethod void testGetPageData(){
		Test.startTest();
            CC_Application__c objApplication;
            String sPageData = '';
            String sReturnValue = '';

        	//System.debug('objApplication:' +objApplication);
            System.runAs(userSelfServiceIntake){
                objApplication = CC_TestDataFactory.createApp();
	            sPageData = CC_LivingSituationController.getPageData(objApplication.Id);
				sReturnValue = CC_LivingSituationController.saveApplicationData(CC_TestDataFactory.getObjectJSON(objApplication));
			}
			
			System.runAs(userAppintake){
				//objApplication = CC_TestDataFactory.createApp();
				sPageData = CC_LivingSituationController.getPageData(objApplication.Id);
				sReturnValue = CC_LivingSituationController.saveApplicationData(CC_TestDataFactory.getObjectJSON(objApplication));
			}
        
        	/*objApplication = CC_TestDataFactory.createApp();	*/
			System.runAs(userCaseManager){
				sPageData = CC_LivingSituationController.getPageData(objApplication.Id);
				sReturnValue = CC_LivingSituationController.saveApplicationData(CC_TestDataFactory.getObjectJSON(objApplication));
			}

		Test.stopTest();	
        System.assertEquals('Success',sReturnValue);   


	}
}