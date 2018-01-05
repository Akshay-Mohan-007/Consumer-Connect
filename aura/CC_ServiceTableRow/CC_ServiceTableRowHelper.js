({
	modifyData : function(component, event) {
		var objService = component.get('v.serviceDetail');

        var name;

        if(!$A.util.isEmpty(objService.sServiceId)){
            if(objService.sServiceName === 'Other' && !$A.util.isEmpty(objService.sOtherServiceName))
                name = objService.sServiceName + ' - '+ objService.sOtherServiceName;
            else
                name = objService.sServiceName;
        }
        else
            name = objService.sOtherServiceName;
        component.set('v.sServiceName',name);

        if(!$A.util.isEmpty(objService.sCurrentlyGettingProgramName)){
            if(objService.sCurrentlyGettingProgramName === 'Other' && !$A.util.isEmpty(objService.sOtherProgName))
                component.set("v.sProgramName",objService.sCurrentlyGettingProgramName + ' - '+ objService.sOtherProgName); 
            else
                component.set("v.sProgramName",objService.sCurrentlyGettingProgramName);
        }
        else
            component.set("v.sProgramName",'NA');  
        //console.debug('objService Name',name);
		
	}
})