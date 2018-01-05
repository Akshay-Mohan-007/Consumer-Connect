/***************************************************************************************************************************************
 * NAME   : CC_TestBasicInformation_Controller
 * DESCRIPTION  : for CC_BasicInformation_Controller 
 *    
 * @AUTHOR   : Debalina
 * @DATE   : 10-27-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Debalina				  10-27-2017			Initial version        
 *
 ****************************************************************************************************************************************/
@isTest
private class CC_TestBasicInformation_Controller {

	@testSetup 
	private static void setUpData() {
		CC_TestDataFactory.setUpDataBasicInfo();
		CC_TestDataFactory.createTestUsers();
	}

	static testmethod void testGetPageData() {
		Map<String,String> mapErrorLabel = CC_BasicInformation_Controller.loadLabelAndError();
		Test.startTest();
		String objPageDataObj = CC_BasicInformation_Controller.getPageData();
		Test.stopTest();
		//System.assertEquals(CC_TestDataFactory.createBasicInfoPageJSON(),objPageDataObj);
		
	}

	static testmethod void testCreateIndividualBasicInfo(){

		String sJSONResponse1 = '';
		CC_BasicInformation_Controller.BasicInfoResponseWrapper objResponse1 = new CC_BasicInformation_Controller.BasicInfoResponseWrapper();
		
		String sJSONResponse2 = '';
		CC_BasicInformation_Controller.BasicInfoResponseWrapper objResponse2 = new CC_BasicInformation_Controller.BasicInfoResponseWrapper();

		String sJSONResponse3 = '';
		CC_BasicInformation_Controller.BasicInfoResponseWrapper objResponse3 = new CC_BasicInformation_Controller.BasicInfoResponseWrapper();

		String sJSONResponse4 = '';
		CC_BasicInformation_Controller.BasicInfoResponseWrapper objResponse4 = new CC_BasicInformation_Controller.BasicInfoResponseWrapper();


		String sJSONResponse5 = '';
		CC_BasicInformation_Controller.BasicInfoResponseWrapper objResponse5 = new CC_BasicInformation_Controller.BasicInfoResponseWrapper();

		Contact objTestCon1 = new Contact();
		objTestCon1.Birthdate = Date.newInstance(1990, 10 , 21 );
		objTestCon1.FirstName = 'TestFirstName1'.toUpperCase();
		objTestCon1.LastName = 'TestLastName1'.toUpperCase();
		objTestCon1.CC_Gender__c = 'Male';
		objTestCon1.CC_Suffix__c = 'II';
		objTestCon1.CC_SSN__c = '';
		objTestCon1.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Individual);
		objTestCon1.CC_Contact_County__c = 'Other';
		objTestCon1.CC_Mailing_Address_County__c = 'Other';
		objTestCon1.CC_Physical_Address_State__c = 'Other';
		objTestCon1.CC_Mailing_Address_State__c = 'Other';

		Contact objTestCon2 = new Contact();
		objTestCon2.Birthdate = Date.newInstance(1990, 10 , 21 );
		objTestCon2.FirstName = 'TestFirst1'.toUpperCase();
		objTestCon2.LastName = 'TestLast1'.toUpperCase();
		objTestCon2.CC_Gender__c = 'Male';
		objTestCon2.CC_Suffix__c = 'II';
		objTestCon2.CC_SSN__c = '888888888';
		objTestCon2.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Individual);
		objTestCon2.CC_Contact_County__c = 'Other';
		objTestCon2.CC_Mailing_Address_County__c = 'Other';
		objTestCon2.CC_Physical_Address_State__c = 'Other';
		objTestCon2.CC_Mailing_Address_State__c = 'Other';

		Contact objTestCon4 = new Contact();
		objTestCon4.Birthdate = Date.newInstance(1990, 10 , 21 );
		objTestCon4.FirstName = 'TestContactF'.toUpperCase();
		objTestCon4.LastName = 'TestContactL'.toUpperCase();
		objTestCon4.CC_Gender__c = 'Male';
		objTestCon4.CC_Suffix__c = 'II';
		objTestCon4.CC_SSN__c = '121212121';
		objTestCon4.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Individual);
		objTestCon4.CC_Contact_County__c = 'Other';
		objTestCon4.CC_Mailing_Address_County__c = 'Other';
		objTestCon4.CC_Physical_Address_State__c = 'Other';
		objTestCon4.CC_Mailing_Address_State__c = 'Other';

		User intakeSalesforceUser = [SELECT Id FROM User WHERE UserName = 'intakeUser@cccloud.dev' LIMIT 1];


		//inserting objTestCon1
		System.runAs(intakeSalesforceUser){
			sJSONResponse1 = CC_BasicInformation_Controller.createIndividualBasicInfo(JSON.serialize(objTestCon1));
			objResponse1 = (CC_BasicInformation_Controller.BasicInfoResponseWrapper) JSON.deserialize(sJSONResponse1, CC_BasicInformation_Controller.BasicInfoResponseWrapper.class);
			
		}

		Contact objExistingCon1 = [SELECT Id FROM Contact
								  WHERE FirstName =:objTestCon1.FirstName 
								  AND LastName =: objTestCon1.LastName
								  AND CC_Gender__c = 'Male'
								  AND Birthdate =: objTestCon1.Birthdate
								  LIMIT 1];

		Contact objExistingCon2 = [SELECT Id,CC_SSN__c,FirstName,LastName FROM Contact
								  WHERE CC_SSN__c = '888888888'
								  LIMIT 1];

		List<String> lstSSN = new List<String>();			
		lstSSN.add('888888888');
		lstSSN.add('999999999');
		lstSSN.add('123456789');

		System.debug('lstSSN:' + lstSSN);

		/*Map<String,Contact> mapSSNContact = new Map<String,Contact>();
		List<Contact> lstAlreadyExistingContact = [SELECT Id,FirstName,LastName,
														  CC_SSN__c,Birthdate,CC_Gender__c,
														  CC_Suffix__c,CC_Contact_County__c,
														  CC_Mailing_Address_County__c,CC_Physical_Address_State__c,
														  CC_Mailing_Address_State__c FROM Contact
												  WHERE CC_SSN__c IN : lstSSN
												  LIMIT 1];

		System.debug();

		for(Contact objCon : lstAlreadyExistingContact) {
			mapSSNContact.put(objCon.CC_SSN__c,objCon);
		}

		System.debug('mapSSNContact:' + mapSSNContact);*/

		Contact objExistingCon3 = [SELECT Id,FirstName,LastName,
										  CC_SSN__c,Birthdate,CC_Gender__c,
										  CC_Suffix__c,CC_Contact_County__c,
										  CC_Mailing_Address_County__c,CC_Physical_Address_State__c,
										  CC_Mailing_Address_State__c FROM Contact
								  WHERE CC_SSN__c = '999999999'
								  LIMIT 1];
		Contact objExistingCon4 = [SELECT Id,FirstName,LastName,
										  CC_SSN__c,Birthdate,CC_Gender__c,
										  CC_Suffix__c,CC_Contact_County__c,
										  CC_Mailing_Address_County__c,CC_Physical_Address_State__c,
										  CC_Mailing_Address_State__c FROM Contact
								  WHERE CC_SSN__c = '123456789'
								  LIMIT 1];

		Test.startTest();
		System.runAs(intakeSalesforceUser){
			
			sJSONResponse1 = CC_BasicInformation_Controller.createIndividualBasicInfo(JSON.serialize(objTestCon1));
			sJSONResponse1 =sJSONResponse1.substring('{"BasicInfoResponseWrapper":'.length(),sJSONResponse1.length() -1 );
			//System.debug('sJSONResponse1:' + sJSONResponse1);
			objResponse1 = (CC_BasicInformation_Controller.BasicInfoResponseWrapper) JSON.deserialize(sJSONResponse1, CC_BasicInformation_Controller.BasicInfoResponseWrapper.class);
			System.debug('Scenario 1 SSN not given objResponse1>>'+objResponse1);

			sJSONResponse2 = CC_BasicInformation_Controller.createIndividualBasicInfo(JSON.serialize(objTestCon2));
			sJSONResponse2 = sJSONResponse2.substring('{"BasicInfoResponseWrapper":'.length(),sJSONResponse2.length() -1 );
			//System.debug('sJSONResponse1:' + sJSONResponse2);
			objResponse2 = (CC_BasicInformation_Controller.BasicInfoResponseWrapper) JSON.deserialize(sJSONResponse2, CC_BasicInformation_Controller.BasicInfoResponseWrapper.class);
			System.debug('Scenario 2 SSN given objResponse2>>'+objResponse2);

			sJSONResponse3 = CC_BasicInformation_Controller.createIndividualBasicInfo(JSON.serialize(objExistingCon3));
			sJSONResponse3 = sJSONResponse3.substring('{"BasicInfoResponseWrapper":'.length(),sJSONResponse3.length() -1 );
			//System.debug('sJSONResponse3:' + sJSONResponse3);
			objResponse3 = (CC_BasicInformation_Controller.BasicInfoResponseWrapper) JSON.deserialize(sJSONResponse3, CC_BasicInformation_Controller.BasicInfoResponseWrapper.class);
			System.debug('Case Exists with Complete Application>>'+objResponse3);


			sJSONResponse4 = CC_BasicInformation_Controller.createIndividualBasicInfo(JSON.serialize(objTestCon4));
			sJSONResponse4 = sJSONResponse4.substring('{"BasicInfoResponseWrapper":'.length(),sJSONResponse4.length() -1 );
			//System.debug('sJSONResponse4:' + sJSONResponse4);
			objResponse4 = (CC_BasicInformation_Controller.BasicInfoResponseWrapper) JSON.deserialize(sJSONResponse4, CC_BasicInformation_Controller.BasicInfoResponseWrapper.class);
			System.debug('New Application and New Individual Created>>'+objResponse4);

			sJSONResponse5 = CC_BasicInformation_Controller.createIndividualBasicInfo(JSON.serialize(objExistingCon4));
			sJSONResponse5 = sJSONResponse5.substring('{"BasicInfoResponseWrapper":'.length(),sJSONResponse5.length() -1 );
			//System.debug('sJSONResponse5:' + sJSONResponse5);
			objResponse5 = (CC_BasicInformation_Controller.BasicInfoResponseWrapper) JSON.deserialize(sJSONResponse5, CC_BasicInformation_Controller.BasicInfoResponseWrapper.class);
			System.debug('Application Complete No Case>>'+objResponse5);

		}
		Test.stopTest();

		/*** Scenario 1 SSN not given Start****/
		System.debug('objExistingCon1>>'+objExistingCon1);
		if(objExistingCon1 != NULL){
			System.assertEquals(objExistingCon1.Id, objResponse1.sContactId);
		}
		System.assertEquals(System.label.CC_Err_Individual_Exists, objResponse1.objMessage.sMessage);
		System.assertEquals(true, objResponse1.objMessage.bHasError);
		System.assertEquals(NULL, objResponse1.sApplicationId);
		/*** Scenario 1 SSN not given End****/


		/*** Scenario 2 SSN given ****/
		System.debug('objExistingCon2>>'+objExistingCon2);
		if(objExistingCon2 != NULL){
			System.assertEquals(objExistingCon2.Id, objResponse2.sContactId);
		}
		System.assertEquals(System.label.CC_Err_Individual_Exists, objResponse2.objMessage.sMessage);
		System.assertEquals(true, objResponse2.objMessage.bHasError);
		System.assertEquals(NULL, objResponse2.sApplicationId);
		/*** Scenario 2 SSN given End****/


		/*** Case Exists with Completed Application ***/
		System.debug('objExistingCon3>>'+objExistingCon3);
		if(objExistingCon3 != NULL){
			System.assertEquals(objExistingCon3.Id, objResponse3.sContactId);
		}

		System.assertEquals(System.label.CC_Err_Individual_Exists_App_Created, objResponse3.objMessage.sMessage);
		System.assertEquals(false, objResponse3.objMessage.bHasError);
		System.assertEquals(true, (objResponse3.sApplicationId != NULL));
		/*** Case Exists with Completed Application ***/


		/*** Fresh Individual and Application Created ***/
		System.assertEquals(System.label.CC_Err_Individual_Created, objResponse4.objMessage.sMessage);
		System.assertEquals(false, objResponse4.objMessage.bHasError);
		System.assertEquals(true, (objResponse4.sApplicationId != NULL));
		System.assertEquals(true, (objResponse4.sContactId != NULL));
		/*** Fresh Individual and Application Created ***/


		/*** No Case Exists with Completed Application ***/
		if(objExistingCon4 != NULL){
			System.assertEquals(objExistingCon4.Id , objResponse5.sContactId);
		}

		System.assertEquals(System.label.CC_Err_Individual_Exists_App_Created, objResponse5.objMessage.sMessage);
		System.assertEquals(false, objResponse5.objMessage.bHasError);
		System.assertEquals(true, (objResponse5.sApplicationId != NULL));

		
	}



}