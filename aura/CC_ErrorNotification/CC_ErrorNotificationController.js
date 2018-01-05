({
    doInit:function(component, event, helper) {
        
        //component.set("v.lstErrors",["This is error1","THIS IS ERROR2","THIS IS ERROR3"]);
        console.log("Loaded Error Component");
        var section = component.find("errorAccordian");
        var content = component.find("errorAccordianContent");
        $A.util.addClass(section, "slds-is-open");
        $A.util.addClass(content, "slds-p-around_small");
        

      },
    
    toggleClass : function(component, event, helper) {
        
        var section = component.find("errorAccordian");
        var content = component.find("errorAccordianContent");
        $A.util.toggleClass(section, "slds-is-open");
       $A.util.toggleClass(content, "slds-p-around_small");
     }
})