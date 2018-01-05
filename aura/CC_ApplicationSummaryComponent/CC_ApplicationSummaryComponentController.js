({
	doInit : function(component, event, helper) {
		helper.loadPage(component, event);
	},
    save : function(component, event, helper){
         if(event.getParam("arguments"))
           helper.saveMaster(component,event,event.getParam("arguments").callback);
        else
           helper.saveMaster(component,event,null);
    },
    submit : function(component, event, helper){
         if(event.getParam("arguments"))
           helper.submitMaster(component,event,event.getParam("arguments").callback);
        else
           helper.submitMaster(component,event,null);
    },
    editIndInfo : function(component, event){
        var editEvent = component.getEvent("navigateToTab");
        editEvent.setParams({"data": 'CC_ContactInformation'});
        editEvent.fire();
    },
    editRepInfo : function(component, event){
        var editEvent = component.getEvent("navigateToTab");
        editEvent.setParams({"data": 'CC_RI_Infro'});
        editEvent.fire();
    },
     editServiceRecord : function(component, event){
        var editEvent = component.getEvent("navigateToTab");
        editEvent.setParams({"data": 'CC_Services_Component'});
        editEvent.fire();
    },

    editLSRecord : function(component, event){
        var editEvent = component.getEvent("navigateToTab");
        editEvent.setParams({"data": 'CC_LivingSituation'});
        editEvent.fire();
    },

    editDocuments : function(component, event){
        var editEvent = component.getEvent("navigateToTab");
        editEvent.setParams({"data": 'CC_FileUpload_Component'});
        editEvent.fire();
    },
    openCommentModal : function(component, event){
        component.set('v.commentPassed',component.get("v.objApp").CC_Describe_why_services_are_needed__c);
        component.set('v.commentType', component.get("v.mapLabels").CC_Service_WhyServiceNeeded);
        component.set('v.isOpen',true);
    }
})