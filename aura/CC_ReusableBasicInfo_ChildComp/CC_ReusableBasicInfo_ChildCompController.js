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
		var sFieldName = event.getSource().get("v.name")
		console.log('maskSSN ' +sFieldName);
		helper.checkAndMaskSSN(component, event, sFieldName);
	},
	check : function(component, event, helper) {
		var inputField = component.find('lastNameId');
		console.log('inputField:'+inputField);
	    var value = component.get('v.sLastName');
	    inputField.set('v.validity', {valid:false, badInput :true});
	    /*if(value == '') {
	        inputField.set('v.validity', {valid:false, badInput :true});
	    }*/
	}
})