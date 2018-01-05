/***************************************************************************************************************************************
* NAME   : CC_CapacityReviewContainer_Controller
* DESCRIPTION  : Capacity Review Container Controller
*					
* @AUTHOR   : Sourav Ghosh
* @DATE   : 18-12-2017
*
* MODIFICATION LOG:  
* --------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER				DATE				DESCRIPTION 
* --------------------------------------------------------------------------------------------------------------------------------------
* Sourav Ghosh         18-12-2017           Initial Version
* Akshay Mohan         02-Jan-2018          Document Upload Header
****************************************************************************************************************************************/

public without sharing class CC_CapacityReviewContainer_Controller {
    
    /* loadData 
* Gets the data required to load the Capacity Review Container
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
        mapLabels.put('CC_Capacity_Review',System.label.CC_Capacity_Review);
        mapLabels.put('CC_HOME_PAGE_URL',EncodingUtil.urlEncode(sHomePageURL, 'UTF-8'));
        mapLabels.put('CC_MODULE',objModule.DeveloperName); 
        mapLabels.put('CC_Document_Review_Header',System.Label.CC_Document_Review_Header);
        mapLabels.put('CC_Services',System.Label.CC_Services);
        mapLabels.put('CC_Living_Situation',System.Label.CC_Living_Situation);
        mapLabels.put('CC_Documents',System.Label.CC_Documents);
        mapLabels.put('CC_Targeting_Criteria',System.Label.CC_Targeting_Criteria);
        mapLabels.put('CC_Urgency_of_Need',System.Label.CC_Urgency_of_Need);
        mapLabels.put('CC_Manage_Allotment',System.Label.CC_Manage_Allotment);
        mapLabels.put('CC_Label_TargetingCrit_Comment',System.Label.CC_Label_TargetingCrit_Comment);
        mapLabels.put('CC_LBL_Comment',System.Label.CC_LBL_Comment);
        
       /* Boolean bShowCommentAndHistory;
        List<CC_Application__c> lstApp = [SELECT Id,Name,CC_App_Status__c FROM CC_Application__c 
                                          WHERE Id =:sAppId LIMIT 1];
        mapLabels.put('Submit_Success',System.Label.CC_Application_Submitted  +' '+ lstApp[0].Name); 

        bShowCommentAndHistory = ( (lstApp.size() == 1)
                                    && (lstApp[0].CC_App_Status__c == System.Label.CC_LBL_RevisionNeeded) )?
                                  true: false;*/

        return '{"mapLabels" : ' + JSON.serialize(mapLabels)+'}';
        
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