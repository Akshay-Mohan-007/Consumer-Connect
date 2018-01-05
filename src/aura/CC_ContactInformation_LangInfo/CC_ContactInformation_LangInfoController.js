({
	validateLangData : function(component, event, helper){
		
		var params = event.getParam('arguments');
        var callback;
        if (params) {
            callback = params.callback;
        }
		helper.validateLangSec(component, event, callback);
	}
})