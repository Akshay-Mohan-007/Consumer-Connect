/***************************************************************************************************************************************
 * NAME         : CC_Services_Controller
 * DESCRIPTION  : for Services  
 *    
 * @AUTHOR   : Debalina
 * @DATE     : 11-7-2017    
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Debalina               11-7-2017         Initial version        
 * Debalina               11-23-2017        Partial Refresh Added
 ****************************************************************************************************************************************/

public without sharing class CC_ServicesController {

    private static final String sServiceTypeId;
    private static final String sWaitListTypeId;
    private static final String sProgramTypeId;
    private static final String sProgramServiceTypeId;
    

    static {
        sServiceTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, System.label.CC_RT_Service_Type);
        sWaitListTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, System.label.CC_RT_Waitlist_Type);
        sProgramTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_Program);
        sProgramServiceTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_Service);
    }

    public class ServiceInfo {
        public String sServiceId;
        public String sServiceName;
        public String sModifierCode;
        public String sParentProgramId;

        public ServiceInfo(String sServiceId, String sServiceName, String sModifierCode, String sParentProgramId) {
            this.sServiceId = sServiceId;
            this.sServiceName = sServiceName;
            this.sModifierCode = sModifierCode;
            this.sParentProgramId = sParentProgramId;
        }
    }

    public class PicklistWrapper {
        public List<String> lstHowSoonServicesNeeded;
        public Map<String,String> mapProgramNameId;
        public Map<String,List<ServiceInfo>> mapProgramService;

        public PicklistWrapper() {
            lstHowSoonServicesNeeded = new List<String>();
            mapProgramNameId = new Map<String,String>();
            mapProgramService = new Map<String,List<ServiceInfo>>();
        }

    }

    public class AppWrapper {
        List<ServiceWrapper> lstRelatedServiceDetail;
        List<CC_Application_Detail__c> lstRelatedWaitingProgram;
        String sHowSoonServiceNeeded;
        String sDescribeWhyServiceNeeded;
        Boolean isIndividualWaitinglist;
        String sId;

        public AppWrapper() {
            lstRelatedServiceDetail = new List<ServiceWrapper>();
            lstRelatedWaitingProgram = new List<CC_Application_Detail__c>();
        }
    }

    public class ServiceWrapper {
        String sCurrentlyGettingProgramName;
        String sOtherProgName;
        String sOtherServiceName;
        String sRelatedAppId;
        String sServiceId;
        String sServiceName;
        String sAppdetailId;
        Boolean bGettingCurrently;
        Boolean bNeededInFuture;

        public ServiceWrapper(){}

        public ServiceWrapper(CC_Application_Detail__c objAppDetail) {
            sCurrentlyGettingProgramName = objAppDetail.Currently_Getting_Program_Name__c;
            sOtherProgName = objAppDetail.Other_Program_Name__c;
            sOtherServiceName = objAppDetail.Other_Service_Name__c;
            sRelatedAppId = objAppDetail.Related_Application__c;
            sServiceId = objAppDetail.Service__c;
            sServiceName = objAppDetail.Service__r.Name ; 
            bGettingCurrently = objAppDetail.Getting_the_Service__c;
            bNeededInFuture = objAppDetail.Service_Needed__c;
            sAppdetailId = objAppDetail.Id;
        }
    }

    @AuraEnabled
    public static AppWrapper getAppDetailInfo(String sAppId) {
        
        List<CC_Application__c> lstApplications = [SELECT Id,
                                                          CC_How_soon_services_needed__c,
                                                          CC_Describe_why_services_are_needed__c,
                                                          CC_On_Any_Waiver_Waiting_List__c,
                                                          Visited_Pages__c,
                                                  (SELECT Id,
                                                          Currently_Getting_Program_Name__c,
                                                          Other_Program_Name__c,
                                                          Other_Service_Name__c,
                                                          Related_Application__c,
                                                          Service__c,
                                                          Service__r.Name,
                                                          Service_Needed__c,
                                                          Getting_the_Service__c,
                                                          Waiting_List_Program__c,
                                                          Waiting_List_Program__r.Name,
                                                          RecordTypeId
                                                    FROM  Application_Details__r)
                                                   FROM CC_Application__c WHERE Id =: sAppId];

        System.debug('lstApplications-->'+lstApplications);

        AppWrapper objApplWrap;
        if(!lstApplications.isEmpty()) {
            CC_Application__c objApp = lstApplications[0];
            objApplWrap = new AppWrapper();
            objApplWrap.sId = sAppId;
            objApplWrap.sHowSoonServiceNeeded = objApp.CC_How_soon_services_needed__c;
            objApplWrap.sDescribeWhyServiceNeeded = objApp.CC_Describe_why_services_are_needed__c;
            objApplWrap.isIndividualWaitinglist = objApp.CC_On_Any_Waiver_Waiting_List__c;

            for(CC_Application_Detail__c objAppDetail : lstApplications[0].Application_Details__r) {
                if(sServiceTypeId.equals(objAppDetail.RecordTypeId))
                    objApplWrap.lstRelatedServiceDetail.add(new ServiceWrapper(objAppDetail)); 
                else if(sWaitListTypeId.equals(objAppDetail.RecordTypeId)) {
                    objApplWrap.lstRelatedWaitingProgram.add(objAppDetail);
                }
            }
        }   

        System.debug('sServiceTypeId'+sServiceTypeId);
        System.debug('sWaitListTypeId'+sWaitListTypeId);
        System.debug('objApplWrap.lstRelatedServiceDetail:' +objApplWrap.lstRelatedServiceDetail);  
        System.debug('objApplWrap.lstRelatedServiceDetail:' +objApplWrap.lstRelatedWaitingProgram);                                

        return objApplWrap;

    }


    @AuraEnabled
    public static String getPageDataForApplication(String sAppId) {

        PicklistWrapper objPicklistWrapper = new PicklistWrapper();

        //Map<String, Schema.SObjectField> mapAppDetailField = CC_Utility.getFieldMap(CC_Constants.CC_APP_DETAIL_OBJ);
        Map<String, Schema.SObjectField> mapAppField = CC_Utility.getFieldMap(CC_Constants.CC_APPLICATION_OBJ);

        objPicklistWrapper.lstHowSoonServicesNeeded = CC_Utility.getPicklistValuesFromFieldMap(mapAppField,
                                                      CC_Constants.CC_APP_DETAIL_FLD_SERVICE_PERIOD);

        List<CC_Program_Service__c> lstProgramAndService = [SELECT Id,
                                                          Name,
                                                          RecordTypeId,
                                                          Active__c,
                                                          Agency__c,
                                                          Program__c,
                                                          Program__r.Name,
                                                          Modifier_1__c,
                                                          Modifier_2__c,
                                                          Modifier_3__c,
                                                          Modifier_4__c,
                                                          Modifier_Code__c
                                                    FROM CC_Program_Service__c 
                                                    WHERE Active__c = true
                                                    AND (RecordTypeId =: sProgramTypeId
                                                    OR  RecordTypeId =: sProgramServiceTypeId)];

        for(CC_Program_Service__c objProg : lstProgramAndService){
            if(sProgramTypeId.equals(objProg.RecordTypeId))
                objPicklistWrapper.mapProgramNameId.put(objProg.Name,objProg.Id); 

            if(sProgramServiceTypeId.equals(objProg.RecordTypeId)) {
                ServiceInfo objServiceInfo = new ServiceInfo(objProg.Id,
                                                                 objProg.Name,
                                                                 objProg.Modifier_Code__c,
                                                                 objProg.Program__c);
                if(!objPicklistWrapper.mapProgramService.containsKey(objProg.Program__r.Name)){
                    objPicklistWrapper.mapProgramService.put(objProg.Program__r.Name,
                                                             new List<ServiceInfo>{objServiceInfo});
                }else {
                    objPicklistWrapper.mapProgramService.get(objProg.Program__r.Name).add(objServiceInfo);
                }
                
            }
        }
        
        System.debug('objPicklistWrapper-->' +objPicklistWrapper);
        Map<String,String> mapLabelAndError = loadLabelAndError();

        AppWrapper objApplication = getAppDetailInfo(sAppId);

        String sCurrentProfile = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Profile.Name;
        
        
        return '{"PicklistWrapper":'+JSON.serialize(objPicklistWrapper)
                + ',"MapLabelError":'+JSON.serialize(mapLabelAndError)
                +',"AppDetailInfo":'+JSON.serialize(objApplication)
                + ',"CurrentProfile":'+JSON.serialize(sCurrentProfile) + '}';
    }

    @AuraEnabled
    public static String updateApplication(CC_Application__c objApp, String sOtherName, List<String> lstWaitProgramId) {

        String retString = '';
        objApp.CC_How_soon_services_needed__c = String.valueOf(objApp.CC_How_soon_services_needed__c);
        objApp.CC_Describe_why_services_are_needed__c = String.valueOf(objApp.CC_Describe_why_services_are_needed__c);
        objApp.CC_On_Any_Waiver_Waiting_List__c = Boolean.valueOf(objApp.CC_On_Any_Waiver_Waiting_List__c);
        objApp.Id = String.valueOf(objApp.Id);
        String sAppVisitedPages = [SELECT Id,Visited_Pages__c 
                                   FROM CC_Application__c WHERE Id =: objApp.Id LIMIT 1].Visited_Pages__c;
        objApp.Visited_Pages__c = CC_Utility.setTabName(System.label.CC_Label_Services,sAppVisitedPages);
        
        Map<String,Id> mapWaitlistProgs = new Map<String,Id>();
        for(CC_Program_Service__c objProg : [SELECT Id, Name from CC_Program_Service__c where RecordType.Id =: sProgramTypeId]){
            mapWaitlistProgs.put(objProg.Name,objProg.Id);
        }
        System.debug('mapWaitlistProgs :'+mapWaitlistProgs);
        System.debug('ProgList through Params :'+lstWaitProgramId);

        Id isOtherId ;
        List<Id> lstWaitlistProgIds = new List<Id>();

        for(String sPName : lstWaitProgramId){
        	if(mapWaitlistProgs.containsKey(sPName)){
        		system.debug('Inside If :'+sPName);
        		lstWaitlistProgIds.add(mapWaitlistProgs.get(sPName));
        		if(sPName == 'Other')
        			isOtherId = mapWaitlistProgs.get(sPName);
        	}
        }
        System.debug('ProgList through Params :'+lstWaitlistProgIds);
        system.debug('Other Id is :'+isOtherId);

        try{
            //update application
            update objApp;

            //update waitlist programs
            if(!lstWaitProgramId.isEmpty())
                updateWailistPrograms(objApp.Id,sOtherName,lstWaitlistProgIds,isOtherId);
            else {

                List<CC_Application_Detail__c> lstAppDetailsToDelete = [SELECT Id,Name,RecordTypeId 
                                                                FROM CC_Application_Detail__c
                                                                WHERE RecordTypeId =: sWaitListTypeId
                                                                AND Related_Application__c =: objApp.Id];

                System.debug('lstAppDetailsToDelete-->' +lstAppDetailsToDelete);

                
                if(!lstAppDetailsToDelete.isEmpty()) {
                    delete lstAppDetailsToDelete;
                }   
            }
            
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
        SYstem.debug('retString :'+retString);                                                  
        return retString;
    }

    public static void updateWailistPrograms(String sAppId, String sOtherName, List<String> lstWaitProgramId, Id isOtherId) {
        List<CC_Application_Detail__c> lstAppDetailsToDelete = [SELECT Id,Name,RecordTypeId 
                                                                FROM CC_Application_Detail__c
                                                                WHERE RecordTypeId =: sWaitListTypeId
                                                                AND Related_Application__c =: sAppId];

        System.debug('lstAppDetailsToDelete-->' +lstAppDetailsToDelete);

        try{
            if(!lstAppDetailsToDelete.isEmpty()) {
                delete lstAppDetailsToDelete;
            }   

        List<CC_Application_Detail__c> lstWaitListProgToInsert = new List<CC_Application_Detail__c>();
        CC_Application_Detail__c objAppDetail; 

            for(String sProgramId : lstWaitProgramId) {
                    objAppDetail = new CC_Application_Detail__c();
                    objAppDetail.Related_Application__c = String.valueOf(sAppId);
                    objAppDetail.RecordTypeId = sWaitListTypeId;
                    if(String.valueOf(isOtherId) != '' && String.valueOf(isOtherId)  == String.valueOf(sProgramId))
                        objAppDetail.Other_Program_Name__c = String.isNotBlank(sOtherName) ? 
                                                     String.valueOf(sOtherName.trim()) : '';

                    //if(String.isBlank(objAppDetail.Other_Program_Name__c))
                    objAppDetail.Waiting_List_Program__c = sProgramId;

                    lstWaitListProgToInsert.add(objAppDetail);
                    
            }   
            System.debug('lstWaitListProgToInsert to insert:' +lstWaitListProgToInsert);
            System.debug('lstWaitListProgToInsert Size:' +lstWaitListProgToInsert.size());

            insert lstWaitListProgToInsert;

        }catch(Exception ex){
            
            System.debug('Exception on Class : CC_ServicesController - updateWailistPrograms, Error : ' +
            ex.getMessage() +
            ' Line Number : ' +
            ex.getLineNumber() +
            ' Cause : ' +
            ex.getCause() +
            ' Type : ' +
            ex.getTypeName());
        }


    }

    @TestVisible
    private static Map<String,String> loadLabelAndError() {
        Map<String,String> mapLabelAndError = new Map<String, String>();
        mapLabelAndError.put('CC_LBL_OTHER',System.label.CC_LBL_OTHER);
        mapLabelAndError.put('CC_Service_ServicePeriod',System.label.CC_Service_ServicePeriod);
        mapLabelAndError.put('CC_Service_WhyServiceNeeded',System.label.CC_Service_WhyServiceNeeded);
        mapLabelAndError.put('CC_Service_IsOnWaitingList',System.label.CC_Service_IsOnWaitingList);
        mapLabelAndError.put('CC_Service_WaitingList',System.label.CC_Service_WaitingList);
        mapLabelAndError.put('CC_Label_Add_New_Services',System.label.CC_Label_Add_New_Services);
        mapLabelAndError.put('CC_Label_Service',System.label.CC_Label_Service);
        mapLabelAndError.put('CC_Label_Getting_Service',System.label.CC_Label_Getting_Service);
        mapLabelAndError.put('CC_Label_Service_Needed',System.label.CC_Label_Service_Needed);


        mapLabelAndError.put('CC_Label_Close',System.label.CC_Label_Close);
        mapLabelAndError.put('CC_Label_Add_Service',System.label.CC_Label_Add_Service);
        mapLabelAndError.put('CC_Label_Select_Service',System.label.CC_Label_Select_Service);
        mapLabelAndError.put('CC_Label_Individual_availing_service',System.label.CC_Label_Individual_availing_service);
        mapLabelAndError.put('CC_Label_Enter_Prog',System.label.CC_Label_Enter_Prog);
        mapLabelAndError.put('CC_Label_Select_Prog',System.label.CC_Label_Select_Prog);
        mapLabelAndError.put('CC_Label_Individual_Req_Service',System.label.CC_Label_Individual_Req_Service);

        mapLabelAndError.put('CC_Label_Cancel',System.label.CC_Label_Cancel);
        mapLabelAndError.put('CC_Label_Save',System.label.CC_Label_Save);

        mapLabelAndError.put('CC_LBL_YES',System.label.CC_LBL_YES);
        mapLabelAndError.put('CC_LBL_NO',System.label.CC_LBL_NO);
        mapLabelAndError.put('CC_LBL_SELECT',System.label.CC_LBL_SELECT);

        mapLabelAndError.put('CC_Err_Service_Period_Mandatory',System.Label.CC_Err_Service_Period_Mandatory);
        mapLabelAndError.put('CC_Err_Why_Service_Needed',System.Label.CC_Err_Why_Service_Needed);
        mapLabelAndError.put('CC_Err_Is_Waitlisted',System.Label.CC_Err_Is_Waitlisted);
        mapLabelAndError.put('CC_Err_Waitlist_Services',System.Label.CC_Err_Waitlist_Services);
        mapLabelAndError.put('CC_Err_Service_Needed_Required',System.Label.CC_Err_Service_Needed_Required);
        mapLabelAndError.put('CC_Label_Services',System.Label.CC_Label_Services);
        mapLabelAndError.put('CC_LBL_Program_Name',System.Label.CC_LBL_Program_Name);
        mapLabelAndError.put('CC_ACTION',System.Label.CC_ACTION);
        mapLabelAndError.put('CC_Err_Other_Program_Name',System.Label.CC_Err_Other_Program_Name);
        mapLabelAndError.put('CC_Err_Service_Prog_already_exist',System.Label.CC_Err_Service_Prog_already_exist);
        mapLabelAndError.put('CC_Err_No_Current_Future_Service',System.Label.CC_Err_No_Current_Future_Service);
        mapLabelAndError.put('CC_Err_Service_Needed_Exists',System.label.CC_Err_Service_Needed_Exists);

        mapLabelAndError.put('CC_APP_REVIEWER_PROFILE',CC_Constants.CC_APP_REVIEWER_PROFILE);
        mapLabelAndError.put('CC_Label_Please',System.label.CC_Label_Please);
        mapLabelAndError.put('CC_Label_Enter_Service_Name',System.label.CC_Label_Enter_Service_Name);

        return mapLabelAndError;
    }


    @AuraEnabled
    public static String deleteAppDetail(List<String> lstAppDetailId, String sAppId) {

        String retString = '';
        CC_Application_Detail__c objAppDetail;
        List<CC_Application_Detail__c> lstAppDetailToDelete = new List<CC_Application_Detail__c>();

        for(String sAppDetailId: lstAppDetailId) {
            objAppDetail = new CC_Application_Detail__c();
            objAppDetail.Id = sAppDetailId;
            lstAppDetailToDelete.add(objAppDetail);
        }

        try{
            delete lstAppDetailToDelete;
            retString = refreshServices(sAppId);
        }
        catch(Exception ex){
            retString = 'Fail';
            System.debug('Exception on Class : CC_ServicesController - deleteAppDetail, Error : ' +
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

    public static String refreshServices(String sAppId) { 
    
        List<CC_Application__c> lstApplications = [SELECT Id,
                                                      (SELECT Id,
                                                              Currently_Getting_Program_Name__c,
                                                              Other_Program_Name__c,
                                                              Other_Service_Name__c,
                                                              Related_Application__c,
                                                              Service__c,
                                                              Service__r.Name,
                                                              Service_Needed__c,
                                                              Getting_the_Service__c,
                                                              RecordTypeId
                                                        FROM  Application_Details__r
                                                        WHERE RecordTypeId =: sServiceTypeId )
                                                       FROM CC_Application__c WHERE Id =: sAppId];
        
        System.debug('lstApplications-->'+lstApplications);

        List<ServiceWrapper> lstRelatedServiceDetail = new List<ServiceWrapper>();
        if(!lstApplications.isEmpty()) {
            
            for(CC_Application_Detail__c objAppDetail : lstApplications[0].Application_Details__r) {
                lstRelatedServiceDetail.add(new ServiceWrapper(objAppDetail));
            }
        } 

        return '{"lstRelatedServiceDetail":'+JSON.serialize(lstRelatedServiceDetail) + '}'; 
    }

    @AuraEnabled
    public static String addAppDetail(String sJSON) {

        String retString = '';
        System.debug('JSON-->'+sJSON);

        ServiceWrapper objServiceWrapper = (ServiceWrapper)JSON.deserialize(sJSON, ServiceWrapper.class);
        System.debug('objServiceWrapper-->'+objServiceWrapper);

        CC_Application_Detail__c objAppDetail = new CC_Application_Detail__c();

        if(String.isBlank(objServiceWrapper.sAppdetailId)) {
            objAppDetail.RecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, System.label.CC_RT_Service_Type);
            objAppDetail.Related_Application__c = objServiceWrapper.sRelatedAppId;
        }else{
            objAppDetail.Id = objServiceWrapper.sAppdetailId;
        }
            
        objAppDetail.Getting_the_Service__c = objServiceWrapper.bGettingCurrently;
        objAppDetail.Other_Program_Name__c = String.isNotBlank(objServiceWrapper.sOtherProgName) ? 
                                             objServiceWrapper.sOtherProgName.trim() : '';



        objAppDetail.Other_Service_Name__c = String.isNotBlank(objServiceWrapper.sOtherServiceName) ? 
                                                     objServiceWrapper.sOtherServiceName.trim() : '';
        
        if(String.isNotBlank(objServiceWrapper.sServiceId))
            objAppDetail.Service__c = objServiceWrapper.sServiceId;
        
        objAppDetail.Service_Needed__c = objServiceWrapper.bNeededInFuture;


        System.debug('objAppDetail to insert:' +objAppDetail);

        try{
            upsert objAppDetail;
            System.debug('objAppDetail inserted:' +objAppDetail);
            retString = refreshServices(objServiceWrapper.sRelatedAppId);
        }
        catch(Exception ex){
            retString = 'Fail';
            System.debug('Exception on Class : CC_ServicesController - addAppDetail, Error : ' +
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

}