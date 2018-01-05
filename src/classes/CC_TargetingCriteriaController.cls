/***************************************************************************************************************************************
* NAME   : CC_TargetingCriteriaController
* DESCRIPTION  :   
*    
* @AUTHOR   : Pankaj Sharma
* @DATE   : 12-12-2017
*
* MODIFICATION LOG:  
* --------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                DATE                DESCRIPTION 
* --------------------------------------------------------------------------------------------------------------------------------------
* Pankaj Sharma               12-12-2017            Initial version  
* Debalina                    12-14-2017            Added more logic
* Debalina                    12-20-2017            Added more logic and Response
* Debalina                    01-02-2018            Issue Fix
* Debalina                    01-05-2018            Issue Fix-Passed Contact Id to task
****************************************************************************************************************************************/

public without sharing class CC_TargetingCriteriaController {
   
   public CC_TargetingCriteriaController(){}
   public class ComponentWrapper {
        public String sAppId;
        public String sAppDetailId;
        public String sAppDetailStatus;
        public Boolean bMeetCriteria;
        public Boolean bMeetAnotherCriteria;
        public String sWaiverProg;
        public String sComments;
        public String sAppDate;
        public Date dTargetingDate;
        public String sCaseId;
        public Time tTime;
        public DateTime dtProcessDateTime;
        public String sTaskIdToClose;
        public String sTimeZone;

        public ComponentWrapper(){
            bMeetCriteria = false;
            bMeetAnotherCriteria = false;
        }
    }

    public static String sProgramTypeId, sAppDetailTypeId;
    static {
         sProgramTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_Program);
         sAppDetailTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, System.label.CC_RT_Waiver_AppDetail);
    }
    /*************************************************************
    @Method Name = doSave;
    @Purpose = To save data send by CC_TargetingCriteria component
    @Parameters = Application Detail JSON String and Application Id
    @return = Void
    ***************************************************************/
    @AuraEnabled
    public static string doSave(String sJSON, String sWaiverProgId, Boolean bIsSubmit){
        try{
            system.debug('sJSON:'+sJSON);
            ComponentWrapper objAppDetails = (ComponentWrapper)JSON.deserialize(sJSON, ComponentWrapper.class);
            system.debug('objAppDetails--->'+objAppDetails);
            System.debug('bIsSubmit-->' +bIsSubmit);
            CC_Application_Detail__c objAppDetailToUpdate = new CC_Application_Detail__c();
            objAppDetailToUpdate.Individual_Meet_Waiver_Criteria__c = objAppDetails.bMeetCriteria;
            objAppDetailToUpdate.Meet_For_Another_Waiver_Program__c = objAppDetails.bMeetAnotherCriteria;
            objAppDetailToUpdate.Id = objAppDetails.sAppDetailId;
            objAppDetailToUpdate.Targeting_Comments__c = objAppDetails.sComments;
            objAppDetailToUpdate.Processing_Date_Time__c = objAppDetails.dtProcessDateTime;
            objAppDetailToUpdate.Select_Time_Zone__c = objAppDetails.sTimeZone;
           
            Map<String,String> mapTask = new Map<String,String>();
            mapTask.put('DT_Master_Record_Id__c', objAppDetails.sAppId);
            mapTask.put('Application__c', objAppDetails.sAppId);
            mapTask.put('Case__c', objAppDetails.sCaseId);
            //mapTask.put('Contact__c', getContactId(objAppDetails.sAppId));
            mapTask.put('DT_Comments__c', objAppDetails.sComments);
            

            if(!objAppDetails.bMeetCriteria){
               objAppDetailToUpdate.Status__c = System.label.CC_Status_Targeting_Criteria_Not_Met; 
            }else{
               if(!System.Label.CC_PGM_STATUS_WAITLISTED.equals(objAppDetails.sAppDetailStatus))
                  objAppDetailToUpdate.Status__c = CC_Constants.CC_APP_DTL_STATUS_PENDING;
            }

            System.debug('objAppDetailToUpdate-->' +objAppDetailToUpdate);
            String sAppVisitedPages = [SELECT Id,Visited_Pages__c 
                                   FROM CC_Application_Detail__c WHERE Id =: objAppDetailToUpdate.Id LIMIT 1].Visited_Pages__c;
            System.debug('sAppVisitedPages-->'+sAppVisitedPages);
            objAppDetailToUpdate.Visited_Pages__c = CC_Utility.setTabName(System.label.CC_Page_Targeting, sAppVisitedPages);
            update objAppDetailToUpdate;

            if(!objAppDetails.bMeetCriteria && objAppDetails.bMeetAnotherCriteria && bIsSubmit){
                String sNewAppDetailId = createAppDetailAndTask(objAppDetails.sAppId,
                                                                 objAppDetails.sAppDetailId,
                                                                 sWaiverProgId,
                                                                 mapTask,
                                                                 objAppDetails.sTaskIdToClose);
                System.debug('sNewAppDetailId-->'+sNewAppDetailId);
            }
            else if(!objAppDetails.bMeetCriteria  && !objAppDetails.bMeetAnotherCriteria && bIsSubmit){
                
                List<DT_Task__c> lstTask = [SELECT Id,DT_Status__c,
                                                   Application_Detail__c 
                                                FROM DT_Task__c
                                                WHERE Application_Detail__c =: objAppDetails.sAppDetailId
                                                AND DT_Status__c =: CC_Constants.CC_TASK_STATUS_NEW];

                if(lstTask.isEmpty()){ 
                   DT_TaskResponseWrapper objResponse;
                   //Create task for App Reviewer
                   mapTask.put('Application_Detail__c', objAppDetails.sAppDetailId);
                   System.debug('mapTask-->' +mapTask);
                   objResponse = DT_TaskAssignment.executeTaskRules(objAppDetails.sAppDetailId, mapTask, objAppDetails.sTaskIdToClose);
                   System.debug('Task objResponse-->' +objResponse);
                   
                }
            }

            //Send appropriate message to container component callback
            List<String> lstMessages = new List<String>();
            if(bIsSubmit){
                lstMessages.add(CC_Constants.CC_SUBMITTED);
            }else{
                lstMessages.add(System.Label.CC_MSG_APP_SAVED_SUCCESS);
            }
            
            return JSON.serialize(new CC_ResponseWrapper(true, NULL, lstMessages));
        }catch(Exception e){
            System.debug('Exception on Class : CC_TargetingCriteriaController - doSave, Error : ' +
                         e.getMessage() +
                         ' Line Number : ' +
                         e.getLineNumber() +
                         ' Cause : ' +
                         e.getCause() +
                         ' Type : ' +
                         e.getTypeName());
            return JSON.serialize(new CC_ResponseWrapper(false, NULL, new List<String>{System.Label.DT_LABEL_CONTACT_ADMIN}));
        }
    }

    /**************
    @Method Name = loadApplicationData;
    @Purpose = To send data to CC_TargetingCriteria component during page load
    @Parameters = App Id
    @return = JSON String containing Application Detail Object, Picklist values(metadata) and labels.
    **************/
    @AuraEnabled
    public static String loadApplicationDetailData(String sAppDetailId)
    { 
        list<CC_Application_Detail__c> lstAppDetails = new list<CC_Application_Detail__c>();
        CC_Application_Detail__c objAppDetails;
        Set<CC_PickListValue_Wrapper> setWaiverProg;
        Map<String,String> maploadLabels = new Map<String,String>();
        ComponentWrapper objWrap = new ComponentWrapper();
        try{
            maploadLabels = loadLabels();
            lstAppDetails = [SELECT Id,
                                    Status__c,
                                    Related_Application__c,
                                    Related_Application__r.CreatedDate,
                                    Related_Application__r.CC_Case__c,    
                                    Waiting_List_Program__c,
                                    Original_Program_Suggestion__c,
                                    Individual_Meet_Waiver_Criteria__c,
                                    Processing_Date_Time__c,
                                    Meet_For_Another_Waiver_Program__c,
                                    Select_Time_Zone__c,
                                    Targeting_Comments__c
                            FROM CC_Application_Detail__c WHERE Id =: sAppDetailId];

            if(lstAppDetails.size() == 1){
                objAppDetails = lstAppDetails[0];
            }
            System.debug('objAppDetails-->'+objAppDetails);

            //Time Zone Values
            List<CC_PickListValue_Wrapper> lstTimeZone = new List<CC_PickListValue_Wrapper>();
            lstTimeZone.add(new CC_PickListValue_Wrapper('',System.Label.CC_Select_Time_Zone));
            Map<String, Schema.SObjectField> mapField = CC_Utility.getFieldMap(CC_Constants.CC_APP_DETAIL_OBJ);
            List<String> lstValues = CC_Utility.getPicklistValuesFromFieldMap(mapField,
                                                      CC_Constants.CC_FLD_TIME_ZONE);
            for(String sVal: lstValues){
                lstTimeZone.add(new CC_PickListValue_Wrapper(sVal));
            }

            //Program Values
            List<CC_Program_Service__c> lstPrograms = getAvailablePrograms(objAppDetails.Related_Application__c);
            setWaiverProg = new Set<CC_PickListValue_Wrapper>();
            setWaiverProg.add(new CC_PickListValue_Wrapper(NULL,System.Label.CC_LBL_SELECT));

            /*String sChildAppDetailProgId = '';
            for(CC_Application_Detail__c objParent :lstAppDetails){
                if(objParent.Child_Program_Suggestions__r.size() == 1) {
                    Map<String,String> mapProgramIdName = getChildProgId(objParent.Child_Program_Suggestions__r[0]);
                    Set<String> setProgId = mapProgramIdName.keySet();
                    sChildAppDetailProgId = new List<String>(setProgId)[0];
                    setWaiverProg.add(new CC_PickListValue_Wrapper(sChildAppDetailProgId,mapProgramIdName.get(sChildAppDetailProgId)));
                }
            }*/

            //Other Application detail with same program has to be removed
            for(CC_Program_Service__c objProg: lstPrograms) {
                if(objProg.Name != System.Label.CC_LBL_OTHER)
                setWaiverProg.add(new CC_PickListValue_Wrapper(objProg.Id,objProg.Name));
            }

            //populate wrapper
            objWrap.sAppId = objAppDetails.Related_Application__c;
            objWrap.sAppDetailId = objAppDetails.Id;
            objWrap.bMeetCriteria = objAppDetails.Individual_Meet_Waiver_Criteria__c;
            objWrap.bMeetAnotherCriteria = objAppDetails.Meet_For_Another_Waiver_Program__c;
            objWrap.sWaiverProg = objAppDetails.Waiting_List_Program__c;
            objWrap.sComments = objAppDetails.Targeting_Comments__c;
            objWrap.dTargetingDate = (objAppDetails.Processing_Date_Time__c != NULL)? 
                                     Date.valueOf(objAppDetails.Processing_Date_Time__c) : Date.valueOf(System.now());
            objWrap.dtProcessDateTime = objAppDetails.Processing_Date_Time__c;
            objWrap.sTimeZone = String.isNotBlank(objAppDetails.Select_Time_Zone__c)? 
                                objAppDetails.Select_Time_Zone__c : '';
            objWrap.sAppDate = objAppDetails.Related_Application__r.CreatedDate.format(CC_Constants.CC_OUTPUT_DATE_FORMAT); 
            objWrap.sCaseId = objAppDetails.Related_Application__r.CC_Case__c;
            objWrap.sAppDetailStatus = objAppDetails.Status__c;

            DateTime dtNow = DateTime.now();
            System.debug('dtNow-->' +dtNow);
            Integer iHour =  (objAppDetails.Processing_Date_Time__c != NULL)? objAppDetails.Processing_Date_Time__c.hour() : dtNow.hour();
            Integer iMinute = (objAppDetails.Processing_Date_Time__c != NULL)? objAppDetails.Processing_Date_Time__c.minute() : dtNow.minute();
            Integer iSecond = (objAppDetails.Processing_Date_Time__c != NULL)? objAppDetails.Processing_Date_Time__c.second() : dtNow.second();
            objWrap.tTime = Time.newInstance(iHour, iMinute, iSecond, 0);

            String sJSON = '{"AppDetailObj" : '+JSON.serialize(objWrap)
                            +',"mapUiLabels" : '+JSON.serialize(maploadLabels)
                            +',"lstPrograms" : '+JSON.serialize(setWaiverProg)
                            +',"lstTimeZone" : '+JSON.serialize(lstTimeZone)
                            +'}';

            return JSON.serialize(new CC_ResponseWrapper(true, sJSON));

        }catch(Exception e){
            System.debug('Exception on Class : CC_TargetingCriteriaController - loadApplicationDetailData, Error : ' +
                         e.getMessage() +
                         ' Line Number : ' +
                         e.getLineNumber() +
                         ' Cause : ' +
                         e.getCause() +
                         ' Type : ' +
                         e.getTypeName());
            return JSON.serialize(new CC_ResponseWrapper(false, NULL, new List<String>{System.Label.DT_LABEL_CONTACT_ADMIN}));
        }  
    }
    
    /**************
    @Method Name = loadLabels;
    @Purpose = load labels and error labels;
    @Parameters = 
    @return = Map<String,String>
    **************/ 
    @TestVisible
    private static Map<String,String> loadLabels() {
        Map<String,String> mapLabels = new Map<String,String>();
        mapLabels.put('Individual_Meet_Waiver_Criteria',System.Label.Individual_Meet_Waiver_Criteria);
        mapLabels.put('Individual_Meet_For_Another_Waiver',System.Label.Individual_Meet_For_Another_Waiver);
        mapLabels.put('Comments_To_Application_Reviewer',System.Label.Comments_To_Application_Reviewer);
        mapLabels.put('Select_Waiver_Targeting_Cretria',System.Label.Select_Waiver_Targeting_Cretria);
        mapLabels.put('Comments_To_Capacity_Reviewer',System.Label.Comments_To_Capacity_Reviewer);
        mapLabels.put('Application_Date',System.Label.Application_Date);
        mapLabels.put('Confirm_Date',System.Label.Confirm_Date);
        mapLabels.put('Confirm_Time',System.Label.Confirm_Time);
        mapLabels.put('CC_I_Don_t_Know',System.Label.CC_I_Don_t_Know);
        mapLabels.put('CC_No',System.Label.CC_No);
        mapLabels.put('CC_Label_ConfirmDate',System.Label.CC_Label_ConfirmDate);
        mapLabels.put('CC_Yes',System.Label.CC_Yes);
        
        
        mapLabels.put('CC_ERR_SELECT_A_PROGRAM',System.Label.CC_ERR_SELECT_A_PROGRAM);
        mapLabels.put('CC_Err_Please_Enter_Confirm_Date',System.Label.CC_Err_Please_Enter_Confirm_Date);
        mapLabels.put('CC_Err_Please_Enter_Confirm_Time',System.Label.CC_Err_Please_Enter_Confirm_Time);
        mapLabels.put('CC_Err_Please_Enter_Comments',System.Label.CC_Err_Please_Enter_Comments);        
        mapLabels.put('CC_Err_Confirm_Date_Cannot_Future_Date',System.Label.CC_Err_Confirm_Date_Cannot_Future_Date);  
        mapLabels.put('CC_Err_Select_Time_Zone',System.Label.CC_Err_Select_Time_Zone);  
        mapLabels.put('CC_Err_Enter_Valid_Date',System.Label.CC_Err_Enter_Valid_Date);  
        mapLabels.put('CC_Select_Time_Zone',System.Label.CC_Select_Time_Zone); 
        mapLabels.put('CC_PGM_STATUS_WAITLISTED',System.Label.CC_PGM_STATUS_WAITLISTED); 

        return mapLabels;
    }

    /**************
    @Method Name = getAvailablePrograms
    @Purpose = Load Programs available for the Application Deatil
    @Parameters = sAppId-Application Id
    @return = List<CC_Program_Service__c>
    **************/ 
    public static List<CC_Program_Service__c> getAvailablePrograms(String sAppId){

        List<CC_Program_Service__c> lstPrograms = [SELECT Id,
                                                       Name                                                              
                                                    FROM CC_Program_Service__c 
                                                    WHERE RecordTypeId =: sProgramTypeId
                                                    AND Id NOT IN (SELECT Waiting_List_Program__c
                                                    FROM CC_Application_Detail__c
                                                    WHERE RecordTypeId =: sAppDetailTypeId 
                                                    AND Related_Application__c =: sAppId) ];

        return lstPrograms;                                            
    }

    /**************
    @Method Name = createAppDetailAndTask
    @Purpose = Load Programs available for the Application Deatil
    @Parameters = sAppId-Application Id,sParentAppDetailId= parent app detail,mapTask for task-Map<String,String>,sTaskIdToClose- Previous task Id to close
    @return = DT_TaskResponseWrapper
    **************/ 
    public static String createAppDetailAndTask(String sAppId, 
                                                String sParentAppDetailId, 
                                                String sWaiverProgId, 
                                                Map<String,String> mapTask, 
                                                String sTaskIdToClose){
        CC_Application_Detail__c objAppDetailChild = new CC_Application_Detail__c();
        objAppDetailChild.Individual_Meet_Waiver_Criteria__c = false;
        objAppDetailChild.Meet_For_Another_Waiver_Program__c = false;
        objAppDetailChild.Waiting_List_Program__c = sWaiverProgId;
        objAppDetailChild.Related_Application__c = sAppId;
        objAppDetailChild.Original_Program_Suggestion__c = sParentAppDetailId;
        objAppDetailChild.Status__c = CC_Constants.CC_APP_DTL_STATUS_PENDING;
        objAppDetailChild.RecordTypeId = sAppDetailTypeId;

        List<CC_Application_Detail__c> lstExistingChild = [SELECT Id FROM CC_Application_Detail__c 
                                                           WHERE Original_Program_Suggestion__c =: sParentAppDetailId LIMIT 1];
        
        if(lstExistingChild.size() == 1){
            objAppDetailChild.Id = lstExistingChild[0].Id;
        }

        system.debug('objAppDetailChild-->'+objAppDetailChild);
        upsert objAppDetailChild;

        List<DT_Task__c> lstTask = [SELECT Id,DT_Status__c,
                                           Application_Detail__c 
                                    FROM DT_Task__c
                                    WHERE Application_Detail__c =: objAppDetailChild.Id
                                    AND DT_Status__c =: CC_Constants.CC_TASK_STATUS_NEW];
        if(lstTask.isEmpty()){                      
            DT_TaskResponseWrapper objResponse;
            //Task Fw Parameters
            mapTask.put('Application_Detail__c', objAppDetailChild.Id);
            //Create task for Capacity Reviewer Group queue     
            objResponse = DT_TaskAssignment.executeTaskRules(objAppDetailChild.Id, mapTask, sTaskIdToClose);
            system.debug('objResponse-->'+objResponse);
        }
        
        return objAppDetailChild.Id;
    }

    /**************
    @Method Name = getChildProgId
    @Purpose = Return ProgramId of Child App Detail
    @Parameters = objChildAppDetail = Child Application detail record
    @return = ProgramId
    **************/ 
   /* public static Map<String,String> getChildProgId(CC_Application_Detail__c objChildAppDetail){
        Map<String,String> mapProgramIdName = new Map<String,String>();
        mapProgramIdName.put(objChildAppDetail.Waiting_List_Program__c,objChildAppDetail.Waiting_List_Program__r.Name);
        return mapProgramIdName;
    }*/

  }