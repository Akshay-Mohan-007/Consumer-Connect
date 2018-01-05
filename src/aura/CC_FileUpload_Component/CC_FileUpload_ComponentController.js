({
	doInit : function(component, event, helper) {
		helper.loadPage(component);
	},
	checkSave : function(component, event, helper) {
		helper.saveDocument(component,event);
	},
	refreshGrid : function(component, event, helper) {
		helper.refreshDocList(component,event);
	},
	save : function(component, event, helper) {
		if(event.getParam("arguments"))
			helper.validate(component,event.getParam("arguments").callback);
		else
			helper.validate(component,null);
	}
	
})