({
    doInit : function(component, event, helper) {
        
      var cmpTarget= component.find('navBar');
      $A.util.addClass(cmpTarget, 'slide-out');
      
        
    },
    validate : function(component, event, helper) {
        helper.doValidation(component,event);
    }
})