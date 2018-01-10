/***************************************************************************************************************************************
 * NAME   : CC_Test_WaitlistedApplicationListCtrlr
 * DESCRIPTION  : Test Class for CC_WaitlistedApplicationListController
 * @AUTHOR   : Nidhin
 * @DATE   : 15-Dec-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin               15-Dec-2017          Initial version        
 *
 ****************************************************************************************************************************************/
@isTest
public class CC_Test_WaitlistedApplicationListCtrlr {
    
    @testSetup static void setupData() {
        List<Contact> lstContact = new List<Contact>();
        Integer iRecordSize = 50;
        for(Integer i = 0; i < iRecordSize; i++){
        	Contact objContact = new Contact(LastName = 'Contact' + i);
        	lstContact.add(objContact);
        }
        insert lstContact;
       
        List<CC_Application__c> lstApp = new List<CC_Application__c>();
        for(Integer i = 0; i < iRecordSize; i++){
                CC_Application__c objApp = new CC_Application__c(
                    							CC_App_Status__c = System.Label.CC_AppStatus_InProgress,
                                                CC_Individual__c = lstContact[i].Id
                                                            );
                lstApp.add(objApp);
        }
        insert lstApp;
        List<CC_Application_Detail__c> lstAppDetail = new List<CC_Application_Detail__c>();
        String sRecordTypeId =CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, CC_Constants.CC_RECORD_TYPE_WAIVER_PROGRAMS);
        for(Integer i = 0; i < iRecordSize; i++){
                CC_Application_Detail__c objAppDetail = new CC_Application_Detail__c(
                    							Status__c = System.Label.CC_PGM_STATUS_WAITLISTED,
                                                Related_Application__c = lstApp[i].Id,
                                                RecordTypeId = sRecordTypeId
                                                            );
                lstAppDetail.add(objAppDetail);
        }
        insert lstAppDetail;
        CC_Master_Settings__c objSettings = new CC_Master_Settings__c(
        												WL_App_List_Page_Size__c = 3,
        												WL_App_List_Pages_Per_Screen__c = 3
        															);
        insert objSettings;
    }
    
    @isTest static void testMethods() {
    	Test.startTest();
    	String sResult = CC_WaitlistedApplicationListController.loadData( 'CreatedDate', 'DESC');
    	System.debug('sResult|loadData>>' + sResult);
    	System.assert(sResult.contains('CC_NO_APPLICATION'));
    	sResult = CC_WaitlistedApplicationListController.getMyAppListAsString( 2, 'CreatedDate', 'DESC', '1', TRUE);
    	System.debug('sResult|TaskListString>>' + sResult);
    	System.assert(sResult.contains('Contact1'));
        Test.stopTest();
    }

}