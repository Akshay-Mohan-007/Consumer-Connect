({
    
    getDisplayValue: function(component, event, helper) {
        try{
            var params = event.getParam('arguments');
            if (params) {
                var value = params.value;
                var config = params.config;
                var callback = params.callback;
                helper.getDisplayValue(component,value, config, callback);
            }
        }catch(e){
            console.log(e.stack, true);
        }
        
    },
    
    getISOValue: function(component, event, helper) {
        try{
            var params = event.getParam('arguments');
            if (params) {
                var date = params.date;
                var config = params.config;
                var callback = params.callback;
                helper.getISOValue(date, config, callback);
            }
        }catch(e){
            console.log(e.stack, true);
        }
        
    }
})