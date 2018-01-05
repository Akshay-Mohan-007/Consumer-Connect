({
    clearValue: function (component) {
        component.set("v.value", "");
    },

    doInit: function (component, event, helper) {
        helper.init(component);
    },

    handleDateChange: function (component, event, helper) {
        console.log("date changing");
        helper.doUpdate(component, event);
    },

    handleFocus : function (component,event, helper){
        try{
        var onFocusEvent = component.getEvent("onFocus");
        onFocusEvent.fire();
        }
        catch(e){
            console.log(e.stack, true); 
        }
    }

})