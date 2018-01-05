({
	doInit : function(component, event, helper) {
		helper.loadData(component);
	},
	changeOwner : function(component, event, helper) {
		helper.setVariablesAndCall(component, 0);
	},
	searchTask : function(component, event, helper) {
		helper.setVariablesAndCall(component, 0);
	},
	first : function(component, event, helper) {
		helper.setVariablesAndCall(component, 0);
	},
	prevSet : function(component, event, helper) {
		var iOffset = component.get("v.iOffset") - component.get("v.iChunkSize");
		helper.setVariablesAndCall(component, iOffset);
	},
	nextSet : function(component, event, helper) {
		var iOffset = component.get("v.iOffset") + component.get("v.iChunkSize");
		helper.setVariablesAndCall(component, iOffset);
	},
	last : function(component, event, helper) {
		helper.getDataList(component, true);
	},
	gotoSelectedPage : function(component, event, helper) {
		var iSelectedPage = event.getSource().get("v.name");
		helper.gotoSelectedPage(component, iSelectedPage);
	}
})