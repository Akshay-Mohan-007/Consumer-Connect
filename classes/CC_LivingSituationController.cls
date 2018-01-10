/***************************************************************************************************************************************
 * NAME         : CC_LivingSituationController
 * DESCRIPTION  : for CC_LivingSituation component  
 *    
 * @AUTHOR   : Debalina
 * @DATE     : 11-15-2017    
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Debalina               11-15-2017         Initial version        
 *
 ****************************************************************************************************************************************/

public without sharing class CC_LivingSituationController {


   	public class PicklistWrapper{
		List<CC_PickListValue_Wrapper> lstCurrentLivingSituation;
		List<CC_PickListValue_Wrapper> lstPreferToLive;

		public PicklistWrapper(){
			lstCurrentLivingSituation = new List<CC_PickListValue_Wrapper>();
			lstPreferToLive = new List<CC_PickListValue_Wrapper>();
		}
	}


	@AuraEnabled
    public static String getPageData(String sAppId) {

    	PicklistWrapper objPicklistWrapper = new PicklistWrapper();
    	Map<String, Schema.SObjectField> mapAppField = CC_Utility.getFieldMap(CC_Constants.CC_APPLICATION_OBJ);

    	List<String> lstValues = CC_Utility.getPicklistValuesFromFieldMap(mapAppField,
                                                      CC_Constants.CC_APP_FLD_CURRENT_LIVING);

    	for(String sVal: lstValues) {
    		objPicklistWrapper.lstCurrentLivingSituation.add(new CC_PickListValue_Wrapper(sVal));
    	}

        lstValues = CC_Utility.getPicklistValuesFromFieldMap(mapAppField,
                                             CC_Constants.CC_APP_FLD_PREFERRED_LIVING);

        for(String sVal: lstValues) {
    		objPicklistWrapper.lstPreferToLive.add(new CC_PickListValue_Wrapper(sVal));
    	}

    	Map<String,String> mapLabelAndError = loadLabelAndError();
    	CC_Application__c objAppl = getApplication(sAppId);
        String sCurrentProfile = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Profile.Name;

        return '{"PicklistWrapper":'+JSON.serialize(objPicklistWrapper)
        		+',"Application":'+JSON.serialize(objAppl)
        		+',"MapLabelError":'+JSON.serialize(mapLabelAndError)
               + ',"CurrentProfile":'+JSON.serialize(sCurrentProfile)+ '}'; 
    }


    public static CC_Application__c getApplication(String sAppId) {
    	CC_Application__c objApp = new CC_Application__c();

    	List<CC_Application__c> lstApp = [SELECT Id, 
    											 CC_Where_does_the_individual_live__c,
    											 CC_Is_Living_Situation_Working__c,
    											 CC_Where_do_you_Prefer__c,
    											 CC_Explain_living_situation__c,
    											 CC_Explain_Where_do_you_prefer__c,
                                                 Visited_Pages__c
    									  FROM CC_Application__c
    								      WHERE Id =: sAppId LIMIT 1];

    	if(lstApp.size() == 1) {
    		objApp = lstApp[0];
    		objApp.CC_Where_does_the_individual_live__c =  String.isNotBlank(objApp.CC_Where_does_the_individual_live__c)? 
    													   objApp.CC_Where_does_the_individual_live__c : '';
    	    objApp.CC_Is_Living_Situation_Working__c = Boolean.valueOf(objApp.CC_Is_Living_Situation_Working__c);
    	    objApp.CC_Where_do_you_Prefer__c = String.isNotBlank(objApp.CC_Where_do_you_Prefer__c)?
    	    								   objApp.CC_Where_do_you_Prefer__c : '';
    	    objApp.CC_Explain_living_situation__c = String.isNotBlank(objApp.CC_Explain_living_situation__c)?
    	    										objApp.CC_Explain_living_situation__c : '';
    	    objApp.CC_Explain_Where_do_you_prefer__c = String.isNotBlank(objApp.CC_Explain_Where_do_you_prefer__c)?
    	    										   objApp.CC_Explain_Where_do_you_prefer__c : '';										
    	}

    	return objApp;
    }


    @AuraEnabled
    public static String saveApplicationData(String sJSON) { 

    	String retString ='';
    	CC_Application__c objAppToUpdate = (CC_Application__c) JSON.deserialize(sJSON, CC_Application__c.class);   
        String sAppVisitedPages = [SELECT Id,Visited_Pages__c 
                                   FROM CC_Application__c WHERE Id =: objAppToUpdate.Id LIMIT 1].Visited_Pages__c;
        objAppToUpdate.Visited_Pages__c = CC_Utility.setTabName(System.label.CC_Label_LivingSituation, sAppVisitedPages);
        System.debug('objAppToUpdate:' +objAppToUpdate);
    	try{
    		update objAppToUpdate;
    		retString = 'Success';
        }
        catch(Exception ex){
            retString = 'Fail';
            System.debug('Exception on Class : CC_ServicesController - updateApplication, Error : ' +
            ex.getMessage() +
            ' Line Number : ' +
            ex.getLineNumber() +
            ' Cause : ' +
            ex.getCause() +
            ' Type : ' +
            ex.getTypeName());
        }
                                                         
        return retString;

    }


	@TestVisible
    private static Map<String,String> loadLabelAndError() {

        Map<String,String> mapLabelAndError = new Map<String, String>();
        mapLabelAndError.put('CC_LBL_OTHER',System.label.CC_LBL_OTHER);
        mapLabelAndError.put('CC_LBL_SELECT',System.label.CC_LBL_SELECT);
        mapLabelAndError.put('CC_Label_CurrentLiving',System.label.CC_Label_CurrentLiving);
        mapLabelAndError.put('CC_Label_CurrentLivingDescription',System.label.CC_Label_CurrentLivingDescription);
		mapLabelAndError.put('CC_Label_IsCurrentLivingWorking',System.label.CC_Label_IsCurrentLivingWorking);
		mapLabelAndError.put('CC_Label_PreferredLiving',System.label.CC_Label_PreferredLiving);
		mapLabelAndError.put('CC_Label_PreferredLivingDescription',System.label.CC_Label_PreferredLivingDescription);
		mapLabelAndError.put('CC_Label_LivingSituation',System.label.CC_Label_LivingSituation);
		mapLabelAndError.put('CC_Err_CurrentLiving',System.label.CC_Err_CurrentLiving);
		mapLabelAndError.put('CC_Err_Explain_CurrentLiving',System.label.CC_Err_Explain_CurrentLiving);
		mapLabelAndError.put('CC_Err_Mandatory',System.label.CC_Err_Mandatory);
        mapLabelAndError.put('CC_APP_REVIEWER_PROFILE',CC_Constants.CC_APP_REVIEWER_PROFILE);
		
		
        return mapLabelAndError;
    }

}