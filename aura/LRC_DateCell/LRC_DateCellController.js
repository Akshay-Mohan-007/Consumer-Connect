({
    
    handleClick : function(component, event, helper) {
        try{
            if(event.key === 'Enter' || event.key === undefined){
                console.log("clicked on date");
                var clickObj = component.getEvent("dateCellClick");
                clickObj.fire();
            }
        }catch(e){
            console.log(e.stack, true);
        }
    }
})