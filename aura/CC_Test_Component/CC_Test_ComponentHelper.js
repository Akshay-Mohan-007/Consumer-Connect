({
	loadPage : function(component, event) {

		this.consoleLog('Loading page');
		component.set('v.bShowDepenedants',false);
        this.callServer(component, "c.loadData", function(response){
                    var retObj = JSON.parse(response);
                    this.consoleLog('Page loaded',false,retObj);
                    component.set('v.mapLabels',retObj.mapLabels);
                    component.set('v.lstMainPhoneTypes',retObj.lstMainPhoneTypes);
                    component.set('v.lstOtherPhoneTypes',retObj.lstOtherPhoneTypes);
                    component.set('v.bShowDepenedants',true);
                    var mapLabels = component.get('v.mapLabels');
                    var key = 'CC_Error_Phone_No_Missing';
                    this.consoleLog('mapLabels: ',false,mapLabels[key]);
                    var blah = component.get('v.objContact');
                });

	},

	saveRecord : function(component, event) {
		var childComponent = component.find('mainPhone');
		this.consoleLog("childComponent",false,childComponent);	
	    childComponent.validate(function(result) {
	        this.consoleLog("validate complete for mainPhone",false,result);	
	        
        });
        
        childComponent = component.find('otherPhone');
		this.consoleLog("childComponent",false,childComponent);	
	    childComponent.validate(function(result) {
	        this.consoleLog("validate complete for otherPhone",false,result);	
	        
        });
	},

	showToast : function(sTitle,sMessage,sType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : sTitle,
            message : sMessage,
            duration : ' 1' ,
            key: 'info_alt',
            mode: 'dismissible',
            type: sType
        });
        toastEvent.fire();
    }
})