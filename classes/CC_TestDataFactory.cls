/***************************************************************************************************************************************
 * NAME   : CC_TestDataFactory
 * DESCRIPTION  : for Test Data 
 *    
 * @AUTHOR   : Debalina
 * @DATE   : 10-27-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Debalina               10-27-2017            Initial version        
 * Akshay                 20-Nov-2017           Add re-usable methods for contact, account creation
 * Nidhin                 01-Dec-2017           create portal user
 * Debalina               04-Dec-2017           Master Settings creation
 * Debalina               15-Dec-2017           Method added for Internal User Creation createUser()
 * Akshay                 19-Dec-2017           Add re-usable methods for Program, App Detail creation,JSON substring
 ****************************************************************************************************************************************/

@isTest
public class CC_TestDataFactory {

    public static Map<String,String>  mapUserProfiles = new Map<String,String>();

    static {

        Set<String> setProfileNames = new Set<String>();
        setProfileNames.add(System.label.CC_App_Intake_Profile);
        setProfileNames.add(System.label.CC_Self_Service_Intake_Profile);
        setProfileNames.add(System.label.CC_Case_Manager_Profile);
        setProfileNames.add(System.label.CC_Capacity_Reviewer_Profile);

        List<Profile> lstUserProfiles = [SELECT Name, Id FROM Profile 
                                           WHERE Name IN: setProfileNames
                                        ];

        for(Profile obj : lstUserProfiles) {
            mapUserProfiles.put(obj.Name,obj.Id);
        }

        System.debug('mapUserProfiles:' +mapUserProfiles);
    }

    public static void createCustomSettingRecord() {
        CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
        objSettings.Comment_Records_Per_Page__c = 5;
        objSettings.Comment_Pages_Per_Screen__c = 5;
        objSettings.Task_Dashboard_Page_Size__c = 10;
        objSettings.Task_Dashboard_Pages_Per_Screen__c = 10;
        objSettings.Feed_Records_Per_Page__c = 2;
        objSettings.Feed_Pages_Per_Screen__c = 1;
        insert objSettings;
    }
    
    public static List<String> createNewIndividualApp(String sName,String sGender, String sSSN, Date dDOB){
        List<String> lstIds = new List<String>();
        
        Account objAccount = new Account(Name = sName+'\'s Account',
                                        RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_ACCOUNT_OBJ,CC_Constants.CC_ACCOUNT_INDIVIDUAL_RECORD_TYPE));
        insert objAccount;
        System.debug('objAccount.Id:' +objAccount.Id);
        lstIds.add(objAccount.Id);
        
        Contact objContact = new Contact();
        objContact.Birthdate =  dDOB;
        objContact.LastName = sName.toUpperCase();
        objContact.CC_Gender__c = sGender;
        objContact.CC_SSN__c = sSSN;
        objContact.AccountId = objAccount.Id;
        objContact.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Individual);
        insert objContact;
        System.debug('objContact.Id:' +objContact.Id);
        lstIds.add(objContact.Id);
        
        CC_Application__c objApp = new CC_Application__c();
        objApp.CC_Individual__c = objContact.Id;
        objApp.CC_App_Status__c = System.label.CC_AppStatus_InProgress;
        insert objApp;
        System.debug('objApp.Id:' +objApp.Id);
        lstIds.add(objApp.Id);
        return lstIds;
    }

    // Create common test records
    public static void setUpDataBasicInfo() {

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
        System.debug('objContact.Id:' +objContact);

        Case objCase = new Case();
        objCase.Status = System.label.CC_Case_Status_Active;
        insert objCase;
        System.debug('objCase.Id:' +objCase.Id);

        CC_Application__c objApp = new CC_Application__c();
        objApp.CC_Individual__c = objContact.Id;
        objApp.CC_App_Status__c = System.label.CC_AppStatus_InProgress;
        objApp.CC_Case__c = objCase.Id;
        insert objApp;
        System.debug('objApp.Id:' +objApp.Id);

        Contact objTestCon3 = new Contact();
        objTestCon3.Birthdate = Date.newInstance(1990, 10 , 21 );
        objTestCon3.FirstName = 'TestContact'.toUpperCase();
        objTestCon3.LastName = 'TestContact'.toUpperCase();
        objTestCon3.CC_Gender__c = 'Male';
        objTestCon3.CC_Suffix__c = 'II';
        objTestCon3.CC_SSN__c = '999999999';
        objTestCon3.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Individual);
        objTestCon3.CC_Contact_County__c = 'Other';
        objTestCon3.CC_Mailing_Address_County__c = 'Other';
        objTestCon3.CC_Physical_Address_State__c = 'Other';
        objTestCon3.CC_Mailing_Address_State__c = 'Other';
        insert objTestCon3;

        objCase = new Case();
        objCase.Status = System.label.CC_Case_Status_Active;
        insert objCase;
        System.debug('objCase>>' +objCase);

        objApp = new CC_Application__c();
        objApp.CC_Individual__c = objTestCon3.Id;
        objApp.CC_App_Status__c = System.label.CC_AppStatus_Complete;
        objApp.CC_Case__c = objCase.Id;
        insert objApp;
        System.debug('objApp>>' +objApp);

        objTestCon3 = new Contact();
        objTestCon3.Birthdate = Date.newInstance(1990, 10 , 21 );
        objTestCon3.FirstName = 'TestContact'.toUpperCase();
        objTestCon3.LastName = 'TestContact'.toUpperCase();
        objTestCon3.CC_Gender__c = 'Male';
        objTestCon3.CC_Suffix__c = 'II';
        objTestCon3.CC_SSN__c = '123456789';
        objTestCon3.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Individual);
        objTestCon3.CC_Contact_County__c = 'Other';
        objTestCon3.CC_Mailing_Address_County__c = 'Other';
        objTestCon3.CC_Physical_Address_State__c = 'Other';
        objTestCon3.CC_Mailing_Address_State__c = 'Other';
        insert objTestCon3;

        objApp = new CC_Application__c();
        objApp.CC_Individual__c = objTestCon3.Id;
        objApp.CC_App_Status__c = System.label.CC_AppStatus_Complete;
        
        insert objApp;
        System.debug('objApp1>>' +objApp);


     
    }

    public static void createTestUsers() {
        List<User> lstUserToInsert = new List<User>();
        User userIntake = new User(Alias = 'intakeU', Email='intakeUser@abc.com',
        EmailEncodingKey='UTF-8', LastName='TestingAppIntakeUser', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = mapUserProfiles.get(System.label.CC_App_Intake_Profile),
        TimeZoneSidKey='America/Los_Angeles', UserName='intakeUser@cccloud.dev');          
        lstUserToInsert.add(userIntake);
        insert lstUserToInsert;
        System.debug(lstUserToInsert);
    }

    public static void createUser(String sProfileName){
        User user = new User(Alias = 'Testing', Email='anyTestUser@abc.com',
        EmailEncodingKey='UTF-8', LastName='anyTestUser', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = mapUserProfiles.get(sProfileName),
        TimeZoneSidKey='America/Los_Angeles', UserName='anyTestUser@cccloud.dev');          
        
        insert user;
        
        System.debug(user);
    }

    public static String createBasicInfoPageJSON() {
        String objJSON = '{"PicklistWrapper":{"lstSuffixOptions":["JR.","SR.","II","III","IV","V","VI","VII"],"lstGenderOptions":["Male","Female"]},"MapLabelError":{"CC_Err_SSN_Mismatch":"SSN does not match.","CC_Err_Enter_Confirm_SSN":"Please enter Confirm SSN.","CC_Err_Cannot_Be_Blank":"Can not be blank.","CC_Err_Name_Contains_Numbers":"Please Enter Valid Name.","CC_Err_DOB_Required":"Please Enter Date Of Birth.","CC_Err_DOB_Future_Date":"Date of Birth Cannot be Present or Future date","CC_SEC_BasicInfo":"Basic Information","CC_Err_Midle_Initial":"Enter Valid Middle Initial","CC_Err_SSN_Len_Less_Than_9":"Must be of 9 characters.","CC_LBL_SELECT":"--SELECT--","CC_LBL_Confirm_SSN":"Confirm Social Security Number","CC_LBL_SSN":"Social Security Number(SSN)","CC_LBL_Gender":"Gender","CC_LBL_DOB":"Date of Birth","CC_LBL_Suffix":"Suffix","CC_LBL_LastName":"Last Name","CC_LBL_Middle_Initial":"Middle Initial","CC_LBL_FirstName":"First Name"}}';
        return objJSON;
    }

    /*
     Createing Service & Program,Application and Application Details Data for Service Component Test Class
     */
     public static void setUpServiceData(){

            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.RecordTypeId = CC_Utility.getRecordTypeId('Account', System.label.CC_Account_RecType);
            insert acc;

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
                objProg.Agency__c = acc.id;

                lstProgtoInsert.add(objProg);
            }
            insert lstProgtoInsert;

            CC_Program_Service__c objService = new CC_Program_Service__c();
            objService.recordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_Service);
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

            CC_Application_Detail__c objAppDetP1 = new CC_Application_Detail__c(Related_Application__c = objApp.Id,
                                                        Service__c = objService.id);
            CC_Application_Detail__c objAppDetW1 = new CC_Application_Detail__c(Related_Application__c = objApp.Id,
                                                        Waiting_List_Program__c = lstProgtoInsert[0].id);

        }


        public static String getObjectJSON(sObject sObj) {
            return JSON.serialize(sObj);
        } 

        public static CC_Application__c createApp() {
            Contact objCon = new Contact();
            objCon.LastName = 'LivingSituation';
            insert objCon;

            CC_Application__c objApp = new CC_Application__c();
            objApp.CC_Where_does_the_individual_live__c = System.Label.CC_LBL_OTHER;
            objApp.CC_Is_Living_Situation_Working__c = false;
            objApp.CC_Where_do_you_Prefer__c = System.Label.CC_LBL_OTHER;
            objApp.CC_Explain_living_situation__c = 'Description';
            objApp.CC_Explain_Where_do_you_prefer__c = 'Description';
            objApp.CC_Individual__c = objCon.Id;
            
            insert objApp;
            return objApp;
        }
        
        public static Group createQueue(){
            Group testGroup = new Group(Name='TestQueue', DeveloperName = 'TestQueue', Type='Queue');
            insert testGroup;
            System.runAs(new User(Id=UserInfo.getUserId())){
                QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'DT_Task__c');
                insert testQueue;
            }
            return testGroup;
        }
        
	public enum PortalType { CspLitePortal, PowerPartner, PowerCustomerSuccess, CustomerSuccess }
    
    public static User getPortalUser(PortalType portalType, User userWithRole, Boolean doInsert) {
    
        /* Make sure the running user has a role otherwise an exception 
           will be thrown. */
        if(userWithRole == null) {   
            
            if(UserInfo.getUserRoleId() == null) {

                UserRole r = new UserRole(name = 'TEST ROLE');
                Database.insert(r);
                
                userWithRole = new User(alias = 'hasrole', email='userwithrole@roletest1.com', userroleid = r.id,
                                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                                    localesidkey='en_US', profileid = UserInfo.getProfileId(), 
                                    timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
            } else {
                userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
            }
            
            System.assert(userWithRole.userRoleId != null, 
                          'This test requires the target org to have at least one UserRole created. Please create a user role in this organization and try again.');
        }

        Account a;
        Contact c;
        System.runAs(userWithRole) {

            a = new Account(name = 'TEST ACCOUNT');
            Database.insert(a);
            
            c = new Contact(AccountId = a.id, lastname = 'lastname', email = 'test@test.com');
            Database.insert(c);

        }
        
        /* Get any profile for the given type.*/
        Profile p = [select id 
                      from profile 
                     where usertype = :portalType.name() 
                     limit 1];   
        
        String testemail = 'puser000@amamama.com';
        User pu = new User(profileId = p.id, username = testemail, email = testemail, 
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US', 
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', 
                           alias='cspu', lastname='lastname', contactId = c.id);
        
        if(doInsert) {
            Database.insert(pu);
        }
        return pu;
    }  
    
    //Start:[Akshay 19-Dec-17]: Common method for program creation
    public static CC_Program_Service__c createProgram(String sName,List<String> lstProgDetails){
        CC_Program_Service__c objProg = new CC_Program_Service__c();
		objProg.recordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_Program);
		objProg.Name = sName;
		objProg.Active__c = true;
		insert objProg;
        String sProgDetailRT = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_ProgramDetail);
        List<CC_Program_Service__c> lstProgramDetails = new List<CC_Program_Service__c>();
        for(String sProgramDetail : lstProgDetails){
            List<String> lstCategory =  sProgramDetail.split(':');
            lstProgramDetails.add(new CC_Program_Service__c(Master_Program__c = objProg.Id, recordTypeId=sProgDetailRT,
                                                           Capacity__c = Decimal.valueOf(lstCategory[1]), Name =lstCategory[0]));
        }
        if(!lstProgramDetails.isEmpty())    
            insert lstProgramDetails;
        return objProg;
    }
    //End:[Akshay 19-Dec-17]: Common method for program creation
    
	//Start:[Akshay 19-Dec-17]: Common method for Program selection creation
    public static CC_Application_Detail__c createProgramSelection(String sAppId, String sProgId){
        CC_Application_Detail__c objAppDetail = new CC_Application_Detail__c();
        objAppDetail.Related_Application__c = sAppId;
        objAppDetail.Waiting_List_Program__c = sProgId;
        objAppDetail.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, System.label.CC_RT_Waiver_AppDetail);
        insert objAppDetail;
        return objAppDetail;
    }
	//End:[Akshay 19-Dec-17]: Common method for Program selection creation
	
    //Start:[Akshay 19-Dec-17]: Common method for JSON substring
    public static String getJSONToDesirialize(String sJSON,String sJSONPrefix, String sJSONSuffix){
        CC_ResponseWrapper wrapResponse = (CC_ResponseWrapper) JSON.deserialize(sJSON, CC_ResponseWrapper.class);
        System.debug('wrapResponse: ' + wrapResponse);
        System.assert(wrapResponse.success,'Error occurred when not expected: '+wrapResponse.response);
        sJSON = wrapResponse.response;
        return sJSON.substring(sJSON.indexOf(sJSONPrefix)+sJSONPrefix.length(),sJSON.lastIndexOf(sJSONSuffix));
    }
    //End:[Akshay 19-Dec-17]: Common method for JSON substring
}