({
	validateLangData : function(component, event, helper){
		
		var params = event.getParam('arguments');
		console.debug('params',params);
        var callback;
        if (params) {
            callback = params.callback;
        }
       console.log('callback',callback);
		helper.validateLangSec(component, event, callback);
	}
})