({  
    loadData : function(component, event) { 

        var action = component.get("c.getPageDataForApplication");
        action.setParams({"sAppId" : component.get("v.sAppId")});
         
        this.callServer(component, "c.getPageDataForApplication", function(result) {                

                //console.debug('JSON:', JSON.parse(result));

                var result = JSON.parse(result);
                console.log(result);
                var lstHowSoonOptions = result.PicklistWrapper.lstHowSoonServicesNeeded;
                var mapProgNameId = result.PicklistWrapper.mapProgramNameId;
                var mapProgServices = new Map();
                mapProgServices = result.PicklistWrapper.mapProgramService;

                component.set("v.mapLabels",result.MapLabelError);
                //component.set("v.bIsOnWatingList",result.AppDetailInfo.isIndividualWaitinglist);
                component.set("v.bIsRadioChecked",result.AppDetailInfo.isIndividualWaitinglist);
				
				if($A.util.isEmpty(result.AppDetailInfo.sDescribeWhyServiceNeeded)){
					component.set("v.sWhyServiceNeeded",'');
				}else{
					component.set("v.sWhyServiceNeeded",result.AppDetailInfo.sDescribeWhyServiceNeeded);
				}
                
                component.set("v.sServicePeriod",result.AppDetailInfo.sHowSoonServiceNeeded);
                component.set("v.lstAppDetailService",result.AppDetailInfo.lstRelatedServiceDetail);
                component.set("v.lstAppDetailWaitingProg",result.AppDetailInfo.lstRelatedWaitingProgram);
                
                //console.debug('Services List:', component.get("v.lstAppDetailService"));
                //console.debug('sServicePeriod:', component.get("v.sServicePeriod"));

                component.set("v.mapProgNameId",mapProgNameId);
                component.set("v.mapProgramService",mapProgServices);
                
                var lstHowSoonOptionFinal = [];
                lstHowSoonOptions.forEach(function(value,iIndex){
                    var objOption = {
                        val : '',
                        selected : ''
                    };

                    if(value === component.get("v.sServicePeriod")){
                        objOption.val = value;
                        objOption.selected = "selected";
                    }else{
                        objOption.val = value;
                    }
                    lstHowSoonOptionFinal.push(objOption);

                });

                //console.debug('lstHowSoonOptionFinal',lstHowSoonOptionFinal);
                /*console.debug('Profile:', result.CurrentProfile);
                if(component.get("v.mapLabels").CC_APP_REVIEWER_PROFILE === result.CurrentProfile){
                    component.set("v.bIsAppReview",true);
                }*/

                component.set("v.lstServicePeriod",lstHowSoonOptionFinal);

                var lstProgramOption = [];
                console.debug('mapProgNameId List:', mapProgNameId);
                for(var key in mapProgNameId) {
                    var objOption = {
                        label : key,
                        value : key
                    }

                    lstProgramOption.push(objOption);
                }

                component.set("v.lstWaitingOptions",lstProgramOption);

                
                var lstExistingWaitlisted = component.get("v.lstAppDetailWaitingProg");
                var lstExistingWaitValue = [];

                lstExistingWaitlisted.forEach(function(value,iIndex){
                    lstExistingWaitValue.push(value.Waiting_List_Program__r.Name);
                    if(value.Waiting_List_Program__r.Name === component.get('v.mapLabels').CC_LBL_OTHER){
                        component.set("v.sOtherWaitProgName",value.Other_Program_Name__c);
                        component.set("v.bIsOtherWaitingSelected",true);
                    }
                });

                component.set("v.lstWaitingValue",lstExistingWaitValue);
                /*console.debug('lstExistingWaitlisted',lstExistingWaitlisted);
                console.debug('lstExistingWaitValue',lstExistingWaitValue);*/
                
                var lstRadioOptions = [];
                lstRadioOptions.push(component.get("v.mapLabels").CC_LBL_YES);
                lstRadioOptions.push(component.get("v.mapLabels").CC_LBL_NO);

                var lstRadioOptionsFinal = [];
                lstRadioOptions.forEach(function(value,iIndex){
                    var objOption = {
                    label : value,
                    value : value
                    }

                    lstRadioOptionsFinal.push(objOption);
                });
                
                
                component.set("v.lstIsWaitlistRadioOptions",lstRadioOptionsFinal);
                

                if(component.get("v.bIsOnWatingList") == true){
                    component.set("v.sIsWaitRadioValue",component.get("v.mapLabels").CC_LBL_YES);
                    component.set("v.bIsWaitingListAvailable",true);
                }
                else
                    component.set("v.sIsWaitRadioValue",component.get("v.mapLabels").CC_LBL_NO);

                //console.debug('RAdio:',component.get("v.sIsWaitRadioValue"));
                //console.debug('Type of bIsOnWatingList',component.get("v.bIsOnWatingList"));

        },{"sAppId" : component.get("v.sAppId")});
        $A.enqueueAction(action);
    },

    saveData : function(component, event, callback){
        console.log('save method started');
        component.set('v.lstErrors',[]);

        var lstErrors = this.validateData(component, event);
        //console.debug('lstErrors',component.get('v.lstErrors'));

        if(callback)
            callback.call(this,lstErrors);

        if(lstErrors.length !== 0){
            component.set("v.lstErrors",lstErrors);
            console.debug('within save.........error');
            console.debug('lstErrors',lstErrors);
            component.set('v.lstErrors',lstErrors);
        }
        else{
            console.debug('within save.........no error');
            //console.debug('radio button val:'+component.get("v.sIsWaitRadioValue"));
            
            var isWaitingRadioVal;
            //console.log('radio response length :'+component.get("v.sIsWaitRadioValue").length);
            var lstRadioButtonResponse = component.get("v.sIsWaitRadioValue");
            
            var lstWaitingPrograms = component.get("v.lstWaitingValue");
            //console.debug('lstWaitingPrograms:', lstWaitingPrograms);

            //if(lstRadioButtonResponse.length !== 0 && lstRadioButtonResponse[0] === 'YES')
            /*if(lstRadioButtonResponse.length !== 0 && lstRadioButtonResponse === 'YES')
                isWaitingRadioVal = true;
            else{
                isWaitingRadioVal = false;

                //clear all waiting programs when no waiting selected.
                lstWaitingPrograms = [];
                component.set("v.lstWaitingValue",lstWaitingPrograms);
            }*/
            
            if(component.get('v.bIsRadioChecked'))
                isWaitingRadioVal = true;
            else{
                isWaitingRadioVal = false;
                //clear all waiting programs when no waiting selected.
                lstWaitingPrograms = [];
                component.set("v.lstWaitingValue",lstWaitingPrograms);

            }
            console.debug('lstWaitingPrograms:', lstWaitingPrograms);

            var objApplication = {
                'sObjectType': 'CC_Application__c',
                'CC_How_soon_services_needed__c': component.get("v.sServicePeriod"),
                'CC_Describe_why_services_are_needed__c': component.get("v.sWhyServiceNeeded"),
                'CC_On_Any_Waiver_Waiting_List__c': isWaitingRadioVal,
                'Id': component.get("v.sAppId")
            };

            var sOtherComment =component.get("v.sOtherWaitProgName"); // 2nd Parameter

            /*var action = component.get("c.updateApplication");
            action.setParams({
                "objApp" : objApplication,
                "sOtherName" : sOtherComment,
                "lstWaitProgramId" : lstWaitingPrograms
             });
*/
            this.callServer(component, "c.updateApplication", function(result){
            //action.setCallback(this, function(response) {
                 // var state = response.getState();
                    console.log('result is : '+ result);
                
            }, {
                "objApp" : objApplication,
                "sOtherName" : sOtherComment,
                "lstWaitProgramId" : lstWaitingPrograms
             });
            //$A.enqueueAction(action);
        }
    },

    validateData :function(component, event){
    var waitListProgs = component.get("v.lstWaitingValue");
    var lstErrors = [];
    var mapLabels = component.get("v.mapLabels");

    component.set("v.bIsError",false);
    component.set("v.bErrIsOnWait",false);
    component.set("v.bErrNoWaitItem",false);
    
    
        if($A.util.isEmpty(component.get("v.sServicePeriod"))){
            lstErrors.push(mapLabels.CC_Err_Service_Period_Mandatory);
            component.set("v.bIsError",true);
        }
        
        if($A.util.isEmpty(component.get("v.sWhyServiceNeeded"))){
            lstErrors.push(mapLabels.CC_Err_Why_Service_Needed);
            component.set("v.bIsError",true);
        }
        if($A.util.isEmpty(component.get("v.sIsWaitRadioValue")) || component.get("v.sIsWaitRadioValue").length === 0){
            lstErrors.push(mapLabels.CC_Err_Is_Waitlisted);
            component.set("v.bErrIsOnWait",true);
        }
        
        if(component.get("v.sIsWaitRadioValue").length > 0  && component.get("v.sIsWaitRadioValue")[0]=== mapLabels.CC_LBL_YES){
            if(waitListProgs.length === 0){
                lstErrors.push(mapLabels.CC_Err_Waitlist_Services);
                component.set("v.bErrNoWaitItem",true);
            }
        }

        if(component.get("v.lstAppDetailService").length === 0 ){
            lstErrors.push(mapLabels.CC_Err_Service_Needed_Required);
        }else{

            var bFutureServiceExists = false;
            component.get("v.lstAppDetailService").forEach(function(value,iIndex){
                 if(value.bNeededInFuture) {
                    bFutureServiceExists = true;
                    return;
                 }   
            });

            if(!bFutureServiceExists)
                lstErrors.push(mapLabels.CC_Err_Service_Needed_Required);
        }

        if(waitListProgs.length > 0){
            waitListProgs.forEach(function(value,iIndex){
                 if(value === component.get('v.mapLabels').CC_LBL_OTHER && $A.util.isEmpty(component.get("v.sOtherWaitProgName"))) {
                    lstErrors.push(component.get('v.mapLabels').CC_Err_Other_Program_Name);
                    component.set("v.bIsError",true);
                    return;
                 }   
            });
        }

        console.debug('bIsError:',component.get("v.bIsError"));
        //console.debug('sServicePeriod:',component.get("v.sServicePeriod"));

        return lstErrors;
    },

    deleteService : function(component, event, obj){

        var lstOfAppIdsForDel = [];
        lstOfAppIdsForDel.push(obj.sAppdetailId);
        component.set('v.lstErrors',[]);

        this.callServer(component, "c.deleteAppDetail", function(msg){
            console.log('result is : '+ msg);
            if(msg === "Fail") {
                    console.log('Delete Fail');
                }
            else{
                console.debug('msg:', JSON.parse(msg));
                msg = JSON.parse(msg);    
                console.debug('Delete Success');
                component.set("v.lstAppDetailService",msg.lstRelatedServiceDetail);
            }
                
        }, {
             "lstAppDetailId" : lstOfAppIdsForDel,
             "sAppId" : component.get("v.sAppId")
        });
    },

    saveService : function(component, event, obj) {

        console.debug('saveService Invoked:'); 
        console.debug('obj:',obj); 

        var objService = {
            sCurrentlyGettingProgramName : '',
            sOtherProgName : obj.sOtherProgName,
            sOtherServiceName : obj.sOtherServiceName,
            sRelatedAppId : (!$A.util.isEmpty(obj.sRelatedAppId))? obj.sRelatedAppId : component.get("v.sAppId"),
            sServiceId : obj.sServiceId,
            sServiceName : '',
            bGettingCurrently : obj.bGettingCurrently,
            bNeededInFuture : obj.bNeededInFuture
        };

        if(!$A.util.isEmpty(obj.sAppdetailId)) {
            objService.sAppdetailId = obj.sAppdetailId;
        }

        console.debug('objService:',objService); 
        this.callServer(component, "c.addAppDetail", function(msg){

            component.set('v.isOpen',false);
            component.set('v.lstErrors',[]);

            console.log('result is : '+ msg);
            if(msg === "Fail") {
                console.debug('Error Saving the data:' +msg);
            }
            else{
               console.debug('Saved'); 
               console.debug('msg:', JSON.parse(msg));
               msg = JSON.parse(msg);   
               component.set("v.lstAppDetailService",msg.lstRelatedServiceDetail);
            }
                
        }, {
             "sJSON" : JSON.stringify(objService)
        });    
    }


})