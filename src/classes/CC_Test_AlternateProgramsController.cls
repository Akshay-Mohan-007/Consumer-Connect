/***************************************************************************************************************************************
* NAME   : CC_Test_AlternateProgramsController
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
public without sharing class CC_Test_AlternateProgramsController {
    
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

        CC_Program_Service__c objProg2 = new CC_Program_Service__c();
        objProg2.recordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_Program);
        objProg2.Name = 'Comprehensive Adult Supports';
        objProg2.Active__c = true;
        insert objProg2;
        
        CC_Application_Detail__c objAppDetail = new CC_Application_Detail__c();
        objAppDetail.Related_Application__c = sAppId;
        objAppDetail.Waiting_List_Program__c = objProg.Id;
        objAppDetail.Individual_Meet_Waiver_Criteria__c = false;
        objAppDetail.Meet_For_Another_Waiver_Program__c = true;
        objAppDetail.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, System.label.CC_RT_Waiver_AppDetail);
        insert objAppDetail;
        
        CC_Application_Detail__c objAppDetail2 = new CC_Application_Detail__c();
        objAppDetail2.Related_Application__c = sAppId;
        objAppDetail2.Waiting_List_Program__c = objProg2.Id;
        objAppDetail2.Individual_Meet_Waiver_Criteria__c = false;
        objAppDetail2.Meet_For_Another_Waiver_Program__c = true;
        objAppDetail2.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, System.label.CC_RT_Waiver_AppDetail);
        insert objAppDetail2;
        
        Test.startTest();
        String sPageData = '';
        User capacityUser = [SELECT Id 
                             FROM User 
                             WHERE Profile.Name =: System.label.CC_Capacity_Reviewer_Profile LIMIT 1];
        System.runAs(capacityUser){
            sPageData = CC_AlternateProgramsController.getPageData(objAppDetail.Id);
            System.debug(sPageData);
        }
        
        Test.stopTest();
        System.assertEquals(sPageData!='',true);
        
    }
    
}