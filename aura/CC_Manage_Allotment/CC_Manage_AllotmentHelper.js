({
    loadPage : function(component,event) {
        
        component.set("v.bIsDataLoaded",false);
        var sAppDetId=component.get("v.sAppDetId");
        var tHead=[{
            sColumnName: 'Category',
            sClass :'',
            sValue :'sName',
            sValueCSS: '',
            sType:'text',
            sIcon:''
        },
                   {
                       sColumnName: 'Available',
                       sClass :'',
                       sValue :'iAvailableSeats',
                       sValueCSS: '',
                       sType:'text',
                       sIcon:''
                   },
                   {
                       sColumnName: 'Reserved',
                       sClass :'',
                       sValue :'iReservedSeats',
                       sValueCSS: '',
                       sType:'text',
                       sIcon:''  
                   },
                   {
                       sColumnName: 'Vacated',
                       sClass :'',
                       sValue :'iVacatedSeats',
                       sValueCSS: '',
                       sType:'text',
                       sIcon:''  
                   },
                   {
                       sColumnName: 'Freed',
                       sClass :'',
                       sValue :'iFreedSeats',
                       sValueCSS: '',
                       sType:'text',
                       sIcon:''  
                   },
                   {
                       sColumnName: 'Waitlisted',
                       sClass :'',
                       sValue :'iWaitlistedSeats',
                       sValueCSS: '',
                       sType:'link',
                       sEventType:'waitlist'
                   },
                   {
                       sColumnName: 'Total',
                       sClass :'',
                       sValue :'iTotalCapacity',
                       sValueCSS: '',
                       sType:'text',
                       sIcon:''           
                   }];
        
        this.callServer(component, "c.loadData", function(response) {
            var responseWrap=JSON.parse(response);
            var result = JSON.parse(responseWrap.response);
            
            
            //component.set("v.sRespWrapper",result);
            //var responseWrapper=component.get("v.sRespWrapper");
            component.set("v.ProgramName",result.WrapperProgDetail.ProgramName);
            component.set("v.TotalAvailableWaiverCapacity",result.WrapperProgDetail.TotalAvailableWaiverCapacity);
            component.set("v.CurrentlyEnrolled",result.WrapperProgDetail.CurrentlyEnrolled);
            component.set("v.objBody",result.WrapperProgDetail.lstProgramDetailWrapper);
            component.set("v.mapLabels",result.mapUiLabels);
            component.set("v.lWaiverCapacityAct",result.lstWaiverCapacityActions);
            component.set("v.AppDetObj",result.appDetObj)
            component.set("v.lProgDetail",result.lstPrgDetail);
            component.set("v.lWaiverProg",result.lstWaiverProg);
            component.set("v.objHeader",tHead);
            
            
            component.set("v.bIsDataLoaded",true);
            
        },{
            "sAppDetId": sAppDetId
        });
    },
    
    handleMeetCriteria : function(component,event)  {
        
        var sMeetCriteria = event.getSource().get("v.value");
        var bMeetCriteria = (sMeetCriteria == "true") ? true : false;
        //component.set("v.bMeetAnotherCriteria",false);
        component.set("v.AppDetObj.Meet_For_Another_Waiver_Program__c", bMeetCriteria);
        
    },
    
    validate : function(component,bIsCreateTask,callback){
        
        var lstErrors = [];
        var bHasError = false;
        component.set("v.bHasError", false);
        component.set("v.lstErrors", []);
        
        var wavCapacityAct = component.get("v.AppDetObj.Capacity_Review_Action__c");
        var resCategory=component.get("v.mapLabels").CC_LABEL_ADD_TO_WAITLIST;
        var addtoWailtlist=component.get("v.mapLabels").CC_LABEL_RESERVED_CAPACITY;
        var bMeetAnotherCriteria=component.get("v.AppDetObj.Meet_For_Another_Waiver_Program__c");
        var appDetObj=component.get("v.AppDetObj");
        
        if( $A.util.isEmpty(wavCapacityAct)){
            bHasError = true;
            lstErrors.push(component.get("v.mapLabels").CC_ERR_WAIVER_CAPACITY_ACTION);
            component.set('v.lstErrors', lstErrors);
        }
        
        var resCategory = component.get("v.AppDetObj.Program_Detail__c");
        
        if(!$A.util.isEmpty(wavCapacityAct) && $A.util.isEmpty(resCategory)){
            bHasError = true;
            lstErrors.push(component.get("v.mapLabels").CC_ERR_RESERVE_CATEGORY);
            component.set('v.lstErrors', lstErrors);
        }
        
        var waiverPrg= component.get("v.sWaiverPrg");
        
        if(wavCapacityAct == 'Add to Waitlist' && $A.util.isEmpty(waiverPrg) && bMeetAnotherCriteria){
            bHasError = true;
            lstErrors.push(component.get("v.mapLabels").CC_ERR_SELECT_A_PROGRAM);
            component.set('v.lstErrors', lstErrors);
        }
        
        var sComments=component.get("v.AppDetObj.Capacity_Review_Action_Comments__c")
        if($A.util.isEmpty(sComments)){
            bHasError = true;
            lstErrors.push(component.get("v.mapLabels").CC_Err_Please_Enter_Comments);
            component.set('v.lstErrors', lstErrors);
            
        }
        
        if(bIsCreateTask && !bHasError){
            if(!$A.util.isEmpty(appDetObj.Visited_Pages__c) && appDetObj.Visited_Pages__c.includes('Targeting Criteria') 
               && appDetObj.Visited_Pages__c.includes('Urgency of Need')){
                
            }
            else{
                var lstVist = [];
                if($A.util.isEmpty(appDetObj.Visited_Pages__c) || !appDetObj.Visited_Pages__c.includes('Targeting Criteria'))
                    lstVist.push('CC_UrgencyComponent');
                if(!$A.util.isEmpty(appDetObj.Visited_Pages__c) && !appDetObj.Visited_Pages__c.includes('Urgency of Need'))
                    lstVist.push('CC_TargetingCriteria');
                if(callback)
                    callback.call(this,lstVist);
            }
        }
        else if(callback)
            callback.call(this,lstErrors);
        
        if(bHasError){
            component.set("v.bHasError", bHasError);
            return;
        }
        
        this.saveData(component,bIsCreateTask,callback);
    },
    
    saveData:function(component,bIsCreateTask,callback){
        //this.ConsoleLog('In Save..');
        var appObj=component.get("v.AppDetObj");
        var sWaiverPrg=component.get("v.sWaiverPrg");
        var sTaskIdToClose=component.get("v.sTaskIdToClose")
        
        
        this.callServer(component, "c.doSave", 
                        function(response) {
                            this.consoleLog(response);
                            if(response!='Success'){
                                //this.showToast('Error',response,'error','sticky',200);
                                alert(response);
                                return
                            }
                           if(callback && bIsCreateTask)
                    		callback.call(this,[]);
                        },
                        {"sJSON"      : JSON.stringify(appObj),
                         "bIsCreateTask": bIsCreateTask,
                         "sTaskIdToClose" :sTaskIdToClose,
                         "sWaiverPrg" :sWaiverPrg}); 
        
    },
    
    rowClick:function(component,event){
        var sAction = event.getParam("action");
        var wrapRow = event.getParam("wrapData");
        this.consoleLog('Row click event: '+sAction);
        this.consoleLog('Row data: ',false,wrapRow);
        if(sAction === 'waitlist'){
            var modalBody;
            var baseComp = component.getSuper();
            $A.createComponent("c:CC_WaitlistGridComponent", 
                               {"sProgramName" : component.get('v.ProgramName'),"sProgramDetailId" : wrapRow.sId},
                               function(content, status) {
                                   if (status === "SUCCESS") {
                                       modalBody = content;
                                       baseComp.find('overlayLib').showCustomModal({
                                           body: modalBody, 
                                           referenceSelector: ".waitPopover",
                                           showCloseButton: true,
                                           cssClass: "slds-modal slds-modal_large",
                                           closeCallback: function() {
                                               helper.consoleLog('closed pop over');
                                           }
                                       })
                                   }
                               });
        }
    }
    
})