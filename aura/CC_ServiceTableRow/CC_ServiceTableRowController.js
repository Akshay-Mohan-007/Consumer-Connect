({
	doInit : function(component, event, helper) {
        helper.modifyData(component, event);
	},
    editRecord : function(component,event,helper) {
        
        //this function is used to pass the row data on click of edit button to CC_AddService via event
        //console.log("Edit:",component.get('v.serviceDetail'));
        
        var editRowEvent = component.getEvent("editEvent");
        editRowEvent.setParams({"param": component.get('v.serviceDetail') });
        editRowEvent.fire();
    },
    deleteRecord : function(component,event, helper){
        
        //this function is used to pass the row data on click of delete button to CC_AddService vis event
        var deleteRowEvent = component.getEvent("deleteEvent");
        deleteRowEvent.setParams({"param": component.get('v.serviceDetail') });
        deleteRowEvent.fire();        
    }
})