({
    doInit : function(component, event, helper){
        helper.InitPage(component, event);
    },
    
    renderDependentPicklist : function(component, event, helper){
        if(!helper.isValueChange(event))   
            return;
        helper.renderDepPicklistOptions(component,component.get("v.PhyStrState"));
    },
    
    validateAddress:function(component,event,helper)
    {   
        var callback = event.getParam("arguments").callback;
        helper.checkAddressValidity(component,callback);
    },
    
    renderAddress : function(component, event, helper){
        if(!helper.isValueChange(event))   
            return;
        helper.showHideAddress(component);
    },
    
    setBlankCounty:function(component,event,helper){

        if(!helper.isValueChange(event))   
            return;
        helper.setBlankCounty(component,component.get("v.PhyStrCounty"));
    }
})