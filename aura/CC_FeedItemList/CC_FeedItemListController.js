({
	doInit : function(component, event, helper) {
		helper.loadData(component);
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
  	},

  	openModalForSelected : function(component, event) {
    	component.set("v.bOpenModalForSelected",true);
  	},
  	openModalForHistoric : function(component, event) {  	
      var lstPagination = component.get("v.lstPagination"); 
      component.set("v.lstStoreAttachments",lstPagination[event.target.id].lstAttchments);
      component.set("v.bOpenModalForHistoric",true);
  	}   
})