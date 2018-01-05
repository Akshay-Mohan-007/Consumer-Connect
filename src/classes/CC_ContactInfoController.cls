/***************************************************************************************************************************************
 * NAME   : CC_ContactInfoCOntroller
 * DESCRIPTION  : for CC_ContactInfoCOntroller  
 *    
 * @AUTHOR   : Sourav Ghosh
 * @DATE   : 11-02-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Sourav Ghosh               11-02-2017            Initial version  
 * Sourav Ghosh               12-08-2017            Modification for Code Review comments    
 *
 ****************************************************************************************************************************************/

public without sharing class CC_ContactInfoController { 

    /**************
    @Method Name = doSave;
    @Purpose = To save data send by CC_ContactInformation component
    @Parameters = Contact JSON String and Application Id
    @return = Void
    **************/
    @auraEnabled
    public static void doSave(String sContact, String sAppId){
    try{
         Contact objContact = (Contact)JSON.deserialize(sContact, Contact.class);
         String sVisitedPages = [Select Visited_Pages__c from CC_Application__c where Id =:sAppId].Visited_Pages__c;
                  
        CC_Application__c objApplication = new CC_Application__c();
        objApplication.Id = sAppId;
        objApplication.Visited_Pages__c = CC_Utility.setTabName(CC_Constants.CC_CONTACT_INFORMATION, sVisitedPages);

            UPDATE objContact;
            UPDATE objApplication;
        }
        catch(Exception e)
        {
            System.debug('Exception on Class : CC_ContactInfoController - doSave, Error : ' +
            e.getMessage() +
            ' Line Number : ' +
            e.getLineNumber() +
            ' Cause : ' +
            e.getCause() +
            ' Type : ' +
            e.getTypeName());
            throw e;
        }
    }
    
    /**************
    @Method Name = loadContactData;
    @Purpose = To send data to CC_ContactInformation component during page load
    @Parameters = Contact Id
    @return = JSON String containing Contact Object, Picklist values(metadata) and labels.
    **************/
    @auraEnabled
    public static String loadContactData(String strConId)
    {      
        try{
           list<Contact> lstCon = new list<Contact>();
           Map<String,String> loadLabels = new Map<String,String>();
           String picklistJSON = '';
        
               lstCon = [Select Id, Name, CC_Main_Phone_Type__c, Phone, CC_Other_Phone_Type__c, OtherPhone,
                          OtherStreet, OtherCity, CC_Physical_Address_State__c, CC_Contact_County__c, OtherPostalCode,
                          CC_Zip4__c, CC_Other_Physical_Address_County__c, MailingStreet, MailingCity,
                          CC_Mailing_Address_State__c, CC_Mailing_Address_County__c, MailingPostalCode, CC_Zip4mailing__c,
                          CC_Other_Mailing_Address_County__c, CC_Same_as_physical_address__c, Email, CC_Written_Language__c,
                          CC_Spoken_Language__c, CC_Other_Written_Language__c from Contact where Id =: strConId];
                
                
                loadLabels = loadLabels();    
                picklistJSON =  getPhonePicklistFields();

                if(!lstCon.isEmpty()){
                    return '{"phonePickList" : '+picklistJSON
                      +',"mapUiLabels" : '+JSON.serialize(loadLabels)
                      +',"conObj" : '+JSON.serialize(lstCon[0])
                      +'}';
                }
            else{
                    return '{"phonePickList":'+picklistJSON
                      +',"mapUiLabels":'+JSON.serialize(loadLabels)
                      +',"conObj":'+JSON.serialize('')
                      +'}';
                }
                            
        } 
        catch(Exception e)
        {
            System.debug('Exception on Class : CC_ContactInfoController - loadContactData, Error : ' +
            e.getMessage() +
            ' Line Number : ' +
            e.getLineNumber() +
            ' Cause : ' +
            e.getCause() +
            ' Type : ' +
            e.getTypeName());
            throw e;
        }
    }
    
   


    /**************
    @Method Name = getPhonePicklistFields;
    @Purpose = private method to fetch picklist values from CC_Utility Class
    @Parameters = 
    @return = JSON String containing All picklist values which are required.
    **************/

    @TestVisible
    private static String getPhonePicklistFields(){
        map<String, Schema.SObjectField> mapContactSchema = new map<String, Schema.SObjectField>();
         mapContactSchema = CC_Utility.getFieldMap(CC_Constants.CC_CONTACT_OBJ);

        return '{"lstMainPhoneTypes" : '+JSON.serialize(CC_Utility.getPicklistValuesWrapper(mapContactSchema, CC_Constants.CC_CONTACT_MAIN_PHN_TYPE, 
                                                                                            System.Label.CC_Select_Main_Phone_Type))
                +', "lstOtherPhoneTypes" : '+JSON.serialize(CC_Utility.getPicklistValuesWrapper(mapContactSchema, CC_Constants.CC_CONTACT_OTHER_PHN_TYPE, 
                                                                                            System.Label.CC_Select_Other_Phone_Type))
                +', "lstWrittenLangs" : '+JSON.serialize(CC_Utility.getPicklistValuesWrapper(mapContactSchema, CC_Constants.CC_CONTACT_WRITTEN_LANG, 
                                                                                            System.Label.CC_Select_Written_Language)) 
                +', "lstSpokenLangs" : '+JSON.serialize(CC_Utility.getPicklistValuesWrapper(mapContactSchema, CC_Constants.CC_CONTACT_SPOKEN_LANG, 
                                                                                            System.Label.CC_Select_Spoken_Language)) 
                +', "lstAddStates" : '+JSON.serialize(CC_Utility.getPicklistValuesWrapper(mapContactSchema, CC_Constants.CC_PHYSICAL_CONTACT_STATE, 
                                                                                            System.Label.CC_Select_State)) +'}';

    }

    /**************
    @Method Name = loadLabels;
    @Purpose = private method to return a map containing all custom labels
    @Parameters = 
    @return = Map<String,String>
    **************/
    @TestVisible
    private static Map<String,String> loadLabels() {
        Map<String,String> mapLabels = new Map<String,String>();
        mapLabels.put('CC_Phone_Type',System.Label.CC_Phone_Type);
        mapLabels.put('CC_Phone_Number',System.Label.CC_Phone_Number);
        mapLabels.put('CC_Phone_Confirmation',System.Label.CC_Phone_Confirmation);
        mapLabels.put('CC_Error_Phone_Type_Missing',System.Label.CC_Error_Phone_Type_Missing);
        mapLabels.put('CC_Error_Phone_No_Missing',System.Label.CC_Error_Phone_No_Missing);
        mapLabels.put('CC_Error_Phone_Confirm_Missing',System.Label.CC_Error_Phone_Confirm_Missing);
        mapLabels.put('CC_Error_Phone_Not_Matching',System.Label.CC_Error_Phone_Not_Matching);
        mapLabels.put('CC_ADDRESS_LINE_1',System.Label.CC_ADDRESS_LINE_1);
        mapLabels.put('CC_ADDRESS_LINE_2',System.Label.CC_ADDRESS_LINE_2);
        mapLabels.put('CC_MAILING_ADDRESS',System.Label.CC_MAILING_ADDRESS);
        mapLabels.put('CC_PHYSICAL_ADDRESS',System.Label.CC_PHYSICAL_ADDRESS);
        
        mapLabels.put('CC_CITY',System.Label.CC_CITY);
        mapLabels.put('CC_COUNTY',System.Label.CC_COUNTY);
        mapLabels.put('CC_STATE',System.Label.CC_STATE);
        mapLabels.put('CC_ZIP_4',System.Label.CC_ZIP_4);
        mapLabels.put('CC_ZIP_CODE',System.Label.CC_ZIP_CODE);
        mapLabels.put('CC_Err_Address_Format',System.Label.CC_Err_Address_Format);
        mapLabels.put('CC_Err_Cannot_Be_Blank',System.Label.CC_Err_Cannot_Be_Blank);
        mapLabels.put('CC_Err_City_Format',System.Label.CC_Err_City_Format);
        mapLabels.put('CC_Err_ZipCode_Format',System.Label.CC_Err_ZipCode_Format);
        mapLabels.put('CC_Err_ZipExt_Format',System.Label.CC_Err_ZipExt_Format);
        mapLabels.put('CC_Err_OtherCounty_Format',System.Label.CC_Err_OtherCounty_Format);
        mapLabels.put('CC_OTHER_COUNTY',System.Label.CC_OTHER_COUNTY);
        mapLabels.put('CC_Error_Phone_Format',System.Label.CC_Error_Phone_Format);
        mapLabels.put('CC_CONTACT_INFO_EMAIL',System.Label.CC_CONTACT_INFO_EMAIL);
        mapLabels.put('CC_CONTACT_INFO_SPOKEN_LANG',System.Label.CC_CONTACT_INFO_SPOKEN_LANG);
        mapLabels.put('CC_CONTACT_INFO_WRITTEN_LANG',System.Label.CC_CONTACT_INFO_WRITTEN_LANG);
        mapLabels.put('CC_SameAsPhyAddress',System.Label.CC_SameAsPhyAddress);
        mapLabels.put('CC_Contact_OtherInformation',System.Label.CC_Contact_OtherInformation);
        mapLabels.put('CC_Err_WrittenLangShdNotBlank',System.Label.CC_Err_WrittenLangShdNotBlank);
        mapLabels.put('CC_Err_EmailFormatIsNotCorrect',System.Label.CC_Err_EmailFormatIsNotCorrect);
        mapLabels.put('CC_Err_SpokenLangShdNotBlank',System.Label.CC_Err_SpokenLangShdNotBlank);
        mapLabels.put('CC_Contact_SaveButton',System.Label.CC_Contact_SaveButton);
        mapLabels.put('CC_Contact_PhoneInformation',System.Label.CC_Contact_PhoneInformation);
        mapLabels.put('CC_Phone_Extension',System.Label.CC_Phone_Extension);
        mapLabels.put('CC_Select_County',System.Label.CC_Select_County);
        mapLabels.put('CC_Select_State',System.Label.CC_Select_State);
        mapLabels.put('CC_Select_Written_Language',System.Label.CC_Select_Written_Language);
        mapLabels.put('CC_Select_Spoken_Language',System.Label.CC_Select_Spoken_Language);
        mapLabels.put('CC_Error_Phone_Not_Matching',System.Label.CC_Error_Phone_Not_Matching);
        mapLabels.put('CC_Error_Phone_Confirm_Missing',System.Label.CC_Error_Phone_Confirm_Missing);
        mapLabels.put('CC_Error_Phone_Ext_Missing',System.Label.CC_Error_Phone_Ext_Missing);
        mapLabels.put('CC_Error_Phone_Ext_Format',System.Label.CC_Error_Phone_Ext_Format);
        mapLabels.put('CC_Other_Written_Language',System.Label.CC_Other_Written_Language);
        mapLabels.put('CC_You_Your_Guardian_LiveAt_Same_Place',System.Label.CC_You_Your_Guardian_LiveAt_Same_Place);
        mapLabels.put('CC_You_Your_Rep_LiveAt_Same_Place',System.Label.CC_You_Your_Rep_LiveAt_Same_Place);
        mapLabels.put('CC_Label_Phone_no',System.Label.CC_Label_Phone_no);

        mapLabels.put('CC_Label_Contact_Info',System.Label.CC_Label_Contact_Info);
        mapLabels.put('CC_LABEL_OTHERCOUNTY',System.Label.CC_LABEL_OTHERCOUNTY);
        mapLabels.put('CC_Err_PreferredLangShdNotBlank',System.Label.CC_Err_PreferredLangShdNotBlank);
        


        return mapLabels;
    }

     /* METHOD NAME   : getDependentOptions 
     * DESCRIPTION  : get Queue Info using developer name
     *
     * RETURN TYPE   : JSON String
     * PARAMETER   : sObjName, sControllingField, sDependentField
     */

    @AuraEnabled
    public static String getDependentOptions(string sObjName, string sControllingField, string sDependentField) {
        try{
            Map <String, List< CC_PickListValue_Wrapper>> mapCounty = CC_Utility.getDependentPicklistValues(sObjName, sControllingField, sDependentField,System.Label.CC_LABEL_SELECT_COUNTY);
            String sJSON = JSON.serialize(mapCounty);
            System.debug('sJSON :'+sJSON);
            return sJSON;
        }
        catch(Exception e)
        {
            System.debug('Exception on Class : CC_ContactInfoController - getDependentOptions, Error : ' +
            e.getMessage() +
            ' Line Number : ' +
            e.getLineNumber() +
            ' Cause : ' +
            e.getCause() +
            ' Type : ' +
            e.getTypeName());
            throw e;
        }

    }
}