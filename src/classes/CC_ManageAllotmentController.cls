/***************************************************************************************************************************************
 * NAME   : CC_ManageAllotmentController
 * DESCRIPTION  : 
 *    
 * @AUTHOR   : Akash
 * @DATE   : 13-Dec-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Akash					13-Dec-2017          Initial version        
 * Nidhin V K				02-Jan-2018          added comments, added field overriding for task framework
 * Akshay Mohan             04-Jan-2018          Changed logic for waitlist
 ****************************************************************************************************************************************/

public class CC_ManageAllotmentController {
    
    
    
    public static String sProgramTypeId, sAppDetailTypeId;
    static {
         sProgramTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_PROGRAM_SERVICE_OBJ, System.label.CC_RT_Program);
         sAppDetailTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, System.label.CC_RT_Waiver_AppDetail);
    }
    
    
    /**************
    @Method Name = loadApplicationData;
    @Purpose = To send data to CC_ManageAllotment component during page load
    @Parameters = Applcation Detail Id
    @return = JSON String containing Application Detail Object, Picklist values(metadata) and labels.
    **************/
    @AuraEnabled
    public static String loadData(String sAppDetId){
        
        System.debug('Application Detail Id:' +sAppDetId);
        Map<String,String> mapLabels = new Map<String,String>();
        Set<CC_PickListValue_Wrapper> setWaiverProg;
        Set<CC_PickListValue_Wrapper> setProgDetail;
        List<WrapperGridValues>lstWrapperProgramDetail=new List<WrapperGridValues>();
        List<CC_Program_Service__c> prgDetails;
        
        Integer filledSeats=0,reservedSeats=0,vacatedSeats=0,freedSeats=0,waitlistedSeats=0,availableSeats=0,totalCapacity=0;
        
        Map<String, Schema.SObjectField> mapAppDetailFields = CC_Utility.getFieldMap(CC_Constants.CC_APP_DETAIL_OBJ);
        
        List<CC_PickListValue_Wrapper> lstCapacityrevActions = CC_Utility.getPicklistValuesWrapper(mapAppDetailFields,CC_Constants.CC_WAIVER_CAPACITY_ACTIONS,
	                                                                                  System.Label.CC_LABEL_CAPACITY_REVIEW);
        CC_Application_Detail__c appDetObj=[Select Id,Waiting_List_Program__c,Related_Application__c,Related_Application__r.CC_Individual__c,
                                                    Capacity_Review_Action__c,Capacity_Review_Comments__c,Program_Detail__c,
                                                    Meet_For_Another_Waiver_Program__c,Status__c,Visited_Pages__c,Enrolled_Program__c 
                                           from CC_Application_Detail__c where id=:sAppDetId];
        //Start[Akshay 4-Jan-18]:Changes for waitlist behavior
        String sRemoveVal;
        System.debug('appDetObj: ' + appDetObj);
        if(appDetObj.Status__c!=System.Label.CC_PGM_STATUS_WAITLISTED)
            sRemoveVal = System.Label.CC_Capacity_Review_Action_Freed;
        if(String.isNotBlank(sRemoveVal)){
            System.debug('sRemoveVal: ' + sRemoveVal);
            Integer iRemoveIndex;
            for(Integer iIndex=0; iIndex < lstCapacityrevActions.size(); iIndex++){
                CC_PickListValue_Wrapper wrapValue = lstCapacityrevActions.get(iIndex);
                if(wrapValue.sKey == sRemoveVal){
                    iRemoveIndex = iIndex;
                    break;
                }
            }
            System.debug('iRemoveIndex: ' + iRemoveIndex);
            if(iRemoveIndex!=null)
                lstCapacityrevActions.remove(iRemoveIndex);
        }
        System.debug('lstCapacityrevActions: ' + lstCapacityrevActions);
        //End[Akshay 4-Jan-18]:Changes for waitlist behavior
        
        CC_Program_Service__c masterProgram=[Select Id,Name,(Select Id,Name,Reserved_Seats__c,Available_Seats__c,Vacated_Seats__c,Waitlisted_Seats__c,
                                                             Filled_Seats__c,Freed_Seats__c,Capacity__c from Programs_Details__r)
                                                             from CC_Program_Service__c where id=:appDetObj.Waiting_List_Program__c];
        
        System.debug('masterProgram-->' +masterProgram);

        
        prgDetails=masterProgram.Programs_Details__r;
        if(prgDetails.size() > 0){
        for(CC_Program_Service__c prg:prgDetails){
            
            filledSeats+=Integer.valueOf(prg.Filled_Seats__c);
            reservedSeats+=Integer.valueOf(prg.Reserved_Seats__c);
            vacatedSeats+=Integer.valueOf(prg.Vacated_Seats__c); 
            freedSeats+=Integer.valueOf(prg.Freed_Seats__c);
            waitlistedSeats+=Integer.valueOf(prg.Waitlisted_Seats__c);
            availableSeats+=Integer.valueOf(prg.Available_Seats__c);
            totalCapacity+=Integer.valueOf(prg.Capacity__c);
            
            
            lstWrapperProgramDetail.add(new WrapperGridValues(String.valueOf(prg.Id),String.valueOf(prg.Name),Integer.valueOf(prg.Filled_Seats__c),Integer.valueOf(prg.Reserved_Seats__c),Integer.valueOf(prg.Vacated_Seats__c),Integer.valueOf(prg.Freed_Seats__c),Integer.valueOf(prg.Waitlisted_Seats__c),Integer.valueOf(prg.Available_Seats__c),Integer.valueOf(prg.Capacity__c)));
            
        }
        
       lstWrapperProgramDetail.add(new WrapperGridValues('',System.Label.CC_LABEL_TOTAL,filledSeats,reservedSeats,vacatedSeats,freedSeats,waitlistedSeats,availableSeats,totalCapacity));
        }
        System.debug('lstWrapperProgramDetail--->' +lstWrapperProgramDetail);
        
        WrapperProgramDetail wrprogDetail=new WrapperProgramDetail();
        wrprogDetail.sPid=masterProgram.Id;
        wrprogDetail.ProgramName=masterProgram.Name;
        wrprogDetail.lstProgramDetailWrapper=lstWrapperProgramDetail;
        wrprogDetail.TotalAvailableWaiverCapacity=availableSeats;
        wrprogDetail.CurrentlyEnrolled=filledSeats;
        
        System.debug('wrprogDetail--->' +wrprogDetail);
        
        
            setProgDetail=new Set<CC_PickListValue_Wrapper>();
            setProgDetail.add(new CC_PickListValue_Wrapper(NULL,System.Label.CC_LBL_SELECT));
            for(WrapperGridValues wrGrVal:lstWrapperProgramDetail){
            if(wrGrVal.sName !=System.Label.CC_LABEL_TOTAL)
                setProgDetail.add(new CC_PickListValue_Wrapper(wrGrVal.sId,wrGrVal.sName));
            
        }
        
        List<CC_Program_Service__c> lstPrograms = CC_TargetingCriteriaController.getAvailablePrograms(appDetObj.Related_Application__c);
            setWaiverProg = new Set<CC_PickListValue_Wrapper>();
            //Other Application detail with same program has to be removed
            setWaiverProg.add(new CC_PickListValue_Wrapper(NULL,System.Label.CC_LBL_SELECT));
            for(CC_Program_Service__c objProg: lstPrograms) {
                if(objProg.Name != System.Label.CC_LBL_OTHER)
                setWaiverProg.add(new CC_PickListValue_Wrapper(objProg.Id,objProg.Name));
            }
        
        mapLabels = loadLabels();
        
        String loadresponse= '{"WrapperProgDetail":'+JSON.serialize(wrprogDetail)
                +',"lstWaiverCapacityActions":'+JSON.serialize(lstCapacityrevActions)
                +',"lstWaiverProg":'+JSON.serialize(setWaiverProg)
                +',"lstPrgDetail":'+JSON.serialize(setProgDetail)
                +',"appDetObj":'+JSON.serialize(appDetObj)
                +',"mapUiLabels":'+JSON.serialize(mapLabels)+ '}';
        
        CC_ResponseWrapper respWrapper=new CC_ResponseWrapper();
        respWrapper.response=loadresponse;
        respWrapper.success=true;
        System.debug('respWrapper-->' +respWrapper);
        
        return JSON.serialize(respWrapper);
        
        
     }
                                                           
    public class WrapperProgramDetail{
        public String ProgramName,sPid;
        public Integer TotalAvailableWaiverCapacity,CurrentlyEnrolled;
        public List<WrapperGridValues> lstProgramDetailWrapper;
    }
    
    public class WrapperGridValues{
        public String sId;
        public String sName;
        public Integer iFilledSeats,iReservedSeats,iVacatedSeats,iFreedSeats,iWaitlistedSeats,iAvailableSeats,iTotalCapacity;
        
    public WrapperGridValues(String sId,String sName,Integer iFilledSeats,Integer iReservedSeats,Integer iVacatedSeats,Integer iFreedSeats,Integer iWaitlistedSeats,Integer iAvailableSeats,Integer iTotalCapacity){
        
         this.sId=sId;
         this.sName=sName;
         this.iFilledSeats=iFilledSeats;
         this.iReservedSeats=iReservedSeats;
         this.iVacatedSeats=iVacatedSeats;
         this.iFreedSeats=iFreedSeats;
         this.iWaitlistedSeats=iWaitlistedSeats;
         this.iAvailableSeats=iAvailableSeats;
         this.iTotalCapacity=iTotalCapacity;
    }
    
    }

    /*************************************************************
    @Method Name = doSave;
    @Purpose = To save data send by CC_Manage_Allotment component
    @Parameters = Application Detail JSON String
    @return = String
    ***************************************************************/
    @AuraEnabled
    public static string doSave(String sJSON, Boolean bIsCreateTask,String sTaskIdToClose,String sWaiverPrg){
        String retString = '';
       
            
        try{
            System.debug('sJSON:'+sJSON);
            System.debug('bIsCreateTask:'+bIsCreateTask);
            System.debug('sTaskIdToClose:'+sTaskIdToClose);
            CC_Application_Detail__c objAppDetails = (CC_Application_Detail__c)JSON.deserialize(sJSON, CC_Application_Detail__c.class);
            system.debug(objAppDetails);
            
            update objAppDetails;
            Map<String,String> mapTask = new Map<String,String>();
            mapTask.put('DT_Master_Record_Id__c', objAppDetails.Related_Application__c);
			mapTask.put('Contact__c', objAppDetails.Related_Application__r.CC_Individual__c);
            mapTask.put('Application__c', objAppDetails.Related_Application__c);
            mapTask.put('DT_Comments__c', objAppDetails.Capacity_Review_Comments__c);
            //Start[Akshay 4-Jan-18]:Changes for waitlist behavior
            if(objAppDetails.Capacity_Review_Action__c==System.Label.CC_LABEL_RESERVED_CAPACITY && bIsCreateTask){
               System.debug('Reserved Action');
                if( String.isNotBlank(sTaskIdToClose)){
                    
                    System.debug('Creting Enrollment Program');
                    CC_Enrolled_Program__c enrolledPrgObj=new CC_Enrolled_Program__c();
                    enrolledPrgObj.Program_Detail__c=objAppDetails.Program_Detail__c;
                    enrolledPrgObj.Individual__c=objAppDetails.Related_Application__r.CC_Individual__c;
                    enrolledPrgObj.Status__c=System.Label.CC_LABEL_RESERVED;
                    try{
                        insert enrolledPrgObj;
                    }
                    catch(System.DmlException e){
                        System.debug('EX msg-->' +e.getMessage());
                        if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                            return System.Label.CC_LABEL_NOT_ENOUGH_SEATS;
                        }
                        throw e;
                    }
                    
                      
                    objAppDetails.Enrolled_Program__c=enrolledPrgObj.Id;
                    objAppDetails.Status__c=System.Label.CC_LABEL_CAPACITY_RESERVED;
                    update objAppDetails;
                            
                    
                    mapTask.put('Enrolled_Program__c', objAppDetails.Enrolled_Program__c);
                            
                    DT_TaskResponseWrapper objResponse = DT_TaskAssignment.executeTaskRules(objAppDetails.Enrolled_Program__c,mapTask,sTaskIdToClose);
                    System.debug('objResponse: ' + objResponse);
                }else{
                    System.debug('updating Enrollment Program');
                    CC_Enrolled_Program__c enrolledPrgObj=new CC_Enrolled_Program__c();
                    enrolledPrgObj.Id = objAppDetails.Enrolled_Program__c;
                    enrolledPrgObj.Program_Detail__c=objAppDetails.Program_Detail__c;
                    enrolledPrgObj.Status__c=System.Label.CC_LABEL_RESERVED;
                    try{
                        update enrolledPrgObj;
                    }
                    catch(System.DmlException e){
                        System.debug('EX msg-->' +e.getMessage());
                        if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                            return System.Label.CC_LABEL_NOT_ENOUGH_SEATS;
                        }
                        throw e;
                    }
                    
                      
                    objAppDetails.Enrolled_Program__c=enrolledPrgObj.Id;
                    objAppDetails.Status__c=System.Label.CC_LABEL_CAPACITY_RESERVED;
                    update objAppDetails;
                }
            }

            if(objAppDetails.Capacity_Review_Action__c==System.Label.CC_LABEL_ADD_TO_WAITLIST && bIsCreateTask)
            {
               System.debug('Waitlisted Submission');
               
               if( String.isNotBlank(sTaskIdToClose)){
                CC_Enrolled_Program__c enrolledPrgObj=new CC_Enrolled_Program__c();
                enrolledPrgObj.Program_Detail__c=objAppDetails.Program_Detail__c;
                enrolledPrgObj.Individual__c=objAppDetails.Related_Application__r.CC_Individual__c;
                enrolledPrgObj.Status__c=System.Label.CC_PGM_STATUS_WAITLISTED;
                insert enrolledPrgObj;
                  
                objAppDetails.Enrolled_Program__c=enrolledPrgObj.Id;
                objAppDetails.Status__c=System.Label.CC_PGM_STATUS_WAITLISTED;
                update objAppDetails;
            
                mapTask.put('Enrolled_Program__c', objAppDetails.Enrolled_Program__c);
                        
                DT_TaskResponseWrapper objResponse = DT_TaskAssignment.executeTaskRules(objAppDetails.Enrolled_Program__c,mapTask,sTaskIdToClose);
                System.debug('objResponse: ' + objResponse);
                
                }else{//update enrollment for waitlisted
                    CC_Enrolled_Program__c enrolledPrgObj=new CC_Enrolled_Program__c();
                    enrolledPrgObj.Id=objAppDetails.Enrolled_Program__c;
                    enrolledPrgObj.Program_Detail__c=objAppDetails.Program_Detail__c;
                    enrolledPrgObj.Status__c=System.Label.CC_PGM_STATUS_WAITLISTED;
                    update enrolledPrgObj;
                }

                if(objAppDetails.Meet_For_Another_Waiver_Program__c){
                    String sAppDetId=CC_TargetingCriteriaController.createAppDetailAndTask(objAppDetails.Related_Application__c,objAppDetails.Id,sWaiverPrg,mapTask,sTaskIdToClose);
                    System.debug('sAppDetId: ' + sAppDetId);
                }
                
            }
            //Freed scenario
            if(objAppDetails.Capacity_Review_Action__c==System.Label.CC_Capacity_Review_Action_Freed && bIsCreateTask){
                CC_Enrolled_Program__c enrolledPrgObj=new CC_Enrolled_Program__c();
                enrolledPrgObj.Id = objAppDetails.Enrolled_Program__c;
                enrolledPrgObj.Status__c=System.Label.CC_Enrolled_Program_Status_Freed;
                update enrolledPrgObj;

                objAppDetails.Enrolled_Program__c=enrolledPrgObj.Id;
                objAppDetails.Status__c=System.Label.CC_Capacity_Review_Status_Disenrolled;
                update objAppDetails;
            }  
                
            
            
            /*else if(objAppDetails.Capacity_Review_Action__c==System.Label.CC_LABEL_ADD_TO_WAITLIST && !objAppDetails.Meet_For_Another_Waiver_Program__c && bIsCreateTask)
            {
                    CC_Enrolled_Program__c enrolledPrgObj=new CC_Enrolled_Program__c();
                    enrolledPrgObj.Program_Detail__c=objAppDetails.Program_Detail__c;
                    enrolledPrgObj.Individual__c=objAppDetails.Related_Application__r.CC_Individual__c;
                    enrolledPrgObj.Status__c=System.Label.CC_PGM_STATUS_WAITLISTED;
                    insert enrolledPrgObj;
                      
                    objAppDetails.Enrolled_Program__c=enrolledPrgObj.Id;
                    objAppDetails.Status__c=System.Label.CC_PGM_STATUS_WAITLISTED;
                    update objAppDetails;
                
                    mapTask.put('Enrolled_Program__c', objAppDetails.Enrolled_Program__c);
                            
                    DT_TaskResponseWrapper objResponse = DT_TaskAssignment.executeTaskRules(objAppDetails.Enrolled_Program__c,mapTask,sTaskIdToClose);
                    System.debug('objResponse: ' + objResponse);
            }*/
            //End[Akshay 4-Jan-18]:Changes for waitlist behavior
            
                
      retString = 'Success';
        }catch(Exception e){
            retString = 'Fail';
            System.debug('Exception on Class : CC_ManageAllotment - doSave, Error : ' +
                         e.getMessage() +
                         ' Line Number : ' +
                         e.getLineNumber() +
                         ' Cause : ' +
                         e.getCause() +
                         ' Type : ' +
                         e.getTypeName());
            
        }
         return retString;
        
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
        mapLabels.put('Select_Waiver_Targeting_Cretria',System.Label.Select_Waiver_Targeting_Cretria);
        mapLabels.put('CC_I_Don_t_Know',System.Label.CC_I_Don_t_Know);
        mapLabels.put('CC_Yes',System.Label.CC_Yes);
        mapLabels.put('CC_RT_Program',System.Label.CC_RT_Program);
        mapLabels.put('CC_LABEL_TOTAL_WAIVER_CAPACITY',System.Label.CC_LABEL_TOTAL_WAIVER_CAPACITY);
        mapLabels.put('CC_LABEL_CURRENTLY_ENROLLED',System.Label.CC_LABEL_CURRENTLY_ENROLLED);
        mapLabels.put('CC_Label_Comments',System.Label.CC_Label_Comments);
        mapLabels.put('CC_Label_AnotherTargetingCriteria',System.Label.CC_Label_AnotherTargetingCriteria);
        mapLabels.put('CC_LABEL_WAIVER_CAPACITY_ACTIONS',System.Label.CC_LABEL_WAIVER_CAPACITY_ACTIONS);
        mapLabels.put('CC_LABEL_RESERVE_CATEGORY',System.Label.CC_LABEL_RESERVE_CATEGORY);
        mapLabels.put('CC_LABEL_WHICH_WAIVER',System.Label.CC_LABEL_WHICH_WAIVER);
        mapLabels.put('CC_LABEL_MANAGE_ALLOTMENT',System.Label.CC_LABEL_MANAGE_ALLOTMENT);
        mapLabels.put('CC_ERR_SELECT_A_PROGRAM',System.Label.CC_ERR_SELECT_A_PROGRAM);
        mapLabels.put('CC_Err_Please_Enter_Comments',System.Label.CC_Err_Please_Enter_Comments);
        mapLabels.put('CC_ERR_RESERVE_CATEGORY',System.Label.CC_ERR_RESERVE_CATEGORY);
        mapLabels.put('CC_ERR_WAIVER_CAPACITY_ACTION',System.Label.CC_ERR_WAIVER_CAPACITY_ACTION);
        mapLabels.put('CC_LABEL_TOTAL',System.Label.CC_LABEL_TOTAL);
        mapLabels.put('CC_LABEL_ADD_TO_WAITLIST',System.Label.CC_LABEL_ADD_TO_WAITLIST);
        mapLabels.put('CC_LABEL_RESERVED_CAPACITY',System.Label.CC_LABEL_RESERVED_CAPACITY);
        mapLabels.put('CC_LABEL_CAPACITY_RESERVED', System.Label.CC_LABEL_CAPACITY_RESERVED);
        mapLabels.put('CC_LABEL_NOT_ENOUGH_SEATS', System.Label.CC_LABEL_NOT_ENOUGH_SEATS);
        
        
        return mapLabels;
    }
    
    
    
}