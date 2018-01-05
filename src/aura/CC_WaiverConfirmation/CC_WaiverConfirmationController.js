({
    doInit : function(component, event, helper) {
        helper.loadPage(component, event);
        
    },
    back : function(component, event, helper){
    
	},
	save :function(component,event,helper){
	    helper.save(component,event);
	},
	submit :function(component,event,helper){
	    helper.submit(component,event);
	},
    renderValues:function(component,event,helper){
        
    },
    handleRadioClick : function(component,event,helper){
    	helper.handleRadioClick(component,event);
    }
})