@isTest
public class CC_Test_Representative_InfoController {
    
    @testSetup static void setupData() {
    }
       
   static testMethod void loadAndSaveAppData1() {

		User userServiceIntake = [SELECT Id FROM User where Profile.Name =: 
								  System.label.CC_Self_Service_Intake_Profile AND IsActive = TRUE LIMIT 1];
		User userAppintake = [SELECT Id FROM User where Profile.Name =: 
								System.label.CC_App_Intake_Profile AND IsActive = TRUE LIMIT 1];
		
            
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
            objContact.OwnerId=userServiceIntake.Id;
			insert objContact;
            
            Contact repobjContact = new Contact();
			repobjContact.Birthdate =  Date.newInstance(1999, 10 , 21);
			repobjContact.FirstName = 'TestFirstName1'.toUpperCase();
			repobjContact.LastName = 'TestLastName1'.toUpperCase();
			repobjContact.CC_Gender__c = 'Male';
			repobjContact.CC_Suffix__c = 'II';
			repobjContact.CC_SSN__c = '888888888';
            repobjContact.CC_Contact_Type__c=System.Label.CC_RT_Representative;
            repobjContact.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Representative);
			repobjContact.CC_Physical_Address_State__c = 'Other';
			repobjContact.CC_Mailing_Address_State__c = 'Other';
			repobjContact.CC_Contact_County__c = 'Other';
			repobjContact.CC_Mailing_Address_County__c = 'Other';
            repobjContact.OwnerId=System.Label.CC_Portal_Master_ID;
			insert repobjContact;
            
            Contact legobjContact = new Contact();
			legobjContact.Birthdate =  Date.newInstance(1999, 10 , 21);
			legobjContact.FirstName = 'TestFirstName1'.toUpperCase();
			legobjContact.LastName = 'TestLastName1'.toUpperCase();
			legobjContact.CC_Gender__c = 'Male';
            legobjContact.CC_Contact_Type__c=System.Label.CC_RT_Legal_Guardian;
            legobjContact.CC_Suffix__c = 'II';
			legobjContact.CC_SSN__c = '888888888';
			legobjContact.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Representative);
			legobjContact.CC_Physical_Address_State__c = 'Other';
			legobjContact.CC_Mailing_Address_State__c = 'Other';
			legobjContact.CC_Contact_County__c = 'Other';
			legobjContact.CC_Mailing_Address_County__c = 'Other';
            legobjContact.OwnerId=System.Label.CC_Portal_Master_ID;
			insert legobjContact;
            
            CC_Application__c objApp = new CC_Application__c();
			objApp.CC_Does_Individual_have_Auth_Rep__c = true;
			objApp.CC_individual_have_LegalGuardian__c = true;
			objApp.CC_Individual_Also_Your_Legal_Guardian__c=false;
			objApp.CC_You_Your_Guardian_LiveAt_Same_Place__c=true;
            objApp.CC_You_Your_Rep_LiveAt_Same_Place__c=true;
            objApp.CC_Individual__c=objContact.Id;
			insert objApp;
            
            String srepobjContact = JSON.serialize(repobjContact);
            String slegobjContact = JSON.serialize(legobjContact);
            String sobjApp = JSON.serialize(objApp);
            
            Test.startTest();
            
            System.runAs(userServiceIntake){
	            map<String,String> mapLabels = CC_Representative_InformationController.loadLabels();
				String strLoadData = CC_Representative_InformationController.loadContactData(objApp.id);
				String saveResult=CC_Representative_InformationController.doSave(srepobjContact,slegobjContact,sobjApp);
				
			}
           System.runAs(userAppintake){
	            map<String,String> mapLabels = CC_Representative_InformationController.loadLabels();
				String strLoadData = CC_Representative_InformationController.loadContactData(objApp.id);
				String saveResult=CC_Representative_InformationController.doSave(srepobjContact,slegobjContact,sobjApp);
            }		
			
            Test.stopTest();
            
    } 
    static testMethod void loadAndSaveAppData2() {

		
		User userAppintake = [SELECT Id FROM User where Profile.Name =: 
								System.label.CC_App_Intake_Profile AND IsActive = TRUE LIMIT 1];
		User userCaseManager = [SELECT Id FROM User where Profile.Name =: 
								System.label.CC_Case_Manager_Profile AND IsActive = TRUE LIMIT 1];
            
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
            objContact.OwnerId=userCaseManager.Id;
			insert objContact;
            
            Contact repobjContact = new Contact();
			repobjContact.Birthdate =  Date.newInstance(1999, 10 , 21);
			repobjContact.FirstName = 'TestFirstName1'.toUpperCase();
			repobjContact.LastName = 'TestLastName1'.toUpperCase();
			repobjContact.CC_Gender__c = 'Male';
			repobjContact.CC_Suffix__c = 'II';
			repobjContact.CC_SSN__c = '888888888';
            repobjContact.CC_Contact_Type__c=System.Label.CC_RT_Representative;
            repobjContact.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Representative);
			repobjContact.CC_Physical_Address_State__c = 'Other';
			repobjContact.CC_Mailing_Address_State__c = 'Other';
			repobjContact.CC_Contact_County__c = 'Other';
			repobjContact.CC_Mailing_Address_County__c = 'Other';
			insert repobjContact;
            
            Contact legobjContact = new Contact();
			legobjContact.Birthdate =  Date.newInstance(1999, 10 , 21);
			legobjContact.FirstName = 'TestFirstName1'.toUpperCase();
			legobjContact.LastName = 'TestLastName1'.toUpperCase();
			legobjContact.CC_Gender__c = 'Male';
            legobjContact.CC_Contact_Type__c=System.Label.CC_RT_Legal_Guardian;
            legobjContact.CC_Suffix__c = 'II';
			legobjContact.CC_SSN__c = '888888888';
			legobjContact.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Representative);
			legobjContact.CC_Physical_Address_State__c = 'Other';
			legobjContact.CC_Mailing_Address_State__c = 'Other';
			legobjContact.CC_Contact_County__c = 'Other';
			legobjContact.CC_Mailing_Address_County__c = 'Other';
			insert legobjContact;
            
            CC_Application__c objApp = new CC_Application__c();
			objApp.CC_Does_Individual_have_Auth_Rep__c = true;
			objApp.CC_individual_have_LegalGuardian__c = true;
			objApp.CC_Individual_Also_Your_Legal_Guardian__c=false;
			objApp.CC_You_Your_Guardian_LiveAt_Same_Place__c=false;
            objApp.CC_You_Your_Rep_LiveAt_Same_Place__c=false;
            objApp.CC_Individual__c=objContact.Id;
			insert objApp;
            
            String srepobjContact = JSON.serialize(repobjContact);
            String slegobjContact = JSON.serialize(legobjContact);
            String sobjApp = JSON.serialize(objApp);
            
            Test.startTest();
            
          
        System.runAs(userAppintake){
	            map<String,String> mapLabels = CC_Representative_InformationController.loadLabels();
				String strLoadData = CC_Representative_InformationController.loadContactData(objApp.id);
				String saveResult=CC_Representative_InformationController.doSave(srepobjContact,slegobjContact,sobjApp);
            }		
			System.runAs(userCaseManager){
	            map<String,String> mapLabels = CC_Representative_InformationController.loadLabels();
				String strLoadData = CC_Representative_InformationController.loadContactData(objApp.id);
				String saveResult=CC_Representative_InformationController.doSave(srepobjContact,slegobjContact,sobjApp);
            }
            Test.stopTest();
            
    } 
    
}