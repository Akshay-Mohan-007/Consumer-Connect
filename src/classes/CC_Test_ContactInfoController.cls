/***************************************************************************************************************************************
 * NAME   : CC_TestContactInfoController
 * DESCRIPTION  : for CC_ContactInfoCOntroller 
 *    
 * @AUTHOR   : Sourav Ghosh
 * @DATE   : 11-05-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Sourav Ghosh				  11-05-2017			Initial version        
 *
 ****************************************************************************************************************************************/
@isTest
private class CC_Test_ContactInfoController{

	@testSetup 
	private static void setUpData() {
		CC_TestDataFactory.setUpDataBasicInfo();
		CC_TestDataFactory.createTestUsers();
	}

	static testMethod void testContactInfoMethods() {

		List<Contact> conObj = new List<Contact>([Select id from Contact LIMIT 1]);
        
		
		User userServiceIntake = fetchUser(System.label.CC_Self_Service_Intake_Profile,true);
    
        User userAppintake = fetchUser(System.label.CC_App_Intake_Profile,true);

        User userCaseManager = fetchUser(System.label.CC_Case_Manager_Profile,true);
        
		System.assertEquals(conObj.size(),1);
         
        CC_Application__c objApp = new CC_Application__c();
        objApp.CC_Individual__c = conObj[0].Id;
        objApp.CC_App_Status__c = System.label.CC_AppStatus_InProgress;
        objApp.CC_How_soon_services_needed__c = 'More than a year';
        objApp.CC_On_Any_Waiver_Waiting_List__c = false;
        insert objApp;
        
		conObj[0].CC_Physical_Address_State__c = 'Kentucky';
		conObj[0].CC_Mailing_Address_State__c = 'Kentucky';
		conObj[0].Phone = '1234465';

		update conObj[0];
        
       /* TestWrapper objWrapper = new TestWrapper();
        objWrapper.objContact = conObj[0];
        objWrapper.sAppId = objApp.Id;*/

		String strContact = JSON.serialize(conObj[0]);

	 	Test.startTest();
	 	
	 	System.runAs(userServiceIntake){

	 	map<String,String> mapLabels = CC_ContactInfoController.loadLabels();
	 	String sPageData1 = CC_ContactInfoController.loadContactData(conObj[0].id); 
	 	String sPageData2 = CC_ContactInfoController.loadContactData('');	
	 	CC_ContactInfoController.doSave(strContact,objApp.Id);

		}

	 	System.runAs(userAppintake){

	 	map<String,String> mapLabels = CC_ContactInfoController.loadLabels();
	 	String sPageData1 = CC_ContactInfoController.loadContactData(conObj[0].id); 
	 	String sPageData2 = CC_ContactInfoController.loadContactData('');	
	 	CC_ContactInfoController.doSave(strContact,objApp.Id);
	 }

	 	System.runAs(userCaseManager){
        /*Contact objContact = new Contact();
            objContact.Birthdate =  Date.newInstance(1999, 10 , 21);
            objContact.FirstName = 'TestFirstName1'.toUpperCase();
            objContact.LastName = 'TestLastName1'.toUpperCase();
         
            insert objContact;
            
        CC_Application__c objApp1 = new CC_Application__c();
        objApp1.CC_Individual__c =objContact.Id;
        objApp1.CC_App_Status__c = System.label.CC_AppStatus_InProgress;
        objApp1.CC_How_soon_services_needed__c = 'More than a year';
        objApp1.CC_On_Any_Waiver_Waiting_List__c = false;
        insert objApp1;
            
        TestWrapper objWrapper1 = new TestWrapper();
        objWrapper1.objContact = objContact;
        objWrapper1.sAppId = objApp.Id;

		String strWrapper1 = JSON.serialize(objWrapper1);*/
            

	 	map<String,String> mapLabels = CC_ContactInfoController.loadLabels();
	 	String sPageData1 = CC_ContactInfoController.loadContactData(conObj[0].id); 
	 	String sPageData2 = CC_ContactInfoController.loadContactData('');	
	 	CC_ContactInfoController.doSave(strContact,objApp.Id);

	 }

	 	Test.stopTest();
    }

    private static User fetchUser(String sProfileName, Boolean bIsActive){

        User userObj = [SELECT Id FROM User where Profile.Name =: sProfileName AND IsActive =: bIsActive LIMIT 1];
        return userObj;
    }  
     public class TestWrapper{
        Contact objContact;
        String sAppId;
    }
}