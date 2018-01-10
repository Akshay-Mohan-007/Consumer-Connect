/***************************************************************************************************************************************
* NAME   : CC_Test_TargetingCriteriaController
* DESCRIPTION  :   
*    
* @AUTHOR   : Debalina
* @DATE   : 12-12-2017
*
* MODIFICATION LOG:  
* --------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                DATE                DESCRIPTION 
* --------------------------------------------------------------------------------------------------------------------------------------
* Debalina               12-12-2017            Initial version  
****************************************************************************************************************************************/
@isTest
public without sharing class CC_Test_TargetingCriteriaController {

	public static String sAppId;

    @testSetup
    public static void setUpData() {
        sAppId = CC_TestDataFactory.createNewIndividualApp('Test Guy','Male','123456789',Date.newInstance(1999, 10 , 21))[2];
        System.debug('sAppId: ' + sAppId);

        CC_TestDataFactory.createUser(System.label.CC_Capacity_Reviewer_Profile);
    }

    static testmethod void testTargetingData(){
    	List<CC_Application__c> lstApp = [SELECT ID FROM CC_Application__c];
        System.debug('lstApp: ' + lstApp);
        sAppId = lstApp[0].Id;

        CC_Program_Service__c objProg = new CC_Program_Service__c();
		objProg.recordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_Program);
		objProg.Name = 'Intensive Supports';
		objProg.Active__c = true;
		insert objProg;

        CC_Application_Detail__c objAppDetail = new CC_Application_Detail__c();
        objAppDetail.Related_Application__c = sAppId;
        objAppDetail.Waiting_List_Program__c = objProg.Id;
        objAppDetail.Individual_Meet_Waiver_Criteria__c = false;
        objAppDetail.Meet_For_Another_Waiver_Program__c = true;
        objAppDetail.Status__c = System.label.CC_Status_Targeting_Criteria_Not_Met; 
        objAppDetail.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, System.label.CC_RT_Waiver_AppDetail);
        insert objAppDetail;


        CC_Program_Service__c objProg2 = new CC_Program_Service__c();
        objProg2.recordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_Program);
        objProg2.Name = 'Comprehensive Adult Supports';
        objProg2.Active__c = true;
        insert objProg2;

        CC_Application_Detail__c objAppDetailChild = new CC_Application_Detail__c();
        objAppDetailChild.Related_Application__c = sAppId;
        objAppDetailChild.Waiting_List_Program__c = objProg2.Id;
        objAppDetailChild.Original_Program_Suggestion__c = objAppDetail.Id;
        objAppDetailChild.Individual_Meet_Waiver_Criteria__c = false;
        objAppDetailChild.Meet_For_Another_Waiver_Program__c = false;
        objAppDetailChild.Status__c = CC_Constants.CC_APP_DTL_STATUS_PENDING; 
        objAppDetailChild.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, System.label.CC_RT_Waiver_AppDetail);
        insert objAppDetailChild;

    	Test.startTest();
        String sPageData = '';
        String sReturnValue = '';
    	User capacityUser = [SELECT Id 
    							FROM User 
    						WHERE Profile.Name =: System.label.CC_Capacity_Reviewer_Profile LIMIT 1];

    	CC_TargetingCriteriaController.ComponentWrapper objComponentWrapper;
    	System.runAs(capacityUser){
            CC_TargetingCriteriaController obj = new CC_TargetingCriteriaController();
            sPageData = CC_TargetingCriteriaController.loadApplicationDetailData(objAppDetail.Id);

            objComponentWrapper = new CC_TargetingCriteriaController.ComponentWrapper();
	        objComponentWrapper.bMeetCriteria = objAppDetail.Individual_Meet_Waiver_Criteria__c;
	        objComponentWrapper.bMeetAnotherCriteria = objAppDetail.Meet_For_Another_Waiver_Program__c;
	        objComponentWrapper.sAppDetailId = objAppDetail.Id;
	        objComponentWrapper.sAppId = sAppId;
	        objComponentWrapper.dtProcessDateTime = Datetime.newInstance(2017,12,15,10,30,0);
	        objComponentWrapper.sComments = 'TestComment';
            sReturnValue = CC_TargetingCriteriaController.doSave(JSON.serialize(objComponentWrapper),objProg.Id,true);
            
            CC_Application_Detail__c objAppDetail2 = new CC_Application_Detail__c();
	        objAppDetail2.Individual_Meet_Waiver_Criteria__c = false;
	        objAppDetail2.Meet_For_Another_Waiver_Program__c = false;
	        objAppDetail2.Id = objAppDetail.Id;
	        update objAppDetail2;

	        objComponentWrapper = new CC_TargetingCriteriaController.ComponentWrapper();
	        objComponentWrapper.bMeetCriteria = objAppDetail2.Individual_Meet_Waiver_Criteria__c;
	        objComponentWrapper.bMeetAnotherCriteria = objAppDetail2.Meet_For_Another_Waiver_Program__c;
	        objComponentWrapper.sAppDetailId = objAppDetail2.Id;
	        objComponentWrapper.sAppId = sAppId;
	        objComponentWrapper.dtProcessDateTime = Datetime.newInstance(2017,12,15,10,30,0);
	        objComponentWrapper.sComments = 'TestComment';
			sReturnValue = CC_TargetingCriteriaController.doSave(JSON.serialize(objComponentWrapper),objProg.Id,false);
		}					

    	Test.stopTest();
        CC_ResponseWrapper objResponseWrap = (CC_ResponseWrapper) JSON.deserialize(sReturnValue, CC_ResponseWrapper.class);
        System.assertEquals(true,objResponseWrap.success);   
    }
}