({
	loadPageData : function(component, event) {
        console.debug('Child loadPageData');
		var result = JSON.parse(component.get("v.sResult"));
        console.debug('result',result);
        //console.debug('DOB',this.formatDOB(result.Application.CC_Individual__r.Birthdate));
        component.set("v.sDOB",this.formatDOB(result.Application.CC_Individual__r.Birthdate));
        component.set("v.mapLabels",result.MapLabelError);
	}
})