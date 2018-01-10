({
	init : function(component, event, helper) {
		helper.loadData(component, event);
	},
	save : function(component, event, helper) {
		if(event.getParam("arguments"))
			helper.validate(component, event.getParam("arguments").callback);
		else
			helper.validate(component, null);
	}
})