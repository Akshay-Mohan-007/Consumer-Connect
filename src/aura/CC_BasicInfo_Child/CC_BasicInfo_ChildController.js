({
	doInit : function(component, event, helper) {
	    //console.debug('Child Component childDoInit');
	    helper.initPage(component);
	},
	validatePage : function(component, event, helper) {

		var params = event.getParam('arguments');
		//console.debug('params',params);
        var callback;
        if (params) {
            callback = params.callback;
        }
       	//console.debug('callback',callback);
		helper.validate(component, event, callback);
	},
	maskSSN : function(component, event, helper) {
		helper.checkAndMaskSSN(component, event, "v.sSSNDisplay", "v.sSSN");
	},
	maskConfirmSSN : function(component, event, helper) {
		helper.checkAndMaskSSN(component, event, "v.sConfirmSSNDisplay","v.sConfirmSSN");
	}
})