({
	doInit : function(component, event, helper) {
        
        
        helper.doInit(component, event);
        
        },
    
    
    fireTableRowEvent:function(component, event, helper){
        
       
        helper.fireRowEvent(component,event.getSource().get('v.value'));
        event.preventDefault();
    }
    
})