({
	doInit : function(component, event, helper) {
		helper.loadPage(component,event);
	},
    
    handleMeetCriteria : function(component,event,helper){
    	helper.handleMeetCriteria(component,event);
    },
    
    submit : function(component,event,helper){
        
         if(event.getParam("arguments"))
            
            helper.validate(component,true, event.getParam("arguments").callback);
        
        else
            helper.validate(component,true,null);
           
    },
    
    save : function(component,event,helper){
        if(event.getParam("arguments")){
            
            helper.validate(component,false, event.getParam("arguments").callback);
        }
        else
            helper.validate(component,false,null);
    },
    rowAction : function(component,event,helper){
        helper.rowClick(component,event);
    }
})