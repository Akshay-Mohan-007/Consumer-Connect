/***************************************************************************************************************************************
 * NAME   : CC_Test_CapacityReviewContainer
 * DESCRIPTION  : For test coverage of CC_CapacityReviewContainer_Controller class
 *    
 * @AUTHOR   : Sourav Ghosh
 * @DATE   : 19-12-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Sourav Ghosh				19-12-2017			Initial Version
 ****************************************************************************************************************************************/
@isTest
public class CC_Test_CapacityReviewContainer {
 public static User userSelfServiceIntake,userAppintake,userCaseManager;
    
    public CC_Test_CapacityReviewContainer() {}
	static {
		userSelfServiceIntake = [SELECT Id FROM User where Profile.Name =: 
								  System.label.CC_Self_Service_Intake_Profile AND IsActive = TRUE LIMIT 1];
		userAppintake = [SELECT Id FROM User where Profile.Name =: 
								System.label.CC_App_Intake_Profile AND IsActive = TRUE LIMIT 1];
		userCaseManager = [SELECT Id FROM User where Profile.Name =: 
								System.label.CC_Case_Manager_Profile AND IsActive = TRUE LIMIT 1];
	}

	@isTest
    public static void loadContainerPage() {
        
    	Test.startTest();
        CC_Application__c objApp;
        String sModule = 'Capacity_Review';
        
        System.runAs(userSelfServiceIntake){
            System.debug('Site Name is : '+Site.getName());
            CC_Module__mdt objMetaData = CC_CapacityReviewContainer_Controller.queryMetaData(sModule);  
            objApp = CC_TestDataFactory.createApp();
        	String sJSON = CC_CapacityReviewContainer_Controller.loadData(objApp.Id,sModule);
        	System.debug('sJSON: ' + sJSON);
        	sJSON = sJSON.substring(sJSON.indexOf('{"mapLabels" : ')+'{"mapLabels" : '.length(),sJSON.lastIndexOf('}'));
        	System.debug('sJSON substring: ' + sJSON);
        	Map<String,String> mapLabels = (Map<String,String>)JSON.deserialize(sJSON, Map<String,String>.class);
        	System.assert(String.isNotBlank(mapLabels.get('CC_MODULE')),'Module name not loaded');
        }
       
        System.runAs(userAppintake){
            CC_Module__mdt objMetaData = CC_CapacityReviewContainer_Controller.queryMetaData(sModule); 
            //objApp = CC_TestDataFactory.createApp(); 
            String sJSON = CC_CapacityReviewContainer_Controller.loadData(objApp.Id,sModule);
            System.debug('sJSON: ' + sJSON);
            sJSON = sJSON.substring(sJSON.indexOf('{"mapLabels" : ')+'{"mapLabels" : '.length(),sJSON.lastIndexOf('}'));
            System.debug('sJSON substring: ' + sJSON);
            Map<String,String> mapLabels = (Map<String,String>)JSON.deserialize(sJSON, Map<String,String>.class);
            System.assert(String.isNotBlank(mapLabels.get('CC_MODULE')),'Module name not loaded');
        }
        
        /*objApp = CC_TestDataFactory.createApp();*/
        System.runAs(userCaseManager){
        
            CC_Module__mdt objMetaData = CC_CapacityReviewContainer_Controller.queryMetaData(sModule);  
            
            System.debug('objApp>>>'+objApp.Id);
      		String sJSON = CC_CapacityReviewContainer_Controller.loadData(objApp.Id,sModule);
        	System.debug('sJSON: ' + sJSON);
        	sJSON = sJSON.substring(sJSON.indexOf('{"mapLabels" : ')+'{"mapLabels" : '.length(),sJSON.lastIndexOf('}'));
        	System.debug('sJSON substring: ' + sJSON);
        	Map<String,String> mapLabels = (Map<String,String>)JSON.deserialize(sJSON, Map<String,String>.class);
        	System.assert(String.isNotBlank(mapLabels.get('CC_MODULE')),'Module name not loaded');
        }
        
        Test.stopTest();
        
    }
}