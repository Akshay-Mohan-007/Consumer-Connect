/***************************************************************************************************************************************
 * NAME   : CC_Test_ApplicationsComponentController
 * DESCRIPTION  : 
 * @AUTHOR   : Pankaj
 * @DATE   : 20-Nov-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Pankaj               20-Nov-2017          Initial version        
 *
 ****************************************************************************************************************************************/


@isTest
public class CC_Test_ApplicationsComponentController {
    
    @testSetup static void setupData() {
        List<Contact> lstContact = new List<Contact>();
        Integer iRecordSize = 200;
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
        CC_Master_Settings__c objSettings = new CC_Master_Settings__c(
        												App_Dashboard_Page_Size__c = 10,
        												App_Dashboard_Pages_Per_Screen__c = 10,
            											Task_Dashboard_Page_Size__c = 10,
        												Task_Dashboard_Pages_Per_Screen__c = 10
        															);
        insert objSettings;
    }
    
    @isTest static void testMethods() {
    	Test.startTest();
    	String sResult = CC_ApplicationsComponentController.loadData( 'CreatedDate', 'DESC');
    	System.debug('sResult|loadData>>' + sResult);
    	System.assert(sResult.contains('CC_APP_NUMBER'));
    	sResult = CC_ApplicationsComponentController.getMyAppListAsString( 2, 'CreatedDate', 'DESC', '1', TRUE);
    	System.debug('sResult|TaskListString>>' + sResult);
    	System.assert(sResult.contains('Contact1'));
        Test.stopTest();
    }

}