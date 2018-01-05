({
	loadPage : function(component) {
		var sProgramId = component.get('v.sProgramId');
		var sProgramDetailId = component.get('v.sProgramDetailId');
		this.consoleLog("sProgramId: " + sProgramId);
		this.consoleLog("sProgramDetailId: " + sProgramDetailId);
		this.callServer(component, "c.loadData", function(response){
			var result = JSON.parse(response);
			this.consoleLog('result',false,result);
			if(result.success){
				var objResponse = JSON.parse(result.response);
				this.consoleLog('objResponse',false,objResponse);
				component.set('v.lstUrgency',objResponse.lstProgramDetails);
				component.set('v.mapLabels',objResponse.mapLabels);
				this.setHeaders(component,objResponse.mapLabels);
				component.set('v.lstIndiv',objResponse.lstWaitList);
				
			}else{
				this.showToast('Error', 'Unexpected Error: '+result.response,'error','sticky',200);
			}
		},{
			sProgramId : sProgramId,
			sProgramDetailID : sProgramDetailId
		});
		
	},
	filter : function(component) {
		var sProgramId = component.get('v.sProgramId');
		var sProgramDetailId = component.get('v.sProgramDetailId');
		this.consoleLog("sProgramId: " + sProgramId);
		this.consoleLog("sProgramDetailId: " + sProgramDetailId);
		component.set('v.lstIndiv',[]);
		this.callServer(component, "c.refreshGrid", function(response){
			var result = JSON.parse(response);
			this.consoleLog('result',false,result);
			if(result.success){
				var objResponse = JSON.parse(result.response);
				this.consoleLog('objResponse',false,objResponse);
				component.set('v.lstIndiv',objResponse.lstWaitList);
			}else{
				this.showToast('Error', 'Unexpected Error: '+result.response,'error','sticky',200);
			}
		},{
			sProgramId : sProgramId,
			sProgramDetailID : sProgramDetailId
		});
	},
	setHeaders : function(component,mapLabels){
		var lstHeaders = [{	
			sColumnName: mapLabels.CC_INDIVIDUAL_NAME,
	        sClass :'',
	        sValue :'sName',
	        sValueCSS: '',
	        sType:'text'
	        },{
	        sColumnName: mapLabels.CC_LBL_Category,
	        sClass :'',
	        sValue :'sUrgency',
	        sValueCSS: '',
	        sType:'text'
	    }];
	    component.set('v.lstHeaders',lstHeaders);
	}
})