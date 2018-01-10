/***************************************************************************************************************************************
* NAME   : CC_ApplicationContainer_Controller
* DESCRIPTION  : Application Container Controller
*					Make sure that the home page urls in CC_Module__mdt is populated with 'Application' as record DeveloperName
*    
* @AUTHOR   : Akshay Mohan
* @DATE   : 21-06-2017
*
* MODIFICATION LOG:  
* --------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER				DATE				DESCRIPTION 
* --------------------------------------------------------------------------------------------------------------------------------------
* Akshay Mohan				21-06-2017			Initial version 
* Nidhin     				22-Nov-2017  		Added methods for Navigation      
* Debalina                  27-Nov-2017         Aaplication Status for comments
* Pankaj					27-Nov-2017			added param to loadData
* Akshay Mohan              30-06-2017          Added success message
* Pankaj Sharma				05-12-2017			changed the sharing of class from with to without
* Sourav Ghosh              11-12-2017          Added condition to load home page in responsive devices
* Sourav Ghosh              18-12-2017          Changed the code to get the homePageURL from CC_Utility
****************************************************************************************************************************************/

public without sharing class CC_ApplicationContainer_Controller {
    
    /* loadData 
* Gets the data required to load the File Upload Component
* 
* @return : a JSON of the page data
*/
    @AuraEnabled
    public static String loadData(String sAppId,String sModuleName) {
       
        CC_Module__mdt objModule = queryMetaData(sModuleName);
        
        String sHomePageURL = CC_Utility.getContainerSite(objModule);
        String sModule = objModule.DeveloperName;

        Map<String,String> mapLabels = new Map<String,String>();
        mapLabels.put('CC_Save_Exit',System.Label.CC_Save_Exit);
        mapLabels.put('CC_Contact_SubmitButton',System.Label.CC_Contact_SubmitButton);
        mapLabels.put('CC_Back_Button',System.Label.CC_Back_Button);
        mapLabels.put('CC_Next_Button',System.Label.CC_Next_Button);
        mapLabels.put('CC_Tab_Complete_Icon',System.Label.CC_Tab_Complete_Icon);
        mapLabels.put('CC_Tab_Incomplete_Icon',System.Label.CC_Tab_Incomplete_Icon);
        mapLabels.put('CC_Document_Upload_Header',System.Label.CC_Document_Upload_Header);
        mapLabels.put('CC_Document_Review_Header',System.Label.CC_Document_Review_Header);
        mapLabels.put('CC_Application_Intake_Page',System.Label.CC_Application_Intake_Page);
        mapLabels.put('CC_Application_Review',System.label.CC_Application_Review);
        mapLabels.put('CC_HOME_PAGE_URL',EncodingUtil.urlEncode(sHomePageURL, 'UTF-8'));
        mapLabels.put('CC_MODULE',objModule.DeveloperName);
        mapLabels.put('CC_Services',System.Label.CC_Services);
        mapLabels.put('CC_Living_Situation',System.Label.CC_Living_Situation);
        mapLabels.put('CC_Documents',System.Label.CC_Documents); 
        mapLabels.put('CC_Contact_Information',System.Label.CC_Contact_Information);
        mapLabels.put('CC_Representative_Information',System.Label.CC_Representative_Information);
        mapLabels.put('CC_Summary',System.Label.CC_Summary);
        mapLabels.put('CC_Waiver_Confirmation',System.Label.CC_Waiver_Confirmation);
        

        Boolean bShowCommentAndHistory;
        List<CC_Application__c> lstApp = [SELECT Id,Name,CC_App_Status__c FROM CC_Application__c 
                                          WHERE Id =:sAppId LIMIT 1];
        mapLabels.put('Submit_Success',System.Label.CC_Application_Submitted  +' '+ lstApp[0].Name); 

        bShowCommentAndHistory = ( (lstApp.size() == 1)
                                    && (lstApp[0].CC_App_Status__c == System.Label.CC_LBL_RevisionNeeded) )?
                                  true: false;

        return '{"mapLabels" : ' + JSON.serialize(mapLabels)
               +',"bShowCommentAndHistory" : '+ JSON.serialize(bShowCommentAndHistory) + '}';
        
    }

    @testVisible
    public static CC_Module__mdt queryMetaData(String sModuleName) {

        CC_Module__mdt objModule = new CC_Module__mdt();
        objModule = [SELECT 
                        DeveloperName,
                        Home_Page_Redirection_Internal_User__c,
                        Home_Page_Redirection_Self_Service_User__c,
                        Home_Page_Redirection_Svc_Provider_User__c,
                        Home_Page_Redirection_App_User__c,
                        Component_with_Comment__c
                        FROM 
                        CC_Module__mdt 
                        WHERE 
                        DeveloperName = :sModuleName LIMIT 1];

        return objModule;
    }

}