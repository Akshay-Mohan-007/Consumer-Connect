({
    afterRender: function(component, helper) {
        try{
            helper.displayValue(component);
            return this.superAfterRender();
        }
        catch(e){
            console.log(e.stack, true); 
        }
    },
    
    rerender: function(component, helper) {
        try{
            helper.displayValue(component);
            return this.superRerender();
        }
        catch(e){
            console.log(e.stack, true); 
        }
    }
})