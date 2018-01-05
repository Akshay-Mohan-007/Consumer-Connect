@isTest
public class CC_Test_Manage_Allotment {
    
    public static String sAppId;

    @testSetup
    public static void setUpData() {
        
        
        sAppId = CC_TestDataFactory.createNewIndividualApp('Test Guy','Male','123456789',Date.newInstance(1999, 10 , 21))[2];
        System.debug('sAppId: ' + sAppId);

        CC_TestDataFactory.createUser(System.label.CC_Capacity_Reviewer_Profile);
    }
    
    static testmethod void testManageAllotmentData(){
        List<CC_Application__c> lstApp = [SELECT ID FROM CC_Application__c];
        System.debug('lstApp: ' + lstApp);
        sAppId = lstApp[0].Id;
        
        CC_Program_Service__c masterPrg= new CC_Program_Service__c();
        masterPrg.recordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_Program);
        masterPrg.Name = 'Comprehensive Adult Supports';
        masterPrg.Active__c = true;
        insert masterPrg;
        
        CC_Program_Service__c prgDetail= new CC_Program_Service__c();
        prgDetail.Name='Urgent';
        prgDetail.RecordTypeId=CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_ProgramDetail);
        prgDetail.Active__c=true;
        prgDetail.Capacity__c=20;
        prgDetail.Master_Program__c=masterPrg.Id;
        insert prgDetail;
        
        CC_Application_Detail__c objAppDetail = new CC_Application_Detail__c();
        objAppDetail.Related_Application__c = sAppId;
        objAppDetail.Waiting_List_Program__c = masterPrg.Id;
        objAppDetail.Individual_Meet_Waiver_Criteria__c = false;
        objAppDetail.Meet_For_Another_Waiver_Program__c = false;
        objAppDetail.Program_Detail__c=prgDetail.Id;
        //objAppDetail.Status__c = System.label.CC_Status_Targeting_Criteria_Not_Met;
        objAppDetail.Capacity_Review_Action__c=System.Label.CC_LABEL_RESERVED_CAPACITY;
        objAppDetail.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, System.label.CC_RT_Waiver_AppDetail);
        insert objAppDetail;
        
        DT_Task__c objTask=new DT_Task__c();
        objTask.Name='Capacity Review';
        objTask.DT_Status__c='New';
        objTask.Application_Detail__c=objAppDetail.Id;
        insert objTask;
        
        Test.startTest();
        String sPageData = '';
        String sReturnValue = '';
        User capacityUser = [SELECT Id 
    							FROM User 
    						WHERE Profile.Name =: System.label.CC_Capacity_Reviewer_Profile LIMIT 1];
        
        System.runAs(capacityUser){
           // String sPageData = '';
            //String sReturnValue = '';
            //CC_ManageAllotmentController.WrapperGridValues objWrapGridValues;
            
            sPageData = CC_ManageAllotmentController.loadData(objAppDetail.Id);
            String sAppDetObj1=JSON.serialize(objAppDetail);
            sReturnValue=CC_ManageAllotmentController.doSave(sAppDetObj1,true,objTask.Id,masterPrg.Id);
            
            CC_Application_Detail__c objAppDetail2 = new CC_Application_Detail__c();
	        //objAppDetail2.Individual_Meet_Waiver_Criteria__c = false;
	        objAppDetail2.Meet_For_Another_Waiver_Program__c = false;
            objAppDetail2.Capacity_Review_Action__c=System.Label.CC_LABEL_ADD_TO_WAITLIST;
            objAppDetail2.Id = objAppDetail.Id;
	        update objAppDetail2;
            
            String sAppDetObj2=JSON.serialize(objAppDetail2);
            sReturnValue=CC_ManageAllotmentController.doSave(sAppDetObj2,true,objTask.Id,'');
            
             CC_Application_Detail__c objAppDetail3 = new CC_Application_Detail__c();
	        //objAppDetail2.Individual_Meet_Waiver_Criteria__c = false;
	        objAppDetail3.Meet_For_Another_Waiver_Program__c = true;
            objAppDetail3.Capacity_Review_Action__c=System.Label.CC_LABEL_ADD_TO_WAITLIST;
            objAppDetail3.Id = objAppDetail.Id;
	        update objAppDetail3;
            
            String sAppDetObj3=JSON.serialize(objAppDetail3);
            sReturnValue=CC_ManageAllotmentController.doSave(sAppDetObj3,true,objTask.Id,masterPrg.Id);
            
            
    }
        Test.stopTest();
        CC_ResponseWrapper objResponseWrap = (CC_ResponseWrapper) JSON.deserialize(sPageData, CC_ResponseWrapper.class);
        System.assertEquals(true,objResponseWrap.success);  
}
}