({
	doInit : function(component, event, helper) {
	    //console.debug('Parent doInit');
	    helper.loadPage(component, event);
	},
	save : function(component, event, helper) {
	    //console.debug('Parent save');
	    component.set("v.bErrorExists",false); 
	    var childComponent = component.find('basicInfoId');
	    childComponent.validatePage(function(result) {
	        //console.log("callback for aura:method was executed");	
	        //console.debug('result:',result); 
	        if(result.length === 0)  {
	        	component.set("v.bErrorExists",false);
	        	component.set("v.lstAllPageErrors",null); 
	        	helper.saveRecord(component, event);
	        }
	    	else {
	    		component.set("v.bErrorExists",true); 
	    		component.set("v.lstAllPageErrors",result);
	    		return; 
	    	}
        });
	},

	
})