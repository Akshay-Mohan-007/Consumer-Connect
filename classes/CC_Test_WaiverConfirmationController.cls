/***************************************************************************************************************************************
 * NAME   : CC_Test_WaiverConfirmationController
 * DESCRIPTION  : Test Class for CC_WaiverConfirmationController
 *
 * @AUTHOR   : Nidhin V K
 * @DATE   : 11-30-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               11-30-2017          Initial version        
 *
 ****************************************************************************************************************************************/
@isTest
private class CC_Test_WaiverConfirmationController {
	
    @testSetup static void setupData() {
    	
        CC_Master_Settings__c objSettings = new CC_Master_Settings__c(
                                                        CC_Customer_Support_Phone_Number__c = '(999) 999-9999'
                                                                    );
        insert objSettings;
    	User pu = CC_TestDataFactory.getPortalUser(CC_TestDataFactory.PortalType.CspLitePortal, null, true);      
        
        System.RunAs(pu) {
			CC_Application__c objApp = new CC_Application__c(
                                        CC_Individual__c = pu.contactId,
                                        Selected_Program_Value__c = 'None',
                                        Is_Waiver_App_Complete__c = false,
                                        Waiver_Confirmation_Comments__c = 'comments'
                                                        );
        	insert objApp;
		} 
    }
    
    @isTest static void testMethods() {
    	CC_Application__c objApp = [SELECT 
										Id, CC_Case__c, CC_Individual__c,
										Selected_Program_Value__c, Is_Waiver_App_Complete__c,
										Waiver_Confirmation_Comments__c
									FROM 
										CC_Application__c 
									LIMIT 1];
        Test.startTest();
        
        String sResult = CC_WaiverConfirmationController.loadData(objApp.Id);
        System.debug('sResult|TaskListString>>' + sResult);
        System.assert(sResult.contains('CC_NONE'));
        
        CC_WaiverConfirmationController.ComponentWrapper wrapper = new CC_WaiverConfirmationController.ComponentWrapper();
    	wrapper.sAppId = objApp.Id;
		wrapper.sComments = objApp.Waiver_Confirmation_Comments__c;
		wrapper.sSuggestedProgramId = objApp.Selected_Program_Value__c;
		wrapper.bIsComplete = true;
		wrapper.sSuggestedProgramId = 'None';
		String sJSON = JSON.serialize(wrapper);
        sResult = CC_WaiverConfirmationController.saveData(sJSON);
        System.assert(sResult.contains('true'));
        
        sResult = CC_WaiverConfirmationController.submitData(sJSON);
        System.assert(sResult.contains('true')); 
        
		wrapper.sSuggestedProgramId = '';
		sJSON = JSON.serialize(wrapper);
        sResult = CC_WaiverConfirmationController.submitData(sJSON);
        
		wrapper.bIsComplete = false;
		sJSON = JSON.serialize(wrapper);
        sResult = CC_WaiverConfirmationController.submitData(sJSON);
        
        Test.stopTest();
    }
}