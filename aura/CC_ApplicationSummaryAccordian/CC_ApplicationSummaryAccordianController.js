({
	editRecord : function(component, event, helper) {
	var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
        componentDef : "c:myComponent"
         
    });
    evt.fire();
    }
})