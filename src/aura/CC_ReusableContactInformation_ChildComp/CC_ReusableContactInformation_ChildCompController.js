({ 
	validatePhnData : function(component, event, helper){
		
		var params = event.getParam('arguments');
		console.debug('params',params);
        var callback;
        if (params) {
            callback = params.callback;
        }
       console.log('callback',callback);
		helper.validatePhnSec(component, event, callback);
	}
})