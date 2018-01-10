({
	doInit : function(component, event, helper) {
		helper.loadData(component, event);
	}, 

	save : function(component, event, helper){
		if(event.getParam("arguments"))
           helper.saveData(component,event,event.getParam("arguments").callback);
		else
           helper.saveData(component,event,null);
	},

	delete : function(component, event, helper){

		console.log('Delete Base Comp');
		var value = event.getParam("param");
        console.log("Received component event with param = ", value);
        helper.deleteService(component, event,value);

	},

	edit : function(component, event, helper){
		
		console.log('Edit Base Comp');
		var value = event.getParam("param");
        console.log("Received component event with param = ", value);
        component.set('v.isOpen','true');
        
        var serviceModalComp = component.find("serviceModal");

        serviceModalComp.setInitialValue(value, function(result) {
	        console.log("callback for aura:method was executed");	
	        //console.debug('result:',result); 
	        helper.saveService(component, event, result);
	       	
        });

	},
	openModel : function(component, event, helper) {
        component.set('v.isOpen','true');
        var serviceModalComp = component.find("serviceModal");
        serviceModalComp.setInitialValue(null, function(result) {
	        console.log("callback for aura:method was executed");	
	        //console.debug('result:',result); 
	       	helper.saveService(component, event, result);
        });
        
	},
	showWaitList : function(component, event){
		console.log('inside showwaitlist');
		var value = component.get("v.sIsWaitRadioValue");
		var mapLabels = component.get("v.mapLabels");
		console.log('value is :'+value);
		//if(value[0] === mapLabels.CC_LBL_YES)
        if(value === mapLabels.CC_LBL_YES)    
			component.set("v.bIsWaitingListAvailable", true);
		else
			component.set("v.bIsWaitingListAvailable", false);
	},

	showHideOther : function(component, event){ 
		console.log('inside showHideOther');
		component.set("v.bIsOtherWaitingSelected",false);

        component.get("v.lstWaitingValue").forEach(function(value,iIndex){
            if(value === component.get('v.mapLabels').CC_LBL_OTHER){
                component.set("v.bIsOtherWaitingSelected",true);
	            return;
            }
        });
	},

	handleRadioButtonForYes : function(component, event){
		var bIsRadioChecked = component.get('v.bIsRadioChecked');
		if(!bIsRadioChecked)
			component.set('v.bIsRadioChecked',true);
	},

	handleRadioButtonForNo : function(component, event){
		var bIsRadioChecked = component.get('v.bIsRadioChecked');
		if(bIsRadioChecked)
			component.set('v.bIsRadioChecked',false);
	}
})