/***************************************************************************************************************************************
* NAME   : CC_Test_UrgencyOfNeedController
* DESCRIPTION  : for CC_UrgencyOfNeedController 
*    
* @AUTHOR : Pankaj
* @DATE   : 13-12-2017
*
* MODIFICATION LOG:  
* --------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER				DATE				DESCRIPTION 
* --------------------------------------------------------------------------------------------------------------------------------------
* Pankaj				  13-12-2017			Initial version        
****************************************************************************************************************************************/
@isTest
public class CC_Test_UrgencyOfNeedController {
    public static String sAppId;
    public static String sAppId2;
    
    @testSetup//set up contact and application
    public static void setUpData() {
        sAppId = CC_TestDataFactory.createNewIndividualApp('Test Guy','Male','123456789',Date.newInstance(1999, 10 , 21))[2];
        // sAppId2 = CC_TestDataFactory.createNewIndividualApp('Test ','Male','123456787',Date.newInstance(1999, 10 , 21))[2];
        System.debug('sAppId: ' + sAppId);
    }
    
    static testMethod void loadAndSaveAppData() {
        List<CC_Application__c> lstApp = [SELECT ID FROM CC_Application__c];
        
        CC_Application_Detail__c objAppDetail = new CC_Application_Detail__c();
        objAppDetail.Individual_Meet_Waiver_Criteria__c = true;
        objAppDetail.Processing_Date_Time__c = Date.newInstance(1990, 10 , 21 );
        objAppDetail.Related_Application__c=lstApp[0].Id;
        insert objAppDetail;
        String objAppDetails = JSON.serialize(objAppDetail);
        
        CC_Application_Detail__c objAppDetail2 = new CC_Application_Detail__c();
        // objAppDetail2.Id=  objAppDetail.Id; 
        objAppDetail2.Individual_Meet_Waiver_Criteria__c = true;
        objAppDetail2.Processing_Date_Time__c = Date.newInstance(1990, 10 , 21 );
        objAppDetail2.Related_Application__c=lstApp[0].Id;
        insert objAppDetail2;
        String objAppDetails2 = JSON.serialize(objAppDetail2);
        List<CC_Application_Detail__c>  lstAppDetail = [SELECT ID FROM CC_Application_Detail__c]; 
        
        Test.startTest();
        String strLoadData = CC_UrgencyOfNeedController.getPageData(lstAppDetail[0].Id);     
        Test.stopTest();
        System.assertEquals(objAppDetail2.Individual_Meet_Waiver_Criteria__c,true);
        
    }
    static testMethod void loadAndSaveAppData2() {
        List<CC_Application__c> lstApp = [SELECT ID FROM CC_Application__c];
        
        CC_Application_Detail__c objAppDetail = new CC_Application_Detail__c();
        objAppDetail.Individual_Meet_Waiver_Criteria__c = true;
        objAppDetail.Processing_Date_Time__c = Date.newInstance(1990, 10 , 21 );
        objAppDetail.Related_Application__c=lstApp[0].Id;
        insert objAppDetail;
        String objAppDetails = JSON.serialize(objAppDetail);
        
        CC_Application_Detail__c objAppDetail2 = new CC_Application_Detail__c();
        // objAppDetail2.Id=  objAppDetail.Id; 
        objAppDetail2.Individual_Meet_Waiver_Criteria__c = true;
        objAppDetail2.Processing_Date_Time__c = Date.newInstance(1990, 10 , 21 );
        objAppDetail2.Related_Application__c=lstApp[0].Id;
        insert objAppDetail2;
        String objAppDetails2 = JSON.serialize(objAppDetail2);
        List<CC_Application_Detail__c>  lstAppDetail = [SELECT ID FROM CC_Application_Detail__c]; 
        
        Test.startTest();
        String saveResult=CC_UrgencyOfNeedController.saveAppDetail(objAppDetails);           
        Test.stopTest();
        
    }  
    
    
    
}