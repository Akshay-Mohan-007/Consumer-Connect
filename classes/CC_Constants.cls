/***************************************************************************************************************************************
 * NAME   : CC_Constants
 * DESCRIPTION  : All Constants.
 *    
 * @AUTHOR   : Nidhin V K
 * @DATE   : 10-27-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K				10-27-2017			Initial version        
 * Debalina                 11-08-2017    
 * Pankaj					11-11-2017      
 * Akshay                   13-Nov-2017         Added constants for Account ,sharing constants, profile names
 * Pankaj					20-Nov-2017
 * Nidhin					22-Nov-2017		
 * Debalina                 27-Nov-2017 	    Added constansts for comments
 * Akshay                   27-Nov-2017         Added constansts for N/A
 * Debalina                 30-Nov-2017         Added values.
 * Sourav                   11-12-2017          Added constants for Application Container Controller
 * Debalina                 12-Dec-2017         Added values.
 * Debalina                 14-Dec-2017         Added values.
 * Nidhin                 	15-Dec-2017         Added values.
 * Nidhin                 	18-Dec-2017         Removed values.
 * Debalina                 20-Dec-2017         Added values.
 * Debalina                 02-Jan-2018         Added values.
 * Debalina                 04-Jan-2018         Added values.
 ****************************************************************************************************************************************/

public with sharing class CC_Constants {

    //For Basic Information,Contact Information and Representative Information Components
    public static final String CC_CONTACT_OBJ = 'Contact';
    public static final String CC_DOCUMENT_DETAIL = 'CC_Document_Detail__c';
    public static final String CC_CONTACT_GENDER = 'CC_Gender__c';
    public static final String CC_CONTACT_SUFFIX = 'CC_Suffix__c';
    public static final String CC_EMPTY = '';
    public static final String CC_NONE = 'None';
    public static final String CC_DOC_DETAIL_STATUS = 'Status__c';
    public static final String CC_CONTACT_MAIN_PHN_TYPE = 'CC_Main_Phone_Type__c';
    public static final String CC_CONTACT_OTHER_PHN_TYPE = 'CC_Other_Phone_Type__c';
    public static final String CC_CONTACT_SPOKEN_LANG = 'CC_Spoken_Language__c';
    public static final String CC_CONTACT_WRITTEN_LANG = 'CC_Written_Language__c';
    public static final String CC_PHYSICAL_CONTACT_COUNTY='CC_Contact_County__c';
    public static final String CC_CONTACT_PREFERRED_LANG='CC_Preferred_Language__c';
    public static final String CC_MAILING_CONTACT_COUNTY='CC_Mailing_Address_County__c';
    public static final String CC_PHYSICAL_CONTACT_STATE='CC_Physical_Address_State__c';
    public static final String CC_MAILING_CONTACT_STATE='CC_Mailing_Address_State__c';
    public static final String CC_INDIVIDUAL_RELATED_TO_REPRESENTATIVE='CC_Person_Related_To_Individual__c';
    public static final String CC_CONTACT_INFORMATION='Contact Information';
    public static final String CC_CONTACT_REPRESENTATIVE='Representative';
    public static final String CC_CONTACT_LEGAL_GUARDIAN='Legal Guardian';
    

    //Start:Akshay[13-Nov-2017]: Adding Constants for record type
    public static final String CC_CONTACT_INDIVIDUAL_RECORD_TYPE = 'Individual';
    public static final String CC_CONTACT_EXTERNAL_RECORD_TYPE = 'External User';
    //End:Akshay[13-Nov-2017]: Adding Constants for record type

    //For Services Component
    public static final String CC_PROGRAM_SERVICE_OBJ = 'CC_Program_Service__c';
    public static final String CC_APP_DETAIL_OBJ = 'CC_Application_Detail__c';
    public static final String CC_RECORD_TYPE_WAIVER_PROGRAMS = 'Waiver Programs';
    public static final String CC_APPLICATION_OBJ = 'CC_Application__c';
    public static final String CC_APP_DETAIL_FLD_SERVICE_PERIOD = 'CC_How_soon_services_needed__c';
    public static final String CC_APP_REVIEWER_PROFILE = 'Application Reviewer Profile';
    

    //For Living Situation Component
    public static final String CC_APP_FLD_CURRENT_LIVING = 'CC_Where_does_the_individual_live__c';
    public static final String CC_APP_FLD_PREFERRED_LIVING = 'CC_Where_do_you_Prefer__c';
    public static final String CC_APP_DTL_STATUS_PENDING = 'Capacity Review Pending';
    
    //For Error Logging
    public static final String CC_ERROR_TYPE_BUSINESS_VALIDATION = 'Business Validation';
    public static final String CC_ERROR_TYPE_VF_CONTROLLER = 'VF Controller';
    public static final String CC_ERROR_TYPE_APEX_TRIGGER = 'Apex Trigger';

    //Start:Akshay[13-Nov-2017]: Adding Constants for changes in account
    public static final String CC_ACCOUNT_OBJ = 'Account';
    public static final String CC_ACCOUNT_INDIVIDUAL_RECORD_TYPE = 'Individual Account';
    //End:Akshay[13-Nov-2017]: Adding Constants for changes in account

    //Start:Akshay[13-Nov-2017]: Adding Constants for Case Manager & supervisor Profile Names
    public static final String CC_CASE_MANAGER_PROFILE = 'Case Manager Profile';
    public static final String CC_CASE_SUPERVISOR_PROFILE = 'Case Supervisor Profile';
    //End:Akshay[13-Nov-2017]: Adding Constants for Case Manager & supervisor Profile Names

    //Start:Akshay[13-Nov-2017]: Adding Constants for Sharing values
    public static final String CC_SHAE_ACCESS_EDIT = 'Edit';
    public static final String CC_SHAE_ACCESS_NONE = 'None';//Typo in var name
    //End:Akshay[13-Nov-2017]: Adding Constants for Sharing values  

    //For Application Summary
    public static final String CC_APP_DETAIL_SERVICE_RECTYPE = 'Service Type';
    
    //Start:Nidhin[22-Nov-2017]: For CC_Module_mdt Application record
    public static final String CC_MODULE_MDT_APPLICATION = 'Application_Intake';
    //For Date Formats
    public static final String CC_OUTPUT_DATE_FORMAT = 'MM/dd/yyyy';
    public static final String CC_OUTPUT_DATE_FORMAT_FOR_FEED = 'MM/dd/yyyy hh:mm:ss a'; 
    public static final String CC_ALL_OPTIONS = 'All Options';
    public static final String CC_OBJ_PROGRAM = 'CC_Program_Service__c';
    public static final String CC_RECORD_TYPE_PROGRAM = 'Program';
    //End:Nidhin[22-Nov-2017]: 


    //Start:Debalina[27-Nov-2017]: For CC_Module_mdt Application record
    public static final String CC_MODE_DRAFT = 'DRAFT';
    public static final String CC_MODE_SUBMITTED = 'SUBMITTED';
    //End:Debalina[27-Nov-2017]: 

    //Start:Akshay[27-Nov-2017]: Added constant for N/A
    public static final String CC_NO_DATA = 'N/A';
    //End:Akshay[27-Nov-2017]: Added constant for N/A


    //Debalina - 30th Nov,2017
    public static final String CC_APP_LOOKUP_FLD = 'Related_Application__c';
    public static final String CC_OTHER = 'Other';

    //Start: Sourav - 11th Dec 2017
    public static final String CC_DESKTOP_THEME_TYPE = 'Theme4d';
    public static final String CC_MOBILE_THEME_TYPE = 'Theme4t';
    //End: Sourav - 11th Dec 2017


    //Start : Debalina - 12th Dec,2017 for CC_UrgencyOfNeedController
     public static final String CC_FLD_REASON = 'Reason__c';

    //End : Debalina - 12th Dec,2017

    //Start : Debalina - 14th Dec,2017 for CC_UrgencyOfNeedController
    public static final String CC_MODULE_MDT_CAPACITY_REVIEW = 'Capacity_Review';

    //Start : Debalina - 15th Dec,2017 for Targeting
    public static final String CC_OUTPUT_DATE_FMT = 'MM/dd/yyyy';
    
    //Start : Akash - 18th Dec,2017 for Manage Allotment
    public static final String CC_WAIVER_CAPACITY_ACTIONS='Capacity_Review_Action__c';

    //Start : Debalina - 20th Dec,2017 for Targeting
    public static final String CC_TASK_STATUS_NEW = 'New';

    //Start : Debalina - 2nd Jan 2018 for Targeting
    public static final String CC_FLD_TIME_ZONE = 'Select_Time_Zone__c';
    public static final String CC_OUTPUT_TIME_FORMAT = 'hh:mm a';

    //Start : Debalina 4th Jan for Targeting
    public static final String CC_SUBMITTED = 'Submitted';
}