({
	handleMeetCriteria : function(component,event,helper){
    	helper.handleMeetCriteria(component,event);
    },
    handleMeetAnotherCriteria : function(component,event,helper){
    	helper.handleMeetAnotherCriteria(component,event);
    },
    doInit : function(component,event,helper) {
        helper.initpage(component, event);
    },
    save : function(component,event,helper){
        if(event.getParam("arguments"))
            helper.validate(component, event.getParam("arguments").bIsSubmit, 
                            event.getParam("arguments").callback);
        else
            helper.validate(component, true,  null);
    },
})