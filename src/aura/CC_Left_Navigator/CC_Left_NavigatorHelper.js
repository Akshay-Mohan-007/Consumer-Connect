({
	doValidation : function(component,event) {
        if (event.getParam("name") === component.get("v.selectedTab")) 
            return;
        var wrapNavigationData = event.getParam("name");
        this.consoleLog('wrapNavigationData',false,wrapNavigationData);
		var navigateEvent = component.getEvent("saveDetails");
        navigateEvent.setParams({ 
            data: wrapNavigationData
         });
        navigateEvent.fire();
        event.preventDefault();
        
        /*hide comment history section*/
        //component.set('v.bshowHistoryTable',false);
        
        var toggleEvent = component.getEvent("commentToggle");
        toggleEvent.fire();
        
        /*toggle of left nav*/
        var navbar = document.getElementById('nav-bar');
        var isOpen = navbar.classList.contains('slide-in');
        
        if(isOpen)
        {
            navbar.classList.remove("slide-in");
            navbar.classList.add("slide-out");
        } 
        else {
            navbar.classList.remove("slide-out");
            navbar.classList.add("slide-in");
        }
        
	}
})