({
    doInit : function(component, event, helper) {
      console.debug('doinit');
      helper.loadPagedata(component, event); 
        
     
    
      },
    handleShowPopover : function(component, event, helper) {
        helper.showPopOver(component, event);
        
    },
    popoverInit:function(component,event,helper){
         helper.popoverInit(component, event);
    },
    toggleMenu:function(component, event, helper) {
        
        
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