/***************************************************************************************************************************************
 * NAME   : CC_Test_WaitlistPopoverController
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
@isTest
public class CC_Test_WaitlistPopoverController {
	@testSetup//set up contact and application
    public static void setUpData() {
        String sAppId = CC_TestDataFactory.createNewIndividualApp('Test Guy','Male','123456789',Date.newInstance(1999, 10 , 21))[2];
        System.debug('sAppId: ' + sAppId);
        
        List<String> lstProgDetail = new List<String>();
        lstProgDetail.add('Regular:50');
        lstProgDetail.add('Urgent:100');
        CC_Program_Service__c objProg = CC_TestDataFactory.createProgram('Intensive Supports',lstProgDetail);
        System.debug('objProg: ' + objProg);
        lstProgDetail = new List<String>();
        lstProgDetail.add('Emergency:60');
        lstProgDetail.add('Urgent:200');
        objProg = CC_TestDataFactory.createProgram('Comprehensive Supports',lstProgDetail);
		System.debug('objProg: ' + objProg);
        
        CC_Application_Detail__c objAppDetail = CC_TestDataFactory.createProgramSelection(sAppId,objProg.Id);
        System.debug('objAppDetail: ' + objAppDetail);
    }
    
    @isTest
    public static void loadWithProgram(){
        
        CC_Program_Service__c objProg = [SELECT ID,Name FROM CC_Program_Service__c WHERE Name='Comprehensive Supports'];
        System.debug('objProg: ' + objProg);
        
        Test.startTest();
        String sResult1 = CC_WaitlistPopoverController.loadData(objProg.Id,null);
        CC_Application_Detail__c objAppDetail = [SELECT ID,Status__c,Waiting_List_Program__c FROM CC_Application_Detail__c limit 1];
        objAppDetail.Status__c = System.Label.CC_PGM_STATUS_WAITLISTED;
        update objAppDetail;
        String sResult2 = CC_WaitlistPopoverController.refreshGrid(objProg.Id,null);
        Test.stopTest();
        
        String sJSONPrefix ='{"lstWaitList" : ',sJSONSuffix = '}';
        String sJSON = CC_TestDataFactory.getJSONToDesirialize(sResult1,sJSONPrefix,sJSONSuffix);
        System.debug('sJSON: ' + sJSON);
        List<CC_WaitlistPopoverController.WaitlistWrapper> lstWaitList = (List<CC_WaitlistPopoverController.WaitlistWrapper>)
            															JSON.deserialize(sJSON, List<CC_WaitlistPopoverController.WaitlistWrapper>.class);
        
        System.debug('lstWaitList: ' + lstWaitList);
        System.assertEquals(0, lstWaitList.size(),'Waitlist retrieved when no present');
        
        sJSON = CC_TestDataFactory.getJSONToDesirialize(sResult2,sJSONPrefix,sJSONSuffix);
        System.debug('sJSON: ' + sJSON);
        lstWaitList = (List<CC_WaitlistPopoverController.WaitlistWrapper>)
            			JSON.deserialize(sJSON, List<CC_WaitlistPopoverController.WaitlistWrapper>.class);
        
        System.debug('lstWaitList: ' + lstWaitList);
        System.assertEquals(1, lstWaitList.size(),'Waitlist not retrieved when present');
    }
    
    @isTest
    public static void loadWithProgramDetail(){
        
        CC_Program_Service__c objProgDetail = [SELECT ID,Name FROM CC_Program_Service__c 
                                         WHERE Master_Program__r.Name='Comprehensive Supports' limit 1];
        System.debug('objProgDetail: ' + objProgDetail);
        CC_Application_Detail__c objAppDetail = [SELECT ID,Status__c,Waiting_List_Program__c FROM CC_Application_Detail__c limit 1];
        objAppDetail.Status__c = System.Label.CC_PGM_STATUS_WAITLISTED;
        objAppDetail.Program_Detail__c = objProgDetail.Id;
        update objAppDetail;
        
        Test.startTest();
        String sResult = CC_WaitlistPopoverController.loadData(null,objProgDetail.Id);
        Test.stopTest();
        
        String sJSONPrefix ='{"lstWaitList" : ',sJSONSuffix = '}';
        String sJSON = CC_TestDataFactory.getJSONToDesirialize(sResult,sJSONPrefix,sJSONSuffix);
        System.debug('sJSON: ' + sJSON);
        List<CC_WaitlistPopoverController.WaitlistWrapper> lstWaitList = (List<CC_WaitlistPopoverController.WaitlistWrapper>)
            															JSON.deserialize(sJSON, List<CC_WaitlistPopoverController.WaitlistWrapper>.class);
        
        System.debug('lstWaitList: ' + lstWaitList);
        System.assertEquals(1, lstWaitList.size(),'Waitlist not retrieved when present');
        
       
    }

    @isTest
    public static void checkErrorLogging(){
        Test.startTest();
        String sResult = CC_WaitlistPopoverController.loadData(null,null);
        sResult = CC_WaitlistPopoverController.refreshGrid(null,null);
        Test.stopTest();
        System.debug('sResult: '+sResult);
        List<DT_Error_Log__c> lstErrors = [SELECT ID,DT_Class_Name__c,DT_Class_Method__c,DT_Error_Type__c 
                                            FROM DT_Error_Log__c WHERE DT_Class_Name__c<>null];
        System.assertEquals(2,lstErrors.size(),'Error not logged');
    }
}