@isTest
public class CC_Test_ApplicationSummary {

    static testmethod void testLoadAndSaveData(){
        User userServiceIntake = fetchUser(System.label.CC_Self_Service_Intake_Profile,true);
    
        User userAppintake = fetchUser(System.label.CC_App_Intake_Profile,true);

        User userCaseManager = fetchUser(System.label.CC_Case_Manager_Profile,true);
       
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
            objContact.OtherStreet = '1st Cross;;Street';
            objContact.OtherCity = 'Bangalore';
            objContact.CC_Physical_Address_State__c = 'Other';
            objContact.OtherPostalCode = '123456';
            objContact.MailingStreet = '1st Cross Street';
            objContact.MailingCity = 'Bangalore';
            objContact.CC_Mailing_Address_State__c = 'Other';
            objContact.MailingPostalCode = '123456';

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

            objApp.CC_Hard_copy_Signature_received__c = true;
            objApp.CC_Applying_on_behalf_of_applicant__c = true;
            objApp.CC_Information_is_correct__c = true;

            update objApp;

            SaveWrapper objWrp = new SaveWrapper();
            objWrp.sAppId = objApp.id;
            objWrp.bIntakeOnBehalfApplicant= true;
            objWrp.bCorrectInfo = true;
            objWrp.bSignatureReceived = true;

            DT_Rule__c rule = new DT_Rule__c();
            rule.Name = 'Test Rule 1';
            rule.DT_Target_SObject_API_Name__c = 'CC_Application__c';
            rule.DT_Rule_Type__c = 'Task';
            rule.DT_Priority__c = 'Normal';
            rule.DT_Module__c = 'Application Submitted';
            rule.DT_Task_Name__c = 'Test Task';

            insert rule;

            System.assertEquals(rule.id != NULL , true);

            Group TestQueue = CC_TestDataFactory.createQueue();

            DT_Rule_Version__c ruleVer = new DT_Rule_Version__c();
            ruleVer.DT_Rule__c = rule.id;
            ruleVer.DT_Assignment_Type__c = 'Queue';
            ruleVer.DT_Queue_Name__c = TestQueue.developerName;
            ruleVer.DT_Version_Number__c = 1;

            insert ruleVer;
            System.assertEquals(ruleVer.id != NULL , true);

            DT_Rule_Criterion__c ruleCrit1 = new DT_Rule_Criterion__c();
            ruleCrit1.DT_Rule_Version__c = ruleVer.id;
            ruleCrit1.recordTypeId = CC_Utility.getRecordTypeId('DT_Rule_Criterion__c','Compare Field Value');
            ruleCrit1.DT_Source_SObject_Field__c = 'CC_Hard_copy_Signature_received__c';
            ruleCrit1.DT_Source_SObject_Field_Type__c = 'BOOLEAN';
            ruleCrit1.DT_Value_To_Compare__c = 'true';
            ruleCrit1.DT_Operator__c = 'Equals To';

            insert ruleCrit1;
            System.assertEquals(ruleCrit1.id != NULL , true);

            DT_Rule_Criterion__c ruleCrit2 = new DT_Rule_Criterion__c();
            ruleCrit2.DT_Rule_Version__c = ruleVer.id;
            ruleCrit2.recordTypeId = CC_Utility.getRecordTypeId('DT_Rule_Criterion__c','Compare Field Value');
            ruleCrit2.DT_Source_SObject_Field__c = 'CC_Information_is_correct__c';
            ruleCrit2.DT_Source_SObject_Field_Type__c = 'BOOLEAN';
            ruleCrit2.DT_Value_To_Compare__c = 'true';
            ruleCrit2.DT_Operator__c = 'Equals To';

            insert ruleCrit2;

            System.assertEquals(ruleCrit2.id != NULL , true);

            rule.DT_IsActive__c = true;

            update rule;
            
            ruleVer.DT_Criteria_Logic__c = '(1 AND 2)';
            ruleVer.DT_IsActive__c = true;
            //ruleVer.DT_Previous_Task_Rule__c = rule.id;

            update ruleVer;
        
            Test.startTest();
			
        	objContact.ownerId = userAppintake.id;
            update objContact;
        
            System.runAs(userAppintake){
            String strLoadData = CC_ApplicationSummaryController.loadSummaryData(objApp.id);
            String strResponse = CC_ApplicationSummaryController.saveSummaryData(JSON.serialize(objWrp));
            String response = CC_ApplicationSummaryController.submitApplication(objApp.Id, objContact.Id, false, 'task1');
            System.assertEquals(response, 'Task Created Successfully');
            }

            objContact.ownerId = userServiceIntake.id;
            update objContact;

            System.runAs(userServiceIntake){
            String strLoadData = CC_ApplicationSummaryController.loadSummaryData(objApp.id);
            String strResponse = CC_ApplicationSummaryController.saveSummaryData(JSON.serialize(objWrp));
            String response = CC_ApplicationSummaryController.submitApplication(objApp.Id, objContact.Id, false, 'task1');
            System.assertEquals(response, 'Task Created Successfully');
            }

            objContact.ownerId = userCaseManager.id;
            update objContact;

            System.runAs(userCaseManager){  
            String strLoadData = CC_ApplicationSummaryController.loadSummaryData(objApp.id);
            String strResponse = CC_ApplicationSummaryController.saveSummaryData(JSON.serialize(objWrp));
            String response = CC_ApplicationSummaryController.submitApplication(objApp.Id, objContact.Id, false, 'task1');
            System.assertEquals(response, 'Task Created Successfully');
            }

            Test.stopTest();
    }  

    private static User fetchUser(String sProfileName, Boolean bIsActive){

        User userObj = [SELECT Id FROM User where Profile.Name =: sProfileName AND IsActive =: bIsActive LIMIT 1];
        return userObj;
    }  
    
     public class SaveWrapper{
        Boolean bIntakeOnBehalfApplicant;
        Boolean bCorrectInfo;
        Boolean bSignatureReceived;
        String sAppId;

    }
}