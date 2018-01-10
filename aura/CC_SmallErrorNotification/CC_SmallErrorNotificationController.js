({
    doInit:function(component, event, helper) {
        
        //component.set("v.lstErrors",["This is error1","THIS IS ERROR2","THIS IS ERROR3"]);
        console.log("Loaded Error Component");
      },
    
    toggleClass : function(component, event, helper) {
        
        var section = component.find("errorAccordianSmall");
        var content = component.find("errorAccordianContentSmall");
        $A.util.toggleClass(section, "slds-is-open");
        $A.util.toggleClass(content, "slds-p-around_small");
     }
})