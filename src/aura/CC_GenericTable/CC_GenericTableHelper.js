({
	doInit : function(component, helper) {
        
        
        var tableList = component.get("v.tbody");
        var tableHeader = component.get("v.thead");
        
        console.log(tableList);
        var propName = Object.keys(tableList[0]);
        console.log(propName);
        
        component.set("v.tcol",propName);
		
	}
})