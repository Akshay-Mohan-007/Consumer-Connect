({
	toggleClass : function(component, event, helper) {
        
        helper.toggleClass(component, event);
        
       
    },
	loadPage : function(component, event, helper) {
		helper.loadData(component, event);
	},
	save : function(component, event, helper) {
		var params = event.getParam('arguments');
     	console.debug('Comment save bIsSubmit:', params.bIsSubmit);
		helper.saveData(component, event, params.bIsSubmit);
	},
	showTable : function(component, event, helper) {
		helper.showTable(component, event);
	},
    showMore : function(component, event, helper) {
		helper.showMore(component, event);
	},
    showLess : function(component, event, helper) {
		helper.showLess(component, event);
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