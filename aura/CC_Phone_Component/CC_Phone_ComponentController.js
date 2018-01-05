({
	doInit : function(component, event, helper) {
		helper.splitPhone(component);
		helper.confirmPhone(component); 
	},
    
    concatPhone:function(component,event,helper){
        helper.concatPhone(component,event,helper);
        
        
    },   
   
	validate : function(component, event, helper) {
		var callback = event.getParam("arguments").callback;
		helper.validate(component,callback);
	},
	phoneChange : function(component, event,helper) {
        helper.phoneChange(component, event,helper);

	},
	phoneConfirmChange : function(component, event, helper) {
        helper.phoneConfirmChange(component, event,helper);
		
	}


})