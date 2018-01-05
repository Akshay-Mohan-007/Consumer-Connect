({
	doInit : function(component) {
		var sTaskId = component.get('v.sTaskId');
		if($A.util.isEmpty(sTaskId)){
			var sParams = this.getURLQueryStringValues();
			sTaskId = sParams['sTaskId'];
			if(!$A.util.isEmpty(sTaskId)){
				component.set('v.sTaskId',sTaskId);
				component.set('v.bShowPrograms',true);
			}
		}
		this.consoleLog("sTaskId: " + sTaskId);
		this.callServer(component, "c.loadData", function(response){
        	var objResult = JSON.parse(response);
            this.consoleLog('Page loaded',false,objResult);
            component.set('v.wrapIndiv',objResult.wrapIndivData);
            component.set('v.mapLabels',objResult.mapLabels);
            component.set('v.sComponentName',objResult.sComponentName);
            component.set('v.sLoadURL',objResult.sSiteURL);
            component.set('v.bStarted',objResult.bStarted);
        },{
        	sContactId : component.get('v.sContactId'),
        	sTaskId : sTaskId,
        	bLoadPrograms : component.get('v.bShowPrograms')
        });
	},
	next : function(component) {
		this.consoleLog('In next');
		if(!component.get('v.bStarted'))
			this.callServer(component, "c.assignTaskToSelf", function(response){
				if(response === 'Success'){
					this.consoleLog('Task successfully assigned');
					this.navigateToNextPage(component);
				}else{
					this.consoleLog('Task already assigned');
					this.showToast('Error', response, 'error', 'sticky', 5000);
				}
			},{
				sTaskId: component.get('v.sTaskId')
			});
		else
			this.navigateToNextPage(component);
		
		
	},
	navigateToNextPage : function(component) {
		var sComponentName = component.get('v.sComponentName');
		var event;
		if($A.util.isEmpty(sComponentName)){
			this.consoleLog('loading URL');
			event = $A.get("e.force:navigateToURL");
            event.setParams({
                "url": component.get('v.sLoadURL')
            });
		}else{
			this.consoleLog('loading component');
			event = $A.get("e.force:navigateToComponent");
            event.setParams({
                componentDef: sComponentName,
                componentAttributes: JSON.parse(component.get('v.sLoadURL'))
            });
		}
		event.fire();
	}
})