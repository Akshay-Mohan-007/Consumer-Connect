/***************************************************************************************************************************************
 * NAME         : CC_IndividualInfoPopoverController
 * DESCRIPTION  : for  component  
 *    
 * @AUTHOR   : Debalina
 * @DATE     : 11-17-2017    
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Debalina               11-17-2017         Initial version        
 *
 ****************************************************************************************************************************************/


public without sharing class CC_IndividualInfoPopoverController {

    @AuraEnabled
    public static String getInfoData(String sAppId) {
        
        String sIndvRecTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Individual);
        List<CC_Application__c> lstAppl = [SELECT Id, 
                                           		    Name, 
                                                  CC_App_Status__c, 
                                                  CC_Case__c, 
                                                  CC_Individual__r.Id,
                                                  CC_Individual__r.FirstName, 
                                                  CC_Individual__r.LastName, 
                                                  CC_Individual__r.CC_Suffix__c,
                                                  CC_Individual__r.CC_Middle_Initial__c, 
                                                  CC_Individual__r.Birthdate, 
                                                  CC_Individual__r.CC_SSN__c ,
                                                  CC_Individual__r.CC_Gender__c ,
                                                  CC_Individual__r.Age__c
                                           FROM CC_Application__c 
                                           WHERE CC_Individual__r.RecordTypeId =: sIndvRecTypeId 
                                           AND Id =: sAppId LIMIT 1];
        
        CC_Application__c objApp = new CC_Application__c();
        if(lstAppl.size() == 1){
			      objApp = lstAppl[0];
            objApp.CC_App_Status__c = String.isNotBlank(objApp.CC_App_Status__c)? objApp.CC_App_Status__c : '';
            objApp.CC_Case__c = String.isNotBlank(objApp.CC_Case__c)? objApp.CC_Case__c : null;
            objApp.CC_Individual__r.CC_Suffix__c = String.isNotBlank(objApp.CC_Individual__r.CC_Suffix__c)? 
                				objApp.CC_Individual__r.CC_Suffix__c : '';
 			      objApp.CC_Individual__r.CC_Middle_Initial__c = String.isNotBlank(objApp.CC_Individual__r.CC_Middle_Initial__c)? 
                										   objApp.CC_Individual__r.CC_Middle_Initial__c : '';
            objApp.CC_Individual__r.CC_SSN__c = String.isNotBlank(objApp.CC_Individual__r.CC_SSN__c)? 
                										   objApp.CC_Individual__r.CC_SSN__c : '';

        }

        Map<String,String> mapLabelAndError = loadLabelAndError();
        return '{"Application":'+JSON.serialize(objApp)
                +',"MapLabelError":'+JSON.serialize(mapLabelAndError)
                +'}';	
    }

    @TestVisible
    private static Map<String,String> loadLabelAndError() {
      Map<String,String> mapLabelAndError = new Map<String, String>();
     
      mapLabelAndError.put('CC_LBL_DOB',System.label.CC_LBL_DOB);
      mapLabelAndError.put('CC_LBL_Gender',System.label.CC_LBL_Gender);
      mapLabelAndError.put('CC_Label_Close',System.label.CC_Label_Close);

      mapLabelAndError.put('CC_LBL_Status',System.label.CC_LBL_Status);
      mapLabelAndError.put('CC_LBL_Application',System.label.CC_LBL_Application);
      mapLabelAndError.put('CC_LBL_AGE',System.label.CC_LBL_AGE);
      mapLabelAndError.put('CC_Label_EnrolledProgram',System.label.CC_Label_EnrolledProgram);
      mapLabelAndError.put('CC_Label_Case',System.label.CC_Label_Case);
      mapLabelAndError.put('CC_Label_LocEndDate',System.label.CC_Label_LocEndDate);
      mapLabelAndError.put('CC_Label_CaseManager',System.label.CC_Label_CaseManager);
      mapLabelAndError.put('CC_Label_CaseSupervisor',System.label.CC_Label_CaseSupervisor);
      mapLabelAndError.put('CC_Label_CaseManagementAgency',System.label.CC_Label_CaseManagementAgency);
      mapLabelAndError.put('CC_Label_CaseManagerContact',System.label.CC_Label_CaseManagerContact);
      mapLabelAndError.put('CC_Label_ProgramSelected',System.label.CC_Label_ProgramSelected);
      mapLabelAndError.put('CC_IndividualInformation',System.label.CC_IndividualInformation);
      mapLabelAndError.put('CC_CaseMangementInformation',System.label.CC_CaseMangementInformation);
      mapLabelAndError.put('CC_SelectedPrograms',System.label.CC_SelectedPrograms);
      mapLabelAndError.put('CC_ProgramName',System.label.CC_ProgramName);

      return mapLabelAndError;
    }
}