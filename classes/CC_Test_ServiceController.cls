@isTest
public class CC_Test_ServiceController {

@testSetup
public static void setUpData() {
		//CC_TestDataFactory.setUpServiceData();
	}
	static testMethod void loadAndSaveServiceData() {

		User userServiceIntake = [SELECT Id FROM User where Profile.Name =: 
								  System.label.CC_Self_Service_Intake_Profile AND IsActive = TRUE LIMIT 1];
		User userAppintake = [SELECT Id FROM User where Profile.Name =: 
								System.label.CC_App_Intake_Profile AND IsActive = TRUE LIMIT 1];
		User userCaseManager = [SELECT Id FROM User where Profile.Name =: 
								System.label.CC_Case_Manager_Profile AND IsActive = TRUE LIMIT 1];

			List<String> lstProgram = new List<String>{'Acquired Brain Injury Supports',
    													'Comprehensive Adult Supports',
    													'Intensive Supports',
    													'Other',
    													'Residential Supports'};
    		List<CC_Program_Service__c> lstProgtoInsert = new List<CC_Program_Service__c>();

    		for(String str : lstProgram){
    			CC_Program_Service__c objProg = new CC_Program_Service__c();
    			objProg.recordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_Program);
    			objProg.Name = str;
    			objProg.Active__c = true;
    			//objProg.Agency__c = acc.id;

    			lstProgtoInsert.add(objProg);
    		}
    		insert lstProgtoInsert;

    		CC_Program_Service__c objService = new CC_Program_Service__c();
    		objService.recordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_Service);
    		objService.Program__c = lstProgtoInsert[0].id;
    		objService.Active__c = true;
    		insert objService;

			Contact objContact = new Contact();
			objContact.Birthdate =  Date.newInstance(1999, 10 , 21);
			objContact.FirstName = 'TestFirstName1'.toUpperCase();
			objContact.LastName = 'TestLastName1'.toUpperCase();
			objContact.CC_Gender__c = 'Male';
			objContact.CC_Suffix__c = 'II';
			objContact.CC_SSN__c = '888888888';
			objContact.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Individual);
			objContact.CC_Physical_Address_State__c = 'Other';
			objContact.CC_Mailing_Address_State__c = 'Other';
			objContact.CC_Contact_County__c = 'Other';
			objContact.CC_Mailing_Address_County__c = 'Other';
			insert objContact;

			CC_Application__c objApp = new CC_Application__c();
			objApp.CC_Individual__c = objContact.Id;
			objApp.CC_App_Status__c = System.label.CC_AppStatus_InProgress;
			objApp.CC_How_soon_services_needed__c = 'More than a year';
			objApp.CC_On_Any_Waiver_Waiting_List__c = false;
			insert objApp;

			List<CC_Application_Detail__c> appDetToInsert = new List<CC_Application_Detail__c>();

			CC_Application_Detail__c objAppDetP1 = new CC_Application_Detail__c();
			objAppDetP1.Related_Application__c = objApp.Id;
			objAppDetP1.Service__c = objService.id;
			objAppDetP1.recordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ,System.label.CC_RT_Service_Type);

			CC_Application_Detail__c objAppDetP2 = new CC_Application_Detail__c();
			objAppDetP2.Related_Application__c = objApp.Id;
			objAppDetP2.Service__c = objService.id;
			objAppDetP2.recordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ,System.label.CC_RT_Service_Type);
			
			CC_Application_Detail__c objAppDetW1 = new CC_Application_Detail__c();
			objAppDetW1.Related_Application__c = objApp.Id;
			objAppDetW1.Waiting_List_Program__c = lstProgtoInsert[0].id;
			objAppDetW1.recordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ,System.label.CC_RT_Waitlist_Type);
			
			appDetToInsert.add(objAppDetP1);
			appDetToInsert.add(objAppDetP2);
			appDetToInsert.add(objAppDetW1);

			insert appDetToInsert;

			CC_Application_Detail__c objAppDetP3 = new CC_Application_Detail__c();
			objAppDetP3.Related_Application__c = objApp.Id;
			objAppDetP3.Service__c = objService.id;
			objAppDetP3.Getting_the_Service__c = true;
			objAppDetP3.Other_Program_Name__c = 'Test';
			objAppDetP3.Other_Service_Name__c = 'Test';
			objAppDetP3.Service_Needed__c = false;
        
        	String strObj = JSON.serialize(objAppDetP3);

			List<Id> lstAppToDel = new List<Id>();
			lstAppToDel.add([Select id from CC_Application_Detail__c where
											recordTypeId =: CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ,System.label.CC_RT_Waitlist_Type)
											 LIMIT 1].id);

			objApp.CC_How_soon_services_needed__c = 'Within 1 year';
			objApp.CC_On_Any_Waiver_Waiting_List__c = true;
			update objApp;



			String sOtherComment = 'TestComment';
			List<String> lstSelectedWaitList = new List<String>{'Acquired Brain Injury Supports',
    														'Comprehensive Adult Supports',
    														'Other'};
            Test.startTest();
            
            System.runAs(userServiceIntake){
	            map<String,String> mapLabels = CC_ServicesController.loadLabelAndError();
				String strLoadData = CC_ServicesController.getPageDataForApplication(objApp.id);
				CC_ServicesController.updateApplication(objApp,sOtherComment,lstSelectedWaitList);
				String returnValDel = CC_ServicesController.deleteAppDetail(lstAppToDel,objApp.Id);
				String returnValAdd = CC_ServicesController.addAppDetail(strObj);
			}
			
			System.runAs(userAppintake){
				map<String,String> mapLabels = CC_ServicesController.loadLabelAndError();
				String strLoadData = CC_ServicesController.getPageDataForApplication(objApp.id);
				CC_ServicesController.updateApplication(objApp,sOtherComment,lstSelectedWaitList);
				String returnValDel = CC_ServicesController.deleteAppDetail(lstAppToDel,objApp.Id);
				String returnValAdd = CC_ServicesController.addAppDetail(strObj);
			}
			
			System.runAs(userCaseManager){
				map<String,String> mapLabels = CC_ServicesController.loadLabelAndError();
				String strLoadData = CC_ServicesController.getPageDataForApplication(objApp.id);
				CC_ServicesController.updateApplication(objApp,sOtherComment,lstSelectedWaitList);
				String returnValDel = CC_ServicesController.deleteAppDetail(lstAppToDel,objApp.Id);
				String returnValAdd = CC_ServicesController.addAppDetail(strObj);
			}
			Test.stopTest();
	}
}