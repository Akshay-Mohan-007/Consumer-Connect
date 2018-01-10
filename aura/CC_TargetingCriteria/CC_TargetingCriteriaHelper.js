({
    handleMeetCriteria : function(component, event){
        var sMeetCriteria = event.getSource().get("v.value");
        var bMeetCriteria = (sMeetCriteria == "true") ? true : false;
        component.set("v.bMeetAnotherCriteria",false);
        component.set("v.bMeetCriteria", bMeetCriteria);
        //this.consoleLog("bMeetCriteria>>" + component.get("v.bMeetCriteria"));	

        if(component.get("v.bMeetCriteria"))
           component.set("v.sComments",'');
    },
    handleMeetAnotherCriteria : function(component, event){
        var sMeetAnotherCriteria = event.getSource().get("v.value");
        var bMeetAnotherCriteria = (sMeetAnotherCriteria == "true") ? true : false;
        component.set("v.bMeetAnotherCriteria", bMeetAnotherCriteria);
        //this.consoleLog("bMeetAnotherCriteria>>" + component.get("v.bMeetAnotherCriteria"));	

        var mapLabels = component.get("v.mapLabels");
        if(!component.get("v.bMeetAnotherCriteria"))
           component.set("v.sLabelComment",mapLabels.Comments_To_Application_Reviewer);
        else{
            component.set("v.sLabelComment",mapLabels.Comments_To_Capacity_Reviewer);
        } 
    },
    initpage : function(component, event) {
        
        component.set("v.bIsDataLoaded",false);
        var sAppDetailId = component.get("v.sAppDetailId");
        this.callServer(component, "c.loadApplicationDetailData", function(response) {
            var result=JSON.parse(response);
            if(!result.success){
                component.set("v.bHasError", true);
                component.set('v.lstErrors', result.messages);
                return;
            }

            var response = JSON.parse(result.response);
            this.consoleLog(response);

            component.set("v.dAppDate",response.AppDetailObj.sAppDate);
            component.set("v.sCaseId",response.AppDetailObj.sCaseId); 
            component.set("v.lWaiverProg",response.lstPrograms);
            component.set("v.lstTimeZone",response.lstTimeZone);
            component.set("v.sTimeZone",response.AppDetailObj.sTimeZone);
            component.set("v.mapLabels",response.mapUiLabels);
            component.set("v.dDate",response.AppDetailObj.dTargetingDate);
            component.set("v.sDate",response.AppDetailObj.dTargetingDate.toString());
            
            component.set("v.sAppDetailStatus",response.AppDetailObj.sAppDetailStatus);
            this.consoleLog('Time:' + response.AppDetailObj.tTime );
            
            var tTime = "";
            if(!$A.util.isEmpty(response.AppDetailObj.tTime))
                tTime = response.AppDetailObj.tTime.split(".")[0].substring(0,5); 
            
            component.set("v.sTime", tTime); 
            component.set("v.sAppId",response.AppDetailObj.sAppId);
            component.set("v.bMeetCriteria",response.AppDetailObj.bMeetCriteria);
            component.set("v.bMeetAnotherCriteria",response.AppDetailObj.bMeetAnotherCriteria);
            component.set("v.sComments",response.AppDetailObj.sComments);
            var mapLabels = component.get("v.mapLabels");
            if(!component.get("v.bMeetAnotherCriteria"))
               component.set("v.sLabelComment",mapLabels.Comments_To_Application_Reviewer);
            else{
                component.set("v.sLabelComment",mapLabels.Comments_To_Capacity_Reviewer);
            } 
            if(response.AppDetailObj.sAppDetailStatus === mapLabels.CC_PGM_STATUS_WAITLISTED){
              component.set("v.bReadOnly", true);
            }
            component.set("v.bIsDataLoaded",true);

        },{"sAppDetailId": sAppDetailId});
    },
    validate : function(component, bIsSubmit, callback){
        
        this.consoleLog(component.get("v.sWaiverProg"));
        var lstErrors = [];
        var bHasError = false;
        component.set("v.bHasError", false);
        component.set('v.lstErrors',[]);
        var bIsCreateTask = false;
        
        var sComments = component.get("v.sComments");
        var bMeetCriteria = component.get("v.bMeetCriteria");
        if( !bMeetCriteria && $A.util.isEmpty(sComments)){
            bHasError = true;
            lstErrors.push(component.get("v.mapLabels").CC_Err_Please_Enter_Comments);
        }
        if(component.get("v.bMeetAnotherCriteria") 
           && $A.util.isEmpty(component.get("v.sWaiverProg"))){
            bHasError = true;
            lstErrors.push(component.get("v.mapLabels").CC_ERR_SELECT_A_PROGRAM);
        }
        if(bMeetCriteria){
            var dDate = component.get("v.dDate");
            if(!$A.util.isEmpty(dDate)){
                if(!this.isValidDate(this.formatDOB(dDate))){
                    bHasError = true;
                    lstErrors.push(component.get("v.mapLabels").CC_Err_Enter_Valid_Date);
                }
                else  { 
                    var dToday = new Date();
                    dToday.setMilliseconds(0);
                    dToday.setSeconds(0)
                    dToday.setMinutes(0);
                    dToday.setHours(0);
                    var dTargetingDate = this.formatToJSDateObject(dDate);
                    
                    if(dTargetingDate.getTime() > dToday.getTime() ){
                        bHasError = true;
                        lstErrors.push(component.get("v.mapLabels").CC_Err_Confirm_Date_Cannot_Future_Date); 
                    }
                }
            }
            else{
                bHasError = true;
                lstErrors.push(component.get("v.mapLabels").CC_Err_Please_Enter_Confirm_Date);
            }

            //Test Datepicker comp
            var sDate = component.get("v.sDate");
            if(!$A.util.isEmpty(sDate)){
                var dToday = new Date();
                dToday.setMilliseconds(0);
                dToday.setSeconds(0)
                dToday.setMinutes(0);
                dToday.setHours(0);
                var dTargetingDate = this.formatToJSDateObject(sDate);
                
                if(dTargetingDate.getTime() > dToday.getTime() ){
                    bHasError = true;
                    lstErrors.push(component.get("v.mapLabels").CC_Err_Confirm_Date_Cannot_Future_Date); 
                }
            }
            else{
                bHasError = true;
                lstErrors.push(component.get("v.mapLabels").CC_Err_Please_Enter_Confirm_Date);
            }
            //Test Datepicker comp
            if($A.util.isEmpty(component.get("v.sTime"))){
                bHasError = true;
                lstErrors.push(component.get("v.mapLabels").CC_Err_Please_Enter_Confirm_Time);
            }
            if($A.util.isEmpty(component.get("v.sTimeZone")))
            {
                bHasError = true;
                lstErrors.push(component.get("v.mapLabels").CC_Err_Select_Time_Zone); 
            } 
        }

        component.set('v.lstErrors', lstErrors);
        if(callback && lstErrors.length > 0){
            callback.call(this,lstErrors);
        }

        if(bHasError){
            component.set("v.bHasError", bHasError);
            return;
        }

        if(!bMeetCriteria && bIsSubmit){
            bIsCreateTask = true;
            //Start[05-Jan-17]: Tell container that submit is about to happen
            if(callback)
                callback.call(this,'Submitted');
            //End[05-Jan-17]: Tell container that submit is about to happen
        }
        
        this.saveData(component,bIsCreateTask,callback);
    },
    formJSONWrapper : function(component){
        var wrapper = {};
        wrapper.sAppId = component.get("v.sAppId");
        wrapper.sAppDetailId = component.get("v.sAppDetailId");
        wrapper.bMeetCriteria = component.get("v.bMeetCriteria");
        wrapper.bMeetAnotherCriteria = component.get("v.bMeetAnotherCriteria");
        wrapper.sCaseId = component.get("v.sCaseId");
        wrapper.sTaskIdToClose=component.get("v.sTaskIdToClose");
        wrapper.sComments = component.get("v.sComments");
        wrapper.sTaskIdToClose = component.get("v.sTaskIdToClose");
        wrapper.sAppDetailStatus = component.get("v.sAppDetailStatus");
        if(wrapper.bMeetCriteria) {
            this.consoleLog(component.get("v.sTime"));

            //Test Datepicker comp
            //var dtProcessDateTime = component.get("v.dDate"); 
            var dtProcessDateTime = component.get("v.sDate");
            dtProcessDateTime = this.formatToJSDateObject(dtProcessDateTime);
            //Test Datepicker comp
            
            var sTime = component.get("v.sTime");
            var tTime= (sTime.split(':'));
            dtProcessDateTime.setHours(tTime[0]);
            dtProcessDateTime.setMinutes(tTime[1]); 
            wrapper.dtProcessDateTime =  dtProcessDateTime;
            wrapper.sTimeZone = component.get("v.sTimeZone");

        }else{
            wrapper.dtProcessDateTime = null;
            wrapper.sTimeZone = '';
        }

        return JSON.stringify(wrapper);
    },
    //Start[05-Jan-17]: Remove callback from save
    saveData : function(component,bIsCreateTask){
        
        this.consoleLog(component.get("v.sTime"));
        var wrapper = this.formJSONWrapper(component);
        var sWaiverProgId = component.get("v.sWaiverProg");
        
        this.consoleLog('sWaiverProgId:'+sWaiverProgId);
        this.consoleLog('wrapper-->');
        this.consoleLog(wrapper); 
        this.callServer(component, "c.doSave", function(response) {
                this.consoleLog('Targeting Save Response-->');
                this.consoleLog(response);
                var objResult = JSON.parse(response);
                if(!objResult.success){
                    this.consoleLog('Targeting Page Not Saved-->'+objResult.messages[0]);
                    
                }else{
                    this.consoleLog('Targeting Saved-->'+objResult.messages[0]);
                    
                    //End[05-Jan-17]: Remove callback from save
                }

            }, 
            {"sJSON"         : wrapper,
             "sWaiverProgId" : sWaiverProgId,
             "bIsSubmit"     : bIsCreateTask
            }
        );
  
    },
    
})