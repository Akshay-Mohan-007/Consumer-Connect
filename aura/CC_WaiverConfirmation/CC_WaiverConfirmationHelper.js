({
    loadPage : function(component, event){
        var sAppId = component.get("v.sAppId");
        this.callServer(component, "c.loadData", 
        	function(response){
	            var objResult = JSON.parse(response);
	            if(!objResult.success){
	            	component.set("v.bHasError", true);
	            	component.set('v.lstErrors', objResult.messages);
	            	return;
	            }
	            var response = JSON.parse(objResult.response);
	            //this.consoleLog('Page loaded',false,objResult);
	            component.set("v.mapLabels",response.mapLabels);
	            component.set("v.lstPrograms",response.lstPrograms);
	            component.set("v.sComments",response.sComments);
	            component.set("v.sSuggestedProgramId",response.sSuggestedProgramId);
	            component.set("v.bIsComplete",response.bIsComplete);
	            component.set("v.bDisableYesRadio",response.bDisableYesRadio);
	        },
	        {"sAppId": sAppId}
        );
    },
    handleRadioClick : function(component, event){
        var sIsComplete = event.getSource().get("v.value");
        var bIsComplete = (sIsComplete == "true") ? true : false;
    	component.set("v.bIsComplete", bIsComplete);
    	console.log("bIsComplete>>" + component.get("v.bIsComplete"));	
    },
    validate : function(component,callback){
    	var lstErrors = [];
    	var bHasError = false;
    	component.set("v.bHasError", false);
    	component.set("v.bProgramError", false);
        component.set("v.bCommentError", false);
    	component.set('v.lstErrors',[]);
        if(component.get("v.bIsComplete") 
        	&& $A.util.isEmpty(component.get("v.sSuggestedProgramId"))){
        	bHasError = true;
        	component.set("v.bProgramError", true);
        	lstErrors.push(component.get("v.mapLabels").CC_ERR_SELECT_A_PROGRAM);
        	component.set('v.lstErrors', lstErrors);
        }
        if($A.util.isEmpty(component.get("v.sComments"))){
        	bHasError = true;
        	component.set("v.bCommentError", true);
        	lstErrors.push(component.get("v.mapLabels").CC_ERR_GIVE_COMMENTS);
        	component.set('v.lstErrors',lstErrors);
        }
        if(bHasError){
        	component.set("v.bHasError", bHasError);
    		if(callback)
    			callback.call(this,lstErrors);
    		return false;
        }
        return true;
    },
    formJSONWrapper : function(component){
        var wrapper = {};
        wrapper.sAppId = component.get("v.sAppId");
        wrapper.bIsComplete = component.get("v.bIsComplete");
        wrapper.sComments = component.get("v.sComments");
        if(wrapper.bIsComplete)
        	wrapper.sSuggestedProgramId = component.get("v.sSuggestedProgramId");
        return JSON.stringify(wrapper);
    },
    save : function(component,event){
        var callback = event.getParam("arguments").callback;
    	if(this.validate(component,callback) == false)
    		return;
        var wrapper = this.formJSONWrapper(component);
        this.saveComments(component,false);
        this.callServer(component, "c.saveData", 
        	function(response){
        		console.log(response);
        		var objResult = JSON.parse(response);
	            if(!objResult.success){
	            	for(var sKey in objResult.messages){
	            		this.showToast('Error', objResult.messages[sKey], 'error', 'pester', '200');
	            	}
	            	if(callback)
                        callback.call(this,objResult.messages);
	            } else{
	            	for(var sKey in objResult.messages){
	            		this.showToast('Success', objResult.messages[sKey], 'success', 'pester', '200');
	            	}
	            	if(callback)
                        callback.call(this,[]);
	            }
	        },
	        {"sJSON": wrapper}
        );
    },
    submit : function(component,event){
        var callback = event.getParam("arguments").callback;
    	if(this.validate(component,null) == false)
    		return;
        var wrapper = this.formJSONWrapper(component);
        
        this.callServer(component, "c.submitData", 
        	function(response){
        		console.log(response);
        		var objResult = JSON.parse(response);
	            if(!objResult.success){
	            	for(var sKey in objResult.messages){
	            		this.showToast('Error', objResult.messages[sKey], 'error', 'pester', '200');
	            	}
	            	if(callback){
	            		if($A.util.isEmpty(objResult.messages))
	            			callback.call(this,["CC_FileUpload_Component"]);
	            		else
	            			callback.call(this,["CC_WaiverConfirmation"]);
	            	}
	            } else{
                    for(var sKey in objResult.messages){
	            		this.showToast('Success', objResult.messages[sKey], 'success', 'sticky', '200');
	            	}
                    this.saveComments(component,true);
	            	if(callback)
                        callback.call(this,[]);
	            }
	        },
	        {"sJSON": wrapper}
        );
    },
    saveComments : function(component,bIsSubmit){
        var commentComp = component.find("CMT_WaiverConfirmation"); 
        console.debug('Comment save:',commentComp); 
        if(!$A.util.isUndefined(commentComp) && commentComp !== null){
            commentComp.save(bIsSubmit);
        }
    }
})