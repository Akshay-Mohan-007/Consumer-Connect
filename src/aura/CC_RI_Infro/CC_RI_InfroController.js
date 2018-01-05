({
    doInit : function(component,event,helper) {
        helper.initpage(component, event);
        helper.loadDependentPicklist(component);
    },
    save : function(component, event, helper){
        if(event.getParam("arguments"))
            helper.validate(component,event.getParam("arguments").callback);
        else
            helper.validate(component,null);
    }
    
   
 
 });