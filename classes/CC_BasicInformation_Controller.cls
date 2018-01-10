/***************************************************************************************************************************************
 * NAME   : CC_BasicInformation_Controller
 * DESCRIPTION  : for CC_BasicInformation_Comp 
 *    
 * @AUTHOR   : Debalina
 * @DATE   : 10-27-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Debalina				  10-27-2017			Initial version        
 * Akshay Mohan			  11-13-2017			Added security model changes for creating account.
 * Debalina               11-18-2017            Ticket 756 Pre default Contact value for Self Service
 * Debalina               12-05-2017            Replaced some hardcoded values
 * Debalina               12-06-2017            lstSuffixOptions modified
 * Debalina               12-08-2017            Code Review Comment Changes.
 ****************************************************************************************************************************************/

public without sharing class CC_BasicInformation_Controller {

	public static User objUser;

	static {
		objUser = [SELECT ID,Name,Profile.Name,Contact.Id,Contact.AccountId FROM User WHERE ID =:UserInfo.getUserId()];
	}

	public class BasicInfoMessageWrapper {
		public String sMessage;
		public Boolean bHasError;
		public BasicInfoMessageWrapper(Boolean bHasError, String sMessage) {
			this.bHasError = bHasError;
			this.sMessage = sMessage;
		}
	}

	public class BasicInfoResponseWrapper {
		public BasicInfoMessageWrapper objMessage;
		public String sContactId;
		public String sApplicationId;

		public BasicInfoResponseWrapper(){}

		public BasicInfoResponseWrapper(String sAppId, String sConId, BasicInfoMessageWrapper objMsg){
			this.sContactId = sConId;
			this.sApplicationId = sAppId;
			this.objMessage = objMsg;
		}

	}

	/*****************************************************************************************************************************************/
	/* getPageData 
    * @params : N/A 
    * @return : JSON String with all data and static values relevant to the page
    *****************************************************************************************************************************************/
	@AuraEnabled
	public static String getPageData() {

		try{
			Map<String, Schema.SObjectField> mapContactFields = CC_Utility.getFieldMap(CC_Constants.CC_CONTACT_OBJ);
			List<String> lstGenderOptions = CC_Utility.getPicklistValuesFromFieldMap(mapContactFields, CC_Constants.CC_CONTACT_GENDER);
			List<CC_PickListValue_Wrapper> lstSuffixOptions = CC_Utility.getPicklistValuesWrapper(mapContactFields,CC_Constants.CC_CONTACT_SUFFIX,
	                                                                                  System.Label.CC_Select_Suffix);
			Map<String,String> mapLabelAndError = loadLabelAndError();
			Contact objCurrentCon; 

			if(objUser.Profile.Name == System.Label.CC_Self_Service_Intake_Profile) {
				List<Contact> lstCurrentCon = [ SELECT Id,
													   FirstName,
													   LastName,
													   CC_Suffix__c,
													   CC_Middle_Initial__c,
													   Birthdate,
													   CC_Gender__c,
													   CC_SSN__c
												FROM Contact
												WHERE Id =: objUser.Contact.Id LIMIT 1];
				objCurrentCon = lstCurrentCon[0];
				objCurrentCon.CC_Suffix__c = String.isNotBlank(objCurrentCon.CC_Suffix__c)? objCurrentCon.CC_Suffix__c : '';
				objCurrentCon.CC_Middle_Initial__c = String.isNotBlank(objCurrentCon.CC_Middle_Initial__c)? objCurrentCon.CC_Middle_Initial__c : '';
				objCurrentCon.CC_SSN__c = String.isNotBlank(objCurrentCon.CC_SSN__c)? objCurrentCon.CC_SSN__c : '';
				objCurrentCon.Birthdate = Date.valueOf(objCurrentCon.Birthdate);
			}

		return '{"lstGenderOptions":'+JSON.serialize(lstGenderOptions)
				+ ',"lstSuffixOptions":'+JSON.serialize(lstSuffixOptions)
				+ ',"ContactInfo":'+JSON.serialize(objCurrentCon)
				+ ',"CurrentProfile":'+JSON.serialize(objUser.Profile.Name)
				+ ',"SiteName":'+JSON.serialize(Site.getName())
				+ ',"MapLabelError":'+JSON.serialize(mapLabelAndError)+ '}';
						
		}catch(Exception ex){
        	System.debug('Exception on Class : CC_BasicInformation_Controller - getPageData, Error : ' +
	        ex.getMessage() +
	        ' Line Number : ' +
	        ex.getLineNumber() +
	        ' Cause : ' +
	        ex.getCause() +
	        ' Type : ' +
	        ex.getTypeName());
	        throw ex;
	        return '';
        }

		
	}


	/******************************************************************************************************************************************/
	/* loadLabelAndError 
    * @params : N/A 
    * @return : Map of static values needed for the page
  	/*****************************************************************************************************************************************/
	@TestVisible
	private static Map<String,String> loadLabelAndError() {
		Map<String,String> mapLabelAndError = new Map<String, String>();
		mapLabelAndError.put('CC_LBL_FirstName',System.label.CC_LBL_FirstName);
		mapLabelAndError.put('CC_LBL_Middle_Initial',System.label.CC_LBL_Middle_Initial);
		mapLabelAndError.put('CC_LBL_LastName',System.label.CC_LBL_LastName);
		mapLabelAndError.put('CC_LBL_Suffix',System.label.CC_LBL_Suffix);
		mapLabelAndError.put('CC_LBL_DOB',System.label.CC_LBL_DOB);
		mapLabelAndError.put('CC_LBL_Gender',System.label.CC_LBL_Gender);
		mapLabelAndError.put('CC_LBL_SSN',System.label.CC_LBL_SSN); 
		mapLabelAndError.put('CC_LBL_Confirm_SSN',System.label.CC_LBL_Confirm_SSN); 
		mapLabelAndError.put('CC_LBL_SELECT',System.label.CC_LBL_SELECT);

		mapLabelAndError.put('CC_Err_SSN_Len_Less_Than_9',System.label.CC_Err_SSN_Len_Less_Than_9);
		mapLabelAndError.put('CC_Err_Midle_Initial',System.label.CC_Err_Midle_Initial);
		mapLabelAndError.put('CC_SEC_BasicInfo',System.label.CC_SEC_BasicInfo);
		mapLabelAndError.put('CC_Err_DOB_Future_Date',System.label.CC_Err_DOB_Future_Date);
		mapLabelAndError.put('CC_Err_DOB_Required',System.label.CC_Err_DOB_Required);
		mapLabelAndError.put('CC_Err_Name_Contains_Numbers',System.label.CC_Err_Name_Contains_Numbers);
		mapLabelAndError.put('CC_Err_Cannot_Be_Blank',System.label.CC_Err_Cannot_Be_Blank);
		mapLabelAndError.put('CC_Err_Enter_Confirm_SSN',System.label.CC_Err_Enter_Confirm_SSN);
		mapLabelAndError.put('CC_Err_SSN_Mismatch',System.label.CC_Err_SSN_Mismatch);
		mapLabelAndError.put('CC_Self_Service_Intake_Profile',System.label.CC_Self_Service_Intake_Profile);
		mapLabelAndError.put('CC_SITE_NAME_SELF_SERVICE', System.Label.CC_SITE_NAME_SELF_SERVICE);
		mapLabelAndError.put('CC_SITE_NAME_SERVICE_PROVIDER', System.Label.CC_SITE_NAME_SERVICE_PROVIDER);
		mapLabelAndError.put('CC_ApplicationIntake', System.Label.CC_ApplicationIntake);
		mapLabelAndError.put('CC_Err_DOB_Format', System.Label.CC_Err_DOB_Format);

		
		return mapLabelAndError;
	}

	/******************************************************************************************************************************************/
	/* createIndividualBasicInfo 
    * @params : sJSON - JSON of Contact to be created  
    * @return : JSON Response with created/existing Contact Id and Application Id
    ******************************************************************************************************************************************/
	@AuraEnabled
	public static String createIndividualBasicInfo(String sJSON) {

		try{
			String sIndvRecTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Individual);
			Contact objContact = (Contact) JSON.deserialize(sJSON, Contact.class);
			System.debug('objContact:' +objContact);
			Date dtBirthDate = Date.valueOf(objContact.Birthdate);
			String sFName = String.valueOf(objContact.FirstName.trim().toUpperCase());
			String sLName = String.valueOf(objContact.LastName.trim().toUpperCase());
			String sGender = String.valueOf(objContact.CC_Gender__c);

			//querying matching app and contact
			String sAppQuery = 'SELECT Id, CC_App_Status__c, CC_Case__c, CC_Case__r.Status, CC_Individual__r.Id'
							 + ',CC_Individual__r.FirstName, CC_Individual__r.LastName, CC_Individual__r.CC_Suffix__c'
							 + ',CC_Individual__r.CC_Middle_Initial__c, CC_Individual__r.Birthdate, CC_Individual__r.CC_SSN__c'
							 + ',CC_Individual__r.CC_Gender__c FROM CC_Application__c'
							 + ' WHERE CC_Individual__r.RecordTypeId =: sIndvRecTypeId';

			System.debug('here1:');				 
			if(String.isNotBlank(objContact.CC_SSN__c)) {
				String sSSN = String.valueOf(objContact.CC_SSN__c.trim());
				sAppQuery += ' AND CC_Individual__r.CC_SSN__c =: sSSN';
				System.debug('here2:');	
			}else {
				sAppQuery += ' AND CC_Individual__r.FirstName =: sFName'
							 + ' AND CC_Individual__r.LastName =: sLName' 
							 + ' AND CC_Individual__r.Birthdate =: dtBirthDate'
							 + ' AND CC_Individual__r.CC_Gender__c =: sGender';
			}

			System.debug(sAppQuery);
			List<CC_Application__c> lstOfMatchingAppContact = Database.query(sAppQuery);
			System.debug('lstOfMatchingAppContact:' +lstOfMatchingAppContact);
			System.debug('sFName:' +sFName);
			System.debug('sLName:' +sLName);
			System.debug('sGender:' +sGender);
			System.debug('dtBirthDate:' +dtBirthDate);

			BasicInfoMessageWrapper objMsg = NULL; 
			String sConId,sAppId = NULL;

			if(!lstOfMatchingAppContact.isEmpty()) {
				Boolean bIsCreateNewApp = false;
				Boolean bIsCasePresent = false;

				for(CC_Application__c objApp: lstOfMatchingAppContact) {
					if(!System.label.CC_AppStatus_Complete.equals(objApp.CC_App_Status__c)
						&& !System.label.CC_AppStatus_Terminated.equals(objApp.CC_App_Status__c)
						){
						//In-Progress/Review Application exists
						bIsCreateNewApp = false;
						bIsCasePresent = false;
						break;
					}else{
						if(String.isNotBlank(objApp.CC_Case__c)){
							//individual exists 
							bIsCreateNewApp = true;
							bIsCasePresent = true;
						}else{
						   //individual exists without an active Case 
						   bIsCreateNewApp = true;
						   bIsCasePresent = false;
						}
					}
				}
				
				if(bIsCreateNewApp) {
					if(bIsCasePresent){
						sConId = lstOfMatchingAppContact[0].CC_Individual__r.Id;
						sAppId = createNewApplication(sConId,lstOfMatchingAppContact[0].CC_Case__c);
						objMsg = new BasicInfoMessageWrapper(false,System.label.CC_Err_Individual_Exists_App_Created);
					}else {
						sConId = lstOfMatchingAppContact[0].CC_Individual__r.Id;
						sAppId = createNewApplication(sConId,CC_Constants.CC_EMPTY);
						objMsg = new BasicInfoMessageWrapper(false,System.label.CC_Err_Individual_Exists_App_Created);
					}
				}else {
					sConId = lstOfMatchingAppContact[0].CC_Individual__r.Id;
					objMsg = new BasicInfoMessageWrapper(true,System.label.CC_Err_Individual_Exists);
				}

			}else{
				//For self service user no application exists
				if(objUser.Profile.Name == System.Label.CC_Self_Service_Intake_Profile) {
					//updating contact info pending
					sConId = objUser.Contact.Id;
					sAppId = createNewApplication(sConId,CC_Constants.CC_EMPTY);
					objMsg = new BasicInfoMessageWrapper(false,System.label.CC_Err_Individual_Exists_App_Created);
				}
				else {
					sConId = createContact(objContact);
					sAppId = createNewApplication(sConId,CC_Constants.CC_EMPTY);
					objMsg = new BasicInfoMessageWrapper(false,System.label.CC_Err_Individual_Created);
				}
			}

			BasicInfoResponseWrapper objBasicInfoResp = new BasicInfoResponseWrapper(sAppId,sConId,objMsg);
			return '{"BasicInfoResponseWrapper":'+JSON.serialize(objBasicInfoResp)+'}'; 
		}catch(Exception ex){
        	System.debug('Exception on Class : CC_BasicInformation_Controller - createIndividualBasicInfo, Error : ' +
	        ex.getMessage() +
	        ' Line Number : ' +
	        ex.getLineNumber() +
	        ' Cause : ' +
	        ex.getCause() +
	        ' Type : ' +
	        ex.getTypeName());
	        throw ex;
	        return '';
        }
		
	}

	/******************************************************************************************************************************************/
	/* createContact 
	* @Description : This method is called from createIndividualBasicInfo to create Individual type Contacts
    * @params : objContact - Contact Object to be inserted
    * @return : Id of created Contact
    ******************************************************************************************************************************************/
	private static Id createContact(Contact objContact) {
		String retString = '';
		objContact.Birthdate = Date.valueOf(objContact.Birthdate) ;
		objContact.FirstName = String.valueOf(objContact.FirstName.trim().toUpperCase());
		objContact.LastName = String.valueOf(objContact.LastName.trim().toUpperCase());
		objContact.CC_Gender__c = String.valueOf(objContact.CC_Gender__c);
		objContact.CC_Suffix__c = String.valueOf(objContact.CC_Suffix__c);
		objContact.CC_SSN__c = String.isNotBlank(objContact.CC_SSN__c) ? String.valueOf(objContact.CC_SSN__c.trim()) : '';
		objContact.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Individual);
		//objContact.AccountId = System.label.CC_Community_Dummy_Account;
		objContact.CC_Contact_County__c = CC_Constants.CC_OTHER;
		objContact.CC_Mailing_Address_County__c = CC_Constants.CC_OTHER;
		objContact.CC_Physical_Address_State__c = CC_Constants.CC_OTHER;
		objContact.CC_Mailing_Address_State__c = CC_Constants.CC_OTHER;
		
		//Start:Akshay[13-Nov-2017]: Adding Logic for security model
		System.debug('Logged in user: ' + objUser);
		if(objUser.Profile.Name == System.Label.CC_Self_Service_Intake_Profile){//Intake Worker Profile or Case MAnager
			objContact.AccountId =  objUser.Contact.AccountId;
			System.debug('Contact updated with account ID: ' + objUser.Contact.AccountId);
		}else {// create account for all other profiles
			Account objIndividualAccount = new Account(Name=objContact.FirstName+' '+objContact.LastName+'\'s Account', OwnerId = System.Label.CC_Portal_Master_ID,
														RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_ACCOUNT_OBJ,CC_Constants.CC_ACCOUNT_INDIVIDUAL_RECORD_TYPE));
			insert objIndividualAccount;
			System.debug('Accoutn created: ' + objIndividualAccount);
			objContact.AccountId = objIndividualAccount.Id;
		}
		objContact.OwnerId = System.Label.CC_Portal_Master_ID;
		//End:Akshay[13-Nov-2017]: Adding Logic for security model

		System.debug('objContact to insert:' +objContact);
        insert objContact;
        System.debug('objContact inserted:' +objContact);
        retString = objContact.Id;
       
		return retString;
	}


	/******************************************************************************************************************************************/
	/* createContact 
	* @Description : Create new Application using Contact Id and associates the application with existing Case if that exists.
    * @params : contactId, caseId existing contact or case Id
    * @return : Id of created Contact
    ******************************************************************************************************************************************/
 	private static String createNewApplication(String contactId,String caseId){
    	String retString = '';
        if(String.isNotBlank(contactId)){
        	CC_Application__c objApp = new CC_Application__c();
            objApp.CC_Individual__c = contactId;

            if(String.isNotBlank(caseId)){
            	objApp.CC_Case__c = caseId;
           	    //if case status closed it has to be changed to active
           	    Case objCase = new Case();
           	    objCase.Id = caseId;
           	    objCase.Status = System.label.CC_Case_Status_Active;
           	    update objCase;
            }
            	
            insert objApp;
            retString = objApp.Id;
        }
        else{
        	System.debug('contactId unspecified =' +contactId);
        	retString = '';
        }
            
        return retString; 
    }

}