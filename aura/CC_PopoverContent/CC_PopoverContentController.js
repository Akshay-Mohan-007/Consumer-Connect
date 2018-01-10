({
    doInit: function(component, event, helper){
        
      console.log('Init');
        component.set('v.lstPrograms',[{pname:'Comprehensive Adult Support',pstatus:'Filled'},
                                     {pname:'Acquired Brain Injury',pstatus:'Closed-does not meet targeting criteria'},
                                     {pname:'Intensive Support',pstatus:'Reserved'},
                                     {pname:'Residential Support',pstatus:'Enrolled-Pending POC'}
                                    ]);
     helper.loadPageData(component, event);
        
    },
	closePopover : function(component, event, helper) {
        
        console.log("closing popover");
        //var myPopover = component.find('submissionPopover');
        //$A.util.toggleClass(myPopover, 'slds-hide');
        var myEvent = $A.get("e.c:PopoverEvent");
        myEvent.setParams({"popoverVisibility": "false"});
        myEvent.fire();
        component.find("overlayLib").notifyClose();
     }
})