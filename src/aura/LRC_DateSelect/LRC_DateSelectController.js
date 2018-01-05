({
    init : function(component, event, helper) {
        helper.init(component, event);
        
        
    },
    handleSelectChange: function(component, event, helper) {
        
        console.log("Changing");
        try{
            var target = event.currentTarget;
            var compEvent = component.getEvent("selectChange");
            compEvent.setParams({ "data": target.value });
            compEvent.fire();
        }
        catch(e){
            console.log(e.stack, true); 
        }
    }
})