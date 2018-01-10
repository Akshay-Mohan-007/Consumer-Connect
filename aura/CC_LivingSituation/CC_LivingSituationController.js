({
	doInit: function (component, event, helper) {
        helper.loadData(component, event);
    },
    save: function(component, event, helper) {
    	if(event.getParam("arguments"))
           helper.validateAndSave(component,event.getParam("arguments").callback);
		else
           helper.validateAndSave(component,null);
    },
    resetFields : function(component, event, helper) {
    	helper.resetValue(component, event);
    }
    
})