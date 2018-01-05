/***************************************************************************************************************************************
 * NAME   : CC_Test_IndividualSummary
 * DESCRIPTION  : Individual Summary Controller Test class
 *    
 * @AUTHOR   : Akshay Mohan
 * @DATE   : 27-Nov-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Akshay Mohan				27-Nov-2017			Initial version        
 ****************************************************************************************************************************************/
 @isTest
public class CC_Test_IndividualSummary {
	@testSetup//set up contact and application
    public static void setUpData() {
        String sAppId = CC_TestDataFactory.createNewIndividualApp('Test Guy','Male','123456789',Date.newInstance(1999, 10 , 21))[2];
        System.debug('sAppId: ' + sAppId);
        
    }

    private static CC_IndividualSummary_Controller.IndividualSummarryWrapper getWrapper(String sJSON){
    	String sPrefix ='{ "wrapIndivData" : ';
    	sJSON =sJSON.substring(sJSON.indexOf(sPrefix)+sPrefix.length(),sJSON.lastIndexOf('}'));
    	return (CC_IndividualSummary_Controller.IndividualSummarryWrapper) 
    			JSON.deserialize(sJSON, CC_IndividualSummary_Controller.IndividualSummarryWrapper.class);
    }

    @isTest
    public static void loadModal() {
    	List<CC_Application__c> lstApp = [SELECT ID,Name,CC_Individual__r.Name,CC_Individual__c FROM CC_Application__c];
        System.debug('lstApp: ' + lstApp);
        String sAppId = lstApp[0].Id,sContactId = lstApp[0].CC_Individual__c;

        Case objCase = new Case(Status = System.label.CC_Case_Status_Active, ContactId = sContactId,Action_Date__c =System.now());
        insert objCase;

        CC_Application__c objApp = new CC_Application__c(Id= sAppId, CC_Case__c = objCase.Id);
        update objApp;

        DT_TestDataFactory.createRuleVersion(NULL, TRUE);
        DT_Rule_Version__c objRuleVersion = [SELECT ID, Name FROM DT_Rule_Version__c LIMIT 1];
        DT_Landing_Navigation__c objLandNav = new DT_Landing_Navigation__c(DT_Parameters__c = 'sAppId:Application__c;sContactId:Contact__c;sModule:Application_Intake',
                                                                            Case_Manager_URL__c = 'application', Component_Name__c ='c:CC_ApplicationContainer', Self_Service_URL__c ='application');
        insert objLandNav;
        objRuleVersion.DT_Navigation__c = objLandNav.Id;
        update objRuleVersion;
        DT_Task__c objTask = new DT_Task__c(DT_Rule_Version__c = objRuleVersion.Id, Contact__c = sContactId, Application__c = sAppId, Case__c = objCase.Id);
        insert objTask;

        Test.startTest();
        String sResultJSON = CC_IndividualSummary_Controller.loadData(null,objTask.Id, false);
        Test.stopTest();

        System.debug('sResultJSON: ' + sResultJSON);
        CC_IndividualSummary_Controller.IndividualSummarryWrapper wrapIndivData = getWrapper(sResultJSON);
        System.debug('wrapIndivData: ' + wrapIndivData);
        System.assert(wrapIndivData.lstPrograms==null,'Programs initialized without querying!');
        System.assertEquals('Test Guy'.toUpperCase(),wrapIndivData.sIndivName,'Wrong individual returned!');
        System.assertEquals(CC_Constants.CC_NO_DATA,wrapIndivData.sLGName,'Wrong LG returned!');
        System.assertEquals(CC_Constants.CC_NO_DATA,wrapIndivData.sARName,'Wrong AR returned!');
    }

    @isTest
    public static void loadModalWithRep() {
    	List<CC_Application__c> lstApp = [SELECT ID,Name,CC_Individual__r.Name,CC_Individual__c,CC_Individual__r.AccountId FROM CC_Application__c];

        System.debug('lstApp: ' + lstApp);
        String sAppId = lstApp[0].Id,sContactId = lstApp[0].CC_Individual__c,sAccountId = lstApp[0].CC_Individual__r.AccountId;

        String sRepRTId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Individual);
        
        List<Contact> lstContacts = new List<Contact>();
        Contact objLG = new Contact(CC_Contact_Type__c = System.Label.CC_Contact_Type_Legal_Guardian, AccountId = sAccountId
        							,LastName = 'LG',Parent_Application__c = sAppId, RecordTypeId = sRepRTId);
        Contact objAR = new Contact(CC_Contact_Type__c = System.Label.CC_Contact_Type_Representative, AccountId = sAccountId
        							,LastName = 'AR', Parent_Application__c = sAppId, RecordTypeId = sRepRTId);
        lstContacts.add(objLG);
        lstContacts.add(objAR);
        insert lstContacts;
		System.debug('lstContacts: ' + lstContacts);
		/*Integer start = System.Now().millisecond();
		while(System.Now().millisecond()< start+900){  delay not working
		}*/
		CC_Application__c objApp = new CC_Application__c();
        objApp.CC_Individual__c = sContactId;
        objApp.CC_App_Status__c = System.label.CC_AppStatus_InProgress;
        insert objApp;
        
        System.debug('Testing start for loadModalWithRep');
        Test.startTest();
        objLG = new Contact(CC_Contact_Type__c = System.Label.CC_Contact_Type_Legal_Guardian+';'+System.Label.CC_Contact_Type_Representative,
        							 AccountId = sAccountId, LastName = 'LGAR',Parent_Application__c = objApp.Id, RecordTypeId = sRepRTId);
        insert objLG;
        String sResultJSON = CC_IndividualSummary_Controller.loadData(sContactId,null, false);
        Test.stopTest();

        System.debug('sResultJSON: ' + sResultJSON);
        CC_IndividualSummary_Controller.IndividualSummarryWrapper wrapIndivData = getWrapper(sResultJSON);
        System.debug('wrapIndivData in loadModalWithRep: ' + wrapIndivData);
        System.assert(wrapIndivData.lstPrograms==null,'Programs initialized without querying!');
        System.assertEquals('Test Guy'.toUpperCase(),wrapIndivData.sIndivName,'Wrong individual returned!');
        /*System.assertEquals('LGAR',wrapIndivData.sLGName,'Wrong LG returned!'); //doesnt work since contact is created in same milisecond
        System.assertEquals('LGAR',wrapIndivData.sARName,'Wrong AR returned!');*/
    }

    @isTest
    public static void loadPage() {
    	List<CC_Application__c> lstApp = [SELECT ID,Name,CC_Individual__r.Name,CC_Individual__c FROM CC_Application__c];
        System.debug('lstApp: ' + lstApp);
        String sAppId = lstApp[0].Id,sContactId = lstApp[0].CC_Individual__c;
        Case objCase = new Case(ContactId = sContactId);
        insert objCase;
        CC_Application__c objApp = new CC_Application__c(Id = sAppId, CC_Case__c = objCase.Id);
        update objApp;

        String sRepRTId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Representative);
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(new Contact(CC_Contact_Type__c = System.Label.CC_Contact_Type_Legal_Guardian
        							,LastName = 'LG',Parent_Application__c = sAppId, RecordTypeId = sRepRTId));
        lstContacts.add(new Contact(CC_Contact_Type__c = System.Label.CC_Contact_Type_Representative
        							,LastName = 'AR', Parent_Application__c = sAppId, RecordTypeId = sRepRTId));
        insert lstContacts;
        System.debug('lstContacts: ' + lstContacts);

        Test.startTest();
        String sResultJSON = CC_IndividualSummary_Controller.loadData(sContactId,null, true);
        Test.stopTest();

        System.debug('sResultJSON: ' + sResultJSON);
        CC_IndividualSummary_Controller.IndividualSummarryWrapper wrapIndivData = getWrapper(sResultJSON);
        System.debug('wrapIndivData: ' + wrapIndivData);
        System.assert(wrapIndivData.lstPrograms!=null,'Programs not initialized after querying!');
        System.assertEquals('Test Guy'.toUpperCase(),wrapIndivData.sIndivName,'Wrong individual returned!');
        
    }

    @isTest
    public static void loadPageWithMultiplePrograms() {
    	List<CC_Application__c> lstApp = [SELECT ID,Name,CC_Individual__r.Name,CC_Individual__c FROM CC_Application__c];
        System.debug('lstApp: ' + lstApp);
        String sAppId = lstApp[0].Id,sContactId = lstApp[0].CC_Individual__c;
        Case objCase = new Case(ContactId = sContactId);
        insert objCase;
        
        CC_Application__c objApp = new CC_Application__c(Id = sAppId, CC_Case__c = objCase.Id);
        update objApp;

        CC_Program_Service__c objProgram = new CC_Program_Service__c(Name='Test Program',
        													RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, 'Program'));
        insert objProgram;
        System.debug('objProgram: ' + objProgram);

        CC_Application_Detail__c objSelectedApp1= new CC_Application_Detail__c(Waiting_List_Program__c =objProgram.Id, 
        																		Related_Application__c = sAppId,
        																		RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, CC_Constants.CC_RECORD_TYPE_WAIVER_PROGRAMS)); 
        insert objSelectedApp1;
        System.debug('objSelectedApp1: ' + objSelectedApp1);

        Test.startTest();
        String sResultJSON = CC_IndividualSummary_Controller.loadData(sContactId,null, true);
        Test.stopTest();

        System.debug('sResultJSON: ' + sResultJSON);
        CC_IndividualSummary_Controller.IndividualSummarryWrapper wrapIndivData = getWrapper(sResultJSON);
        System.debug('wrapIndivData: ' + wrapIndivData);
        System.assertEquals(1,wrapIndivData.lstPrograms.size(),'Programs not found after querying!');
        System.assertEquals('Test Program',wrapIndivData.lstPrograms[0].sProgramName,'Wrong program returned!');
    }
}