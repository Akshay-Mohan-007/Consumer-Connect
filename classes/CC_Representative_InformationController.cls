/***************************************************************************************************************************************
* NAME   : CC_Representative_InformationController
* DESCRIPTION  : for CC_ReresentativeInformationController 
*    
* @AUTHOR   : Akash Kumar
* @DATE   : 11-10-2017
*
* MODIFICATION LOG:  
* --------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                DATE                DESCRIPTION 
* --------------------------------------------------------------------------------------------------------------------------------------
* Akash                11-10-2017            Initial version        
*
****************************************************************************************************************************************/


public class CC_Representative_InformationController {
    
    @auraEnabled
    public static String loadContactData(String strAppId)
    {  
        system.debug('Application Id Is:' +strAppId); 
        
        Contact repCon,legCon;
        CC_Application__c appInf;
        Map<String,String> loadLabels = new Map<String,String>();
        String picklistJSON = '';
        appInf=[Select Id,CC_Does_Individual_have_Auth_Rep__c,CC_individual_have_LegalGuardian__c,CC_Individual_Also_Your_Legal_Guardian__c,
                CC_You_Your_Guardian_LiveAt_Same_Place__c,CC_You_Your_Rep_LiveAt_Same_Place__c,CC_Individual__r.Id,CC_Individual__r.AccountId,CC_Individual__r.OtherCity,
                CC_Individual__r.OtherPostalCode,CC_Individual__r.OtherStreet,CC_Individual__r.CC_Physical_Address_State__c,CC_Individual__r.CC_Zip4__c,CC_Individual__r.CC_Contact_County__c, CC_Individual__r.CC_Other_Physical_Address_County__c,
                CC_Individual__r.MailingStreet,CC_Individual__r.CC_Mailing_Address_County__c, CC_Individual__r.MailingCity,CC_Individual__r.CC_Mailing_Address_State__c,CC_Individual__r.MailingPostalCode,CC_Individual__r.CC_Zip4mailing__c,
                CC_Individual__r.CC_Other_Mailing_Address_County__c,Visited_Pages__c,
                (Select CC_Same_as_physical_address__c,Phone,Email,FirstName,CC_Middle_Initial__c,CC_Suffix__c,LastName,
                Formatted_Physical_Address__c,Formatted_Mailing_Address__c,CC_Other_Mailing_Address_County__c,CC_Other_Physical_Address_County__c,
                CC_Person_Related_To_Individual__c,Birthdate,OtherPhone,CC_Main_Phone_Type__c,CC_Contact_Type__c,CC_Preferred_Language__c,
                CC_Other_Phone_Type__c,OtherStreet,OtherCity,CC_Physical_Address_State__c,OtherPostalCode,CC_Zip4__c,CC_Mailing_Address_County__c,
                MailingStreet,MailingCity,CC_Mailing_Address_State__c,MailingPostalCode,CC_Zip4mailing__c,CC_Contact_County__c from Contacts__r) 
                from CC_Application__c where id=:strAppId];
        
        System.debug('appInf: '+ appInf);
        List<Contact> masterContact=getRepresentativeandLegGuardianContact(appInf);
        repCon = masterContact[0];
        legCon = masterContact[1];
        
        System.debug('repCon-->' +repCon);
        System.debug('legCon-->' +legCon);
        System.debug('appInf-->' +appInf);
        loadLabels = loadLabels();    
        picklistJSON =  getPicklistFields();
        
        return '{"phonePickList":'+picklistJSON 
            +',"mapUiLabels":'+JSON.serialize(loadLabels)
            +',"repconObj":'+JSON.serialize(repCon)
            +',"legconObj":'+JSON.serialize(legCon)
            +',"appInf":'+JSON.serialize(appInf)+'}';
    }
    
    public static List<Contact> getRepresentativeandLegGuardianContact(CC_Application__c appInf){
        
        List<Contact> lstCon=new List<Contact>();
        Contact repCon,LegCon;
       
        repCon=new Contact (CC_Same_as_physical_address__c=false,Phone='',Email='',FirstName='',CC_Middle_Initial__c='',CC_Suffix__c=null, LastName='',
                            CC_Person_Related_To_Individual__c=null,Birthdate=System.today(),OtherPhone='',CC_Main_Phone_Type__c=null,CC_Other_Physical_Address_County__c='',CC_Other_Mailing_Address_County__c='',
                            CC_Other_Phone_Type__c=null,OtherStreet='',OtherCity='',CC_Physical_Address_State__c=null,OtherPostalCode='',CC_Zip4__c='',CC_Mailing_Address_County__c=null,
                            MailingStreet='',MailingCity='',CC_Mailing_Address_State__c=null,MailingPostalCode='',CC_Zip4mailing__c='',CC_Preferred_Language__c=null, CC_Contact_County__c=null);
        
        
        legCon=new Contact (CC_Same_as_physical_address__c=false,Phone='',Email='',FirstName='',CC_Middle_Initial__c='',CC_Suffix__c=null, LastName='',
                            CC_Person_Related_To_Individual__c=null,Birthdate=System.today(),OtherPhone='',CC_Main_Phone_Type__c=null,
                            CC_Other_Phone_Type__c=null,OtherStreet='',OtherCity='',CC_Physical_Address_State__c=null,OtherPostalCode='',CC_Zip4__c='',CC_Mailing_Address_County__c=null,
                            MailingStreet='',MailingCity='',CC_Mailing_Address_State__c=null,MailingPostalCode='',CC_Zip4mailing__c='',CC_Preferred_Language__c=null, CC_Contact_County__c=null);
        
        for(Contact con:appInf.Contacts__r){
            if(con.CC_Contact_Type__c.contains(System.Label.CC_Contact_Type_Representative)){
                repCon=con;
                System.debug('Rep found');
            }
            if(con.CC_Contact_Type__c.contains(System.Label.CC_Contact_Type_Legal_Guardian) && !appInf.CC_Individual_Also_Your_Legal_Guardian__c){
                legCon=con;   
                System.debug('Leg found');
            }
        }
        
        
        lstCon.add(repCon);
        lstCon.add(legCon);
        return lstCon;
        
    }
    
    
    @TestVisible
    private static String getPicklistFields(){
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
                                                                                      System.Label.CC_Select_State)) 
            +',"lstPreferredLanguage" : '+JSON.serialize(CC_Utility.getPicklistValuesWrapper(mapContactSchema,CC_Constants.CC_CONTACT_PREFERRED_LANG,
                                                                                             System.Label.CC_LBL_SELECT))
            +',"lstSuffix" : '+JSON.serialize(CC_Utility.getPicklistValuesWrapper(mapContactSchema,CC_Constants.CC_CONTACT_SUFFIX,
                                                                                  System.Label.CC_Select_Suffix)) 
            +',"lstRltntype" : '+JSON.serialize(CC_Utility.getPicklistValuesWrapper(mapContactSchema, CC_Constants.CC_INDIVIDUAL_RELATED_TO_REPRESENTATIVE, 
                                                                                    System.Label.CC_LBL_SELECT_RELATION))+'}';
        
        
    }
    
    
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
        mapLabels.put('CC_Select_Preferred_Language',System.Label.CC_Select_Preferred_Language);
        mapLabels.put('CC_Other_Written_Language',System.Label.CC_Other_Written_Language);
        mapLabels.put('CC_LBL_FirstName',System.label.CC_LBL_FirstName);
        mapLabels.put('CC_CONTACT_INFO_PREFERRED_LANG',System.label.CC_CONTACT_INFO_PREFERRED_LANG);
        mapLabels.put('CC_LBL_SELECT_RELATION',System.label.CC_LBL_SELECT_RELATION);
        mapLabels.put('CC_LBL_Middle_Initial',System.label.CC_LBL_Middle_Initial);
        mapLabels.put('CC_LBL_LastName',System.label.CC_LBL_LastName);
        mapLabels.put('CC_LBL_Suffix',System.label.CC_LBL_Suffix);
        mapLabels.put('CC_LBL_DOB',System.label.CC_LBL_DOB);
        mapLabels.put('CC_LBL_Gender',System.label.CC_LBL_Gender);
        mapLabels.put('CC_LBL_SSN',System.label.CC_LBL_SSN); 
        mapLabels.put('CC_LBL_Confirm_SSN',System.label.CC_LBL_Confirm_SSN); 
        mapLabels.put('CC_LBL_SELECT',System.label.CC_LBL_SELECT);
        mapLabels.put('CC_You_Your_Rep_LiveAt_Same_Place',System.Label.CC_You_Your_Rep_LiveAt_Same_Place);
        mapLabels.put('CC_You_Your_Guardian_LiveAt_Same_Place',System.Label.CC_You_Your_Guardian_LiveAt_Same_Place);
        mapLabels.put('CC_Authorized_Representative_Information',System.Label.CC_Authorized_Representative_Information);
        mapLabels.put('CC_Representative_Contact_Information',System.Label.CC_Representative_Contact_Information);
        mapLabels.put('CC_Legal_Guardian_Information',System.Label.CC_Legal_Guardian_Information);
        mapLabels.put('CC_Legal_Guardian_Contact_Information',System.Label.CC_Legal_Guardian_Contact_Information);
        mapLabels.put('CC_Does_Individual_have_Auth_Rep',System.Label.CC_Does_Individual_have_Auth_Rep);
        mapLabels.put('CC_individual_have_LegalGuardian',System.Label.CC_individual_have_LegalGuardian);
        mapLabels.put('CC_How_Auth_Rep_Related_To_Individual',System.Label.CC_How_Auth_Rep_Related_To_Individual);
        mapLabels.put('CC_Physical_Address_Line1',System.Label.CC_Physical_Address_Line1);
        mapLabels.put('CC_Physical_Address_Line2',System.Label.CC_Physical_Address_Line2);
        mapLabels.put('CC_PERSON_ALSO_LEGAL_GUARDIAN_OF_INDIVIDUAL',System.Label.CC_PERSON_ALSO_LEGAL_GUARDIAN_OF_INDIVIDUAL);
        mapLabels.put('CC_Other_Preferred_Language',System.Label.CC_Other_Preferred_Language);
        mapLabels.put('CC_Auth_Rep_Some1_Whom_Ind_Can_Name_To_Help',System.Label.CC_Auth_Rep_Some1_Whom_Ind_Can_Name_To_Help);
        mapLabels.put('CC_Legal_Guardian_Court_Appointed_Adult',System.Label.CC_Legal_Guardian_Court_Appointed_Adult);
        mapLabels.put('CC_Guardian_Appointed_By_State',System.Label.CC_Guardian_Appointed_By_State);
        mapLabels.put('CC_LBL_YES',System.Label.CC_LBL_YES);
        mapLabels.put('CC_LBL_NO',System.Label.CC_LBL_NO);
        mapLabels.put('CC_Err_DOB_Future_Date',System.Label.CC_Err_DOB_Future_Date);
        mapLabels.put('CC_Err_DOB_Required',System.Label.CC_Err_DOB_Required);
        mapLabels.put('CC_Err_PreferredLangShdNotBlank',System.Label.CC_Err_PreferredLangShdNotBlank);
        mapLabels.put('CC_Error_Please_Select_Ind_Have_Auth_Rep',System.Label.CC_Error_Please_Select_Ind_Have_Auth_Rep);
        mapLabels.put('CC_Label_Phone_no',System.Label.CC_Label_Phone_no);
        mapLabels.put('CC_LBL_REPRESENTATIVE_INFORMATION',System.Label.CC_LBL_REPRESENTATIVE_INFORMATION);
        mapLabels.put('CC_Error_Person_Related_To_Ind_Cannot_Blank',System.Label.CC_Error_Person_Related_To_Ind_Cannot_Blank);
        mapLabels.put('CC_Error_Phone_Ext_Format',System.Label.CC_Error_Phone_Ext_Format);
        mapLabels.put('CC_LBL_YES',System.Label.CC_LBL_YES);
        mapLabels.put('CC_LBL_NO',System.Label.CC_LBL_NO);
        mapLabels.put('CC_LABEL_OTHERCOUNTY',System.Label.CC_LABEL_OTHERCOUNTY);
        mapLabels.put('CC_Err_DOB_Format',System.Label.CC_Err_DOB_Format);
        
        
        return mapLabels;
    }
    
    @auraEnabled
    public static String doSave(String sRepContact,String sLegContact,String sAppObj){
        System.debug('sRepContact-->' +sRepContact);
        System.debug('sLegContact-->' +sLegContact);
        System.debug('sAppObj-->' +sAppObj);
        
        Contact repContact=(Contact)JSON.deserialize(sRepContact, Contact.class);
        Contact legContact=(Contact)JSON.deserialize(sLegContact, Contact.class);
        CC_Application__c appObj=(CC_Application__c)JSON.deserialize(sAppObj,CC_Application__c.class);
        
        System.debug('repContact-->' +repContact);
        System.debug('legContact-->' +legContact);
        System.debug('appObj-->' +appObj);
        
        List<Contact> lstupdate=new List<Contact>(),lstinsert=new List<Contact>();
        List<Contact> listdeleterepcon=new List<Contact>();
        String retString;
        
        appObj.Visited_Pages__c = CC_Utility.setTabName(System.label.CC_LBL_REPRESENTATIVE_INFORMATION,appObj.Visited_Pages__c);
        update appObj;
        
        repContact.OwnerId=System.Label.CC_Portal_Master_ID;
        if(appObj.CC_Does_Individual_have_Auth_Rep__c){
            if(appObj.CC_You_Your_Rep_LiveAt_Same_Place__c){
                System.debug('rep same address');
                cloneAddress(repContact,appObj);
            }
            else{
                System.debug('rep diff address');
            } 
            
            repContact.Parent_Application__c=appObj.Id;
            repContact.CC_Contact_Type__c=System.Label.CC_RT_Representative;
            repContact.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Representative);
            repContact.AccountId=appObj.CC_Individual__r.AccountId;
            
            
            if(appObj.CC_Does_Individual_have_Auth_Rep__c && appObj.CC_Individual_Also_Your_Legal_Guardian__c){
                System.debug('rep & lg same');
                repContact.CC_Contact_Type__c=System.Label.CC_RT_RepLeg_Info;
            }
            if(String.isBlank(repContact.Id))
                lstInsert.add(repContact);
            else
                lstUpdate.add(repContact);
            
            System.debug('rep con upserting');
        }
        else{
            if(!string.isBlank(repContact.Id)){
                listdeleterepcon.add(repContact);
                System.debug('rep con deleting');
            }
            
        }
        
        legContact.OwnerId=System.Label.CC_Portal_Master_ID;
        if(appObj.CC_individual_have_LegalGuardian__c && !appObj.CC_Individual_Also_Your_Legal_Guardian__c){
            if(appObj.CC_You_Your_Guardian_LiveAt_Same_Place__c){
                System.debug('LG same address');
                cloneAddress(legContact,appObj);
            }
            else{
                System.debug('LG diff address');
            }
            
            legContact.CC_Contact_Type__c=System.Label.CC_RT_Legal_Guardian;
            legContact.Parent_Application__c=appObj.Id;
            legContact.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ, System.label.CC_RT_Representative);
            legContact.AccountId=appObj.CC_Individual__r.AccountId;
            
            if(String.isBlank(legContact.Id))
                lstInsert.add(legContact);
            else
                lstUpdate.add(legContact);
            System.debug('leg con upserting');
        }else{
            if(!string.isBlank(legContact.Id)){
                listdeleterepcon.add(legContact);
                System.debug('leg con deleting');
            }
            
        } 
        System.debug('lstInsert: ' +lstInsert);
        if(!lstInsert.isEmpty()){
            CC_Utility.insertRecords(lstInsert);
        }
        System.debug('lstUpdate: ' +lstUpdate);
        if(!lstUpdate.isEmpty()){
            CC_Utility.updateRecords(lstUpdate);
        }
        System.debug('listdeleterepcon: ' +listdeleterepcon);
        if(!listdeleterepcon.isEmpty()){
            CC_Utility.deleteRecords(listdeleterepcon);
        }
        retString=loadContactData(appObj.Id);
        return retString;
        
    }
    
    private static Contact cloneAddress(Contact repContact,CC_Application__c appObj) {
        
        System.debug('Passed obj' +appObj);
        
        repContact.OtherStreet=appObj.CC_Individual__r.OtherStreet;
        repContact.OtherCity=appObj.CC_Individual__r.OtherCity;
        repContact.CC_Physical_Address_State__c=appObj.CC_Individual__r.CC_Physical_Address_State__c;
        repContact.OtherPostalCode=appObj.CC_Individual__r.OtherPostalCode;
        repContact.CC_Zip4__c=appObj.CC_Individual__r.CC_Zip4__c;
        repContact.CC_Contact_County__c=appObj.CC_Individual__r.CC_Contact_County__c;
        repContact.CC_Other_Physical_Address_County__c=appObj.CC_Individual__r.CC_Other_Physical_Address_County__c;
        repContact.MailingStreet=appObj.CC_Individual__r.MailingStreet;
        repContact.MailingCity=appObj.CC_Individual__r.MailingCity;
        repContact.CC_Mailing_Address_State__c=appObj.CC_Individual__r.CC_Mailing_Address_State__c;
        repContact.MailingPostalCode=appObj.CC_Individual__r.MailingPostalCode;
        repContact.CC_Zip4mailing__c=appObj.CC_Individual__r.CC_Zip4mailing__c;
        repContact.CC_Mailing_Address_County__c=appObj.CC_Individual__r.CC_Mailing_Address_County__c;
        repContact.CC_Other_Mailing_Address_County__c=appObj.CC_Individual__r.CC_Other_Mailing_Address_County__c;
        
        System.debug('Address Contact--->' +repContact);
        
        return repContact;
        
    }
    @AuraEnabled
    public static String getDependentOptions(string sObjName, string sControllingField, string sDependentField) {
        Map <String, List<CC_PickListValue_Wrapper>> mapCounty = CC_Utility.getDependentPicklistValues(sObjName, sControllingField,sDependentField,System.Label.CC_LABEL_SELECT_COUNTY);
        String sJSON = JSON.serialize(mapCounty);
        System.debug('sJSON :'+sJSON);
        return sJSON;
    }
    
}