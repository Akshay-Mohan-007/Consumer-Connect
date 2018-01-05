({ 
	doInit : function(component, event, helper) { 
		helper.loadData(component);
		helper.loadDependentPicklist(component);		
	},
	
	save : function(component, event, helper){
     if(event.getParam("arguments"))
           helper.validateChildData(component,event.getParam("arguments").callback);
		else
           helper.validateChildData(component,null);
		},

})