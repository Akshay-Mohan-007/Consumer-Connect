/***************************************************************************************************************************************
 * NAME   : CC_ApplicationSummaryController
 * DESCRIPTION  : to send and receive data from CC_AppicationSummary component 
 *    
 * @AUTHOR   : Sourav Ghosh
 * @DATE   : 11-15-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Sourav Ghosh				11-15-2017			Initial version 
 * Nidhin     				13-Dec-2017			Changed method structure of task f/w      
 *
 ****************************************************************************************************************************************/

public without sharing class CC_ApplicationSummaryController {

    /**************
    @Method Name = loadSummaryData;
    @Purpose = To send data to Application summary component during page load
    @Parameters = Application id
    @return = JSON String containing Contact, Application and List of Application Detail.
    **************/
    @auraEnabled
    public static string loadSummaryData(String appId){
        
        String sServiceData, sLivingSituationData, sResidentAddress, sMailingAddress, sName, sRepName, sLegName, sRIData ;
        Contact objRepContact, objLegContact;
        Contact objCon = new Contact();
        CC_Application__c objApp = new CC_Application__c();
        List<CC_Application_Detail__c> lstAppDet = new List<CC_Application_Detail__c>();

        try{
            if(appId != NULL && appId != ''){
                List<CC_Application__c> lstApp = new List<CC_Application__c>();
                lstApp = [Select Id,CC_Individual__c,CC_Individual__r.FirstName, CC_Individual__r.LastName,CC_Individual__r.CC_Middle_Initial__c,
                            CC_Applying_on_behalf_of_applicant__c,  CC_Hard_copy_Signature_received__c, CC_Information_is_correct__c,
                            CC_Where_does_the_individual_live__c, CC_Is_Living_Situation_Working__c,Visited_Pages__c,CC_App_Status__c,
                            CC_Does_Individual_have_Auth_Rep__c,CC_individual_have_LegalGuardian__c,CC_Individual_Also_Your_Legal_Guardian__c,
                            CC_Individual__r.Formatted_Mailing_Address__c,CC_Individual__r.Formatted_Physical_Address__c,
                            CC_How_soon_services_needed__c,CC_Describe_why_services_are_needed__c,CC_On_Any_Waiver_Waiting_List__c,
                            CC_Individual__r.CC_Suffix__c,CC_Individual__r.Phone,CC_Individual__r.OtherPhone,CC_Individual__r.Name,
                            CC_Individual__r.OtherStreet,CC_Individual__r.OtherCity,CC_Individual__r.CC_Physical_Address_State__c,
                            CC_Individual__r.CC_Contact_County__c,CC_Individual__r.OtherPostalCode,CC_Individual__r.MailingStreet,
                            CC_Individual__r.MailingCity,CC_Individual__r.CC_Mailing_Address_State__c,CC_Individual__r.CC_Mailing_Address_County__c,
                            CC_Individual__r.MailingPostalCode,CC_Individual__r.CC_Same_as_physical_address__c 
                            from CC_Application__c where Id =: appId LIMIT 1];
                
                if(lstApp.size() > 0){
                Id contactId= lstApp[0].CC_Individual__c;
                objApp = lstApp[0];

                objCon.Id = lstApp[0].CC_Individual__c;
                objCon.FirstName = (lstApp[0].CC_Individual__r.FirstName != '') ? lstApp[0].CC_Individual__r.FirstName : '';
                objCon.LastName = (lstApp[0].CC_Individual__r.LastName != '') ? lstApp[0].CC_Individual__r.LastName : '';
                objCon.CC_Suffix__c = (lstApp[0].CC_Individual__r.CC_Suffix__c != '') ? lstApp[0].CC_Individual__r.CC_Suffix__c : '';
                objCon.CC_Middle_Initial__c = (lstApp[0].CC_Individual__r.CC_Middle_Initial__c != '') ? lstApp[0].CC_Individual__r.CC_Middle_Initial__c : '';
                objCon.Phone = (lstApp[0].CC_Individual__r.Phone != '') ? lstApp[0].CC_Individual__r.Phone : '';
                objCon.OtherPhone = (lstApp[0].CC_Individual__r.OtherPhone != '') ? lstApp[0].CC_Individual__r.OtherPhone : '';
                objCon.OtherStreet = (lstApp[0].CC_Individual__r.OtherStreet != '') ? lstApp[0].CC_Individual__r.OtherStreet : '';
                objCon.OtherCity = (lstApp[0].CC_Individual__r.OtherCity != '') ? lstApp[0].CC_Individual__r.OtherCity : '';
                objCon.OtherPostalCode = (lstApp[0].CC_Individual__r.OtherPostalCode != '') ? lstApp[0].CC_Individual__r.OtherPostalCode : '';
                objCon.CC_Physical_Address_State__c = (lstApp[0].CC_Individual__r.CC_Physical_Address_State__c != '') ? lstApp[0].CC_Individual__r.CC_Physical_Address_State__c : '';
                objCon.CC_Contact_County__c = (lstApp[0].CC_Individual__r.CC_Contact_County__c != '') ? lstApp[0].CC_Individual__r.CC_Contact_County__c : '';
                objCon.MailingStreet = (lstApp[0].CC_Individual__r.MailingStreet != '') ? lstApp[0].CC_Individual__r.MailingStreet : '';
                objCon.MailingCity = (lstApp[0].CC_Individual__r.MailingCity != '') ? lstApp[0].CC_Individual__r.MailingCity : '';
                objCon.CC_Mailing_Address_State__c = (lstApp[0].CC_Individual__r.CC_Mailing_Address_State__c != '') ? lstApp[0].CC_Individual__r.CC_Mailing_Address_State__c : '';
                objCon.CC_Mailing_Address_County__c = (lstApp[0].CC_Individual__r.CC_Mailing_Address_County__c != '') ? lstApp[0].CC_Individual__r.CC_Mailing_Address_County__c : '';
                objCon.MailingPostalCode = (lstApp[0].CC_Individual__r.MailingPostalCode != '') ? lstApp[0].CC_Individual__r.MailingPostalCode : '';
                
                //sResidentAddress = lstApp[0].CC_Individual__r.Formatted_Physical_Address__c.replace(',,',',');
                //sMailingAddress = lstApp[0].CC_Individual__r.Formatted_Mailing_Address__c.replace(',,',',');                    
                    
                sResidentAddress = generateAddress(lstApp[0].CC_Individual__r.OtherStreet,lstApp[0].CC_Individual__r.OtherCity,
                                                lstApp[0].CC_Individual__r.CC_Physical_Address_State__c,lstApp[0].CC_Individual__r.OtherPostalCode);
                
                sMailingAddress = generateAddress(lstApp[0].CC_Individual__r.MailingStreet,lstApp[0].CC_Individual__r.MailingCity,
                                                lstApp[0].CC_Individual__r.CC_Mailing_Address_State__c,lstApp[0].CC_Individual__r.MailingPostalCode); 

                String sMiddleName = (lstApp[0].CC_Individual__r.CC_Middle_Initial__c != '') ? lstApp[0].CC_Individual__r.CC_Middle_Initial__c : '';
                if(sMiddleName != NULL && sMiddleName != '')
                    sName = lstApp[0].CC_Individual__r.FirstName+ ' '+sMiddleName+ ' '+lstApp[0].CC_Individual__r.LastName;
                else    
                    sName = lstApp[0].CC_Individual__r.FirstName+ ' ' +lstApp[0].CC_Individual__r.LastName;
                }
                
                Id AppDetServiceRecordType = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ,
                                                                             CC_Constants.CC_APP_DETAIL_SERVICE_RECTYPE);
                lstAppDet = [Select Id,Currently_Getting_Program_Name__c,Getting_the_Service__c,Other_Program_Name__c,
                              Other_Service_Name__c,Service_Needed__c,Service__r.Name from CC_Application_Detail__c where 
                              Related_Application__c =: appId AND RecordTypeId =:AppDetServiceRecordType];

                sServiceData = CC_ServicesController.getPageDataForApplication(appId);
                sLivingSituationData = CC_LivingSituationController.getPageData(appId);
                sRIData = CC_Representative_InformationController.loadContactData(appId);
                
                String sRepContact = '{"'+sRIData.subString(sRIData.IndexOf('repconObj'),sRIData.IndexOf('legconObj'))+'}';
                String sLegContact = '{"'+sRIData.subString(sRIData.IndexOf('legconObj'),sRIData.IndexOf('appInf'))+'}';

                objRepContact = (Contact)JSON.deserialize(sRepContact,Contact.class);
                objLegContact = (Contact)JSON.deserialize(sLegContact,Contact.class);

                /******
                List<Contact> lstRepresentativeContacts = CC_Representative_InformationController.getRepresentativeandLegGuardianContact(appId);

                if(lstRepresentativeContacts.size() > 0){
                   for(Contact objContact : lstRepresentativeContacts){
                        if(objContact.CC_Contact_Type__c.contains('Representative'))
                            objRepContact = objContact;
                        else if(objContact.CC_Contact_Type__c.contains('Legal Guardian'))
                            objLegContact = objContact;
                   }
                }
                ******/

                if(objRepContact != NULL && objRepContact.CC_Middle_Initial__c != NULL && objRepContact.CC_Middle_Initial__c != '')
                    sRepName = objRepContact.FirstName+ ' '+objRepContact.CC_Middle_Initial__c+ ' '+ objRepContact.LastName;
                else if(objRepContact != NULL)   
                    sRepName = objRepContact.FirstName+ ' ' +objRepContact.LastName;
                

                if(objLegContact != NULL && objLegContact.CC_Middle_Initial__c != NULL && objLegContact.CC_Middle_Initial__c != '')
                    sLegName = objLegContact.FirstName+ ' '+objLegContact.CC_Middle_Initial__c+ ' '+ objLegContact.LastName;
                else if(objLegContact != NULL)   
                    sLegName = objLegContact.FirstName+ ' ' +objLegContact.LastName;
                
        }
    }
    catch(Exception e){
        System.debug('Exception on Class : CC_ApplicationSummary - loadSummaryData, Error : ' +
            e.getMessage() +
            ' Line Number : ' +
            e.getLineNumber() +
            ' Cause : ' +
            e.getCause() +
            ' Type : ' +
            e.getTypeName());
        throw e;
        }


        return '{"ObjContact" :'+ JSON.serialize(objCon)+
                 ',"ObjRepContact" :'+ JSON.serialize(objRepContact)+
                 ',"ObjLegContact" :'+ JSON.serialize(objLegContact)+
                 ',"ObjApplication" :'+ JSON.serialize(objApp)+
                 ',"LstAppDetails" :'+ JSON.serialize(lstAppDet)+
                 ',"ContactName" :'+ JSON.serialize(sName)+
                 ',"RepContactName" :'+ JSON.serialize(sRepName)+
                 ',"LegalContactName" :'+ JSON.serialize(sLegName)+
            	 ',"ResidentAddress" :'+ JSON.serialize(sResidentAddress)+
            	 ',"MailingAddress" :'+ JSON.serialize(sMailingAddress)+
                 ',"lstDocs" :'+ JSON.serialize(CC_FileUpload_Controller.loadDocuments(appId,'Application__c'))+
                 ',"MapLabels" :'+ JSON.serialize(loadLabels())+
                 ',"ServiceWrapper" :'+ sServiceData +
                 ',"LivingSituationWrapper" :'+ sLivingSituationData + 
                 ',"pickListWrapper" :'+JSON.serialize(CC_Utility.getPicklistValuesWrapper(CC_Constants.CC_CONTACT_OBJ,
                                                CC_Constants.CC_CONTACT_SUFFIX, System.Label.CC_Select_Suffix)) +'}';
    }

    /**************
    @Method Name = saveSummaryData;
    @Purpose = To save data send by Application summary component
    @Parameters = String JSON containing application fields value
    @return = String containing SUCCESS or ERROR msg
    **************/
    @auraEnabled
    public static String saveSummaryData(String sJSON){
        SaveWrapper objWrp = (SaveWrapper)JSON.deserialize(sJSON, SaveWrapper.class);
        String retStr;
        try{
            CC_Application__c objApp = new CC_Application__c();
            objApp.Id = Id.valueOf(objWrp.sAppId);
            objApp.CC_Applying_on_behalf_of_applicant__c = objWrp.bIntakeOnBehalfApplicant;
            objApp.CC_Information_is_correct__c = objWrp.bCorrectInfo;
            objApp.CC_Hard_copy_Signature_received__c = objWrp.bSignatureReceived;

            if(objApp.Id != NULL){
                UPDATE objApp;
                retStr = 'SUCCESS';
            }
        }
        catch(Exception e){
            retStr = 'ERROR';
            System.debug('Exception on Class : CC_ApplicationSummary - saveData, Error : ' +
            e.getMessage() +
            ' Line Number : ' +
            e.getLineNumber() +
            ' Cause : ' +
            e.getCause() +
            ' Type : ' +
            e.getTypeName());
            throw e;
        }
        return retStr;
    }

    /**************
    @Method Name = submitApplication;
    @Purpose = To submit the application
    @Parameters = application id,contact id
    @return = void
    **************/
    @auraEnabled
    public static String submitApplication(String sAppId, String sConId, boolean bIsAlreadySubmitted, String sTaskToClose){
        CC_Application__c objApp = new CC_Application__c();
        objApp.Id = Id.valueOf(sAppId);
        if(!bIsAlreadySubmitted)
            objApp.CC_App_Status__c = 'Submitted';
        else
            objApp.CC_App_Status__c = 'Resubmitted';       
        objApp.Submitted_Date__c = System.now();
        objApp.CC_Applying_on_behalf_of_applicant__c = true;
        objApp.CC_Information_is_correct__c= true;
        objApp.CC_Hard_copy_Signature_received__c = true;

        update objApp;
        
        //Map<String,String> mapOwners = new Map<String,String>();
        Map<String,String> mapTask = new Map<String,String>();

        mapTask.put('DT_Master_Record_Id__c',sAppId);
        mapTask.put('Application__c',Id.valueOf(sAppId));
        mapTask.put('Contact__c',Id.valueOf(sConId));

        DT_TaskResponseWrapper objTaskWrapper = DT_TaskAssignment.executeTaskRules(sAppId,
                                            mapTask,sTaskToClose);
        
        if(objTaskWrapper.success)
            return 'Task Created Successfully';
        else 
            return 'Task is not created :(....';

    }


    private static string generateAddress(String sStreet, String sCity, String sState, String sZip ){
        String sAddress = sStreet+','+sCity+','+sState+','+sZip;

        if((sAddress != '' && sAddress != NULL) && sAddress.contains(';;')){
            String sUpdatedAdd1 = sAddress.replace(';;',',');
            String sUpdatedAdd2 = sUpdatedAdd1.replace(',,',',');
            sAddress = sUpdatedAdd2;
        }
        return sAddress;
    }

    @TestVisible
    private static Map<String,String> loadLabels() {

        Map<String,String> mapLabels = new Map<String,String>();
        mapLabels.put('CC_Label_Same_as_above',System.Label.CC_Label_Same_as_above);
        mapLabels.put('CC_Label_Name',System.Label.CC_Label_Name);
        mapLabels.put('CC_CONTACT_INFO_MAIN_PHN',System.Label.CC_CONTACT_INFO_MAIN_PHN);
        mapLabels.put('CC_CONTACT_INFO_OTHER_PHN',System.Label.CC_CONTACT_INFO_OTHER_PHN);
        mapLabels.put('CC_Label_Resident_Address',System.Label.CC_Label_Resident_Address);
        mapLabels.put('CC_Mailing_Address',System.Label.CC_Mailing_Address);
        mapLabels.put('CC_INDIVIDUAL_INFORMATION',System.Label.CC_INDIVIDUAL_INFORMATION);
        mapLabels.put('CC_OTHER_QUESTIONS',System.Label.CC_OTHER_QUESTIONS);
        mapLabels.put('CC_Label_Hard_Signature_Received',System.Label.CC_Label_Hard_Signature_Received);
        mapLabels.put('CC_Label_Header_Other_Question',System.Label.CC_Label_Header_Other_Question);
        mapLabels.put('CC_Label_Behalf_of_Applicant',System.Label.CC_Label_Behalf_of_Applicant);
        mapLabels.put('CC_Label_Correct_Information',System.Label.CC_Label_Correct_Information);
        mapLabels.put('CC_LBL_FirstName',System.Label.CC_LBL_FirstName);
        mapLabels.put('CC_LBL_Middle_Initial',System.Label.CC_LBL_Middle_Initial);
        mapLabels.put('CC_LBL_LastName',System.Label.CC_LBL_LastName);
        mapLabels.put('CC_LBL_Suffix',System.Label.CC_LBL_Suffix);
        mapLabels.put('CC_Contact_SaveButton',System.Label.CC_Contact_SaveButton);          
        mapLabels.put('CC_Contact_SubmitButton',System.Label.CC_Contact_SubmitButton);
        mapLabels.put('CC_Err_First_Name_Mandatory',System.Label.CC_Err_First_Name_Mandatory);
        mapLabels.put('CC_Err_Middle_Name_Not_Matching',System.Label.CC_Err_Middle_Name_Not_Matching);
        mapLabels.put('CC_Err_Last_Name_Mandatory',System.Label.CC_Err_Last_Name_Mandatory);
        mapLabels.put('CC_Err_Suffix_Not_Matching',System.Label.CC_Err_Suffix_Not_Matching);
        mapLabels.put('CC_Err_confirm_Applying_onBehalf_Applicant',System.Label.CC_Err_confirm_Applying_onBehalf_Applicant);
        mapLabels.put('CC_Err_confirm_Signature_received',System.Label.CC_Err_confirm_Signature_received);
        mapLabels.put('CC_Label_Services',System.Label.CC_Label_Services);
        mapLabels.put('CC_Label_Getting_Service',System.Label.CC_Label_Getting_Service);
        mapLabels.put('CC_Label_Service_Needed',System.Label.CC_Label_Service_Needed);
        mapLabels.put('CC_LBL_Program_Name',System.Label.CC_LBL_Program_Name);
        mapLabels.put('CC_LS_Is_the_living_situation_working',System.Label.CC_LS_Is_the_living_situation_working);
        mapLabels.put('CC_LS_Where_do_you_live',System.Label.CC_LS_Where_do_you_live);
        mapLabels.put('CC_How_soon_are_the_services_needed',System.Label.CC_How_soon_are_the_services_needed);
        mapLabels.put('CC_Service_WhyServiceNeeded',System.Label.CC_Service_WhyServiceNeeded);
        mapLabels.put('CC_Label_LivingSituation',System.Label.CC_Label_LivingSituation);
        mapLabels.put('CC_Are_you_currently_on_waiting_list',System.Label.CC_Are_you_currently_on_waiting_list);
        mapLabels.put('CC_Err_confirm_correct_information',System.Label.CC_Err_confirm_correct_information);
        mapLabels.put('CC_Err_First_Name_Not_Matching',System.Label.CC_Err_First_Name_Not_Matching);
        mapLabels.put('CC_Err_Last_Name_Not_Matching',System.Label.CC_Err_Last_Name_Not_Matching);
        mapLabels.put('CC_Contact_OtherInformation',System.Label.CC_Contact_OtherInformation);
        mapLabels.put('CC_Err_All_pages_are_not_saved',System.Label.CC_Err_All_pages_are_not_saved);
        mapLabels.put('CC_APPSUMMARY_HEADING',System.Label.CC_APPSUMMARY_HEADING);
        mapLabels.put('CC_Label_Physical_Address',System.Label.CC_Label_Physical_Address);
        mapLabels.put('CC_Label_CurrentLiving',System.Label.CC_Label_CurrentLiving);
        mapLabels.put('CC_Label_IsCurrentLivingWorking',System.Label.CC_Label_IsCurrentLivingWorking);
        mapLabels.put('CC_Label_Representative_Info',System.Label.CC_Label_Representative_Info);
        mapLabels.put('CC_Label_Authorized_Rep',System.Label.CC_Label_Authorized_Rep);
        mapLabels.put('CC_Label_Legal_Gurdian',System.Label.CC_Label_Legal_Gurdian);
        mapLabels.put('CC_Label_Document_Type',System.Label.CC_Label_Document_Type);
        mapLabels.put('CC_Label_Date',System.Label.CC_Label_Date);
        mapLabels.put('CC_Label_Comments',System.Label.CC_Label_Comments);
        mapLabels.put('CC_Label_Status',System.Label.CC_Label_Status);
        mapLabels.put('CC_Label_Review_Comments',System.Label.CC_Label_Review_Comments);
        mapLabels.put('CC_Label_What_Is_Needed',System.Label.CC_Label_What_Is_Needed);
        mapLabels.put('CC_Label_Type_of_Document_Accepted',System.Label.CC_Label_Type_of_Document_Accepted);
        mapLabels.put('CC_Label_Save',System.Label.CC_Label_Save);
        mapLabels.put('CC_Confirm_Header',System.Label.CC_Confirm_Header);
        mapLabels.put('CC_Document_Not_Uploaded_Warning',System.Label.CC_Document_Not_Uploaded_Warning);
        mapLabels.put('CC_Confirm_No',System.Label.CC_Confirm_No);
        mapLabels.put('CC_Confirm_Yes',System.Label.CC_Confirm_Yes);
        mapLabels.put('CC_Label_Cancel',System.Label.CC_Label_Cancel);
        mapLabels.put('CC_Confirm_Delete',System.Label.CC_Confirm_Delete);
        mapLabels.put('CC_Document_Delete_Warning',System.Label.CC_Document_Delete_Warning);
        mapLabels.put('CC_Document_Upload_Header',System.Label.CC_Document_Upload_Header);
        mapLabels.put('CC_Error_Document_Missing',System.Label.CC_Error_Document_Missing);
        mapLabels.put('CC_Document_Not_Uploaded',System.Label.CC_Document_Not_Uploaded);
        mapLabels.put('CC_Documents_Not_Required',System.Label.CC_Documents_Not_Required);
        mapLabels.put('CC_Label_LivingSituation',System.Label.CC_Label_LivingSituation);
        mapLabels.put('CC_Label_Uploaded_Docs',System.Label.CC_Label_Uploaded_Docs);
        mapLabels.put('NA','N/A');
        mapLabels.put('CC_Label_E_Sign',System.Label.CC_Label_E_Sign);
        
        return mapLabels;
    }

    public class SaveWrapper{
        Boolean bIntakeOnBehalfApplicant;
        Boolean bCorrectInfo;
        Boolean bSignatureReceived;
        String sAppId;
    }

    public class RiWrapper{
        Contact objRepCon;
        Contact objLegCon;
        CC_Application__c objAppInf;
        String sPickListJSON;
        Map<String,String> maploadLabels;
    }
}