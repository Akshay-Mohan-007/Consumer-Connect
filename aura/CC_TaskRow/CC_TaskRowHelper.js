({
	redirectToNextpage : function(component, event){
		//redirects to the next page based on parent page
		this.consoleLog("redirectToNextpage");
        var row = component.get("v.row");
        var sTaskId = row.sRecordId;
        this.consoleLog("sTaskId>>" + sTaskId);
        var sSiteName = component.get("v.sSiteName");
		this.consoleLog("sSiteName>>" + sSiteName);
		var sURL = "/";
		if(sSiteName === undefined || sSiteName === null) {
	        //sURL += sTaskId;
	        var cmpEvent = $A.get("e.force:navigateToComponent");
            cmpEvent.setParams({
                componentDef: "c:CC_IndividualSummary",
                componentAttributes: {
                	sTaskId : sTaskId,
                	bShowPrograms : true
                }
            });
            cmpEvent.fire();
	    } else {
	    	var mapLabels = component.get("v.mapLabels");
	        if(sSiteName === mapLabels.CC_SITE_NAME_SELF_SERVICE)
	        	sURL += "individual-summary?sTaskId=" + sTaskId;
	        else if(sSiteName === mapLabels.CC_SITE_NAME_SERVICE_PROVIDER)
	        	sURL += "individual-summary?sTaskId=" + sTaskId;
	        this.redirectToPageURL(sURL);
	    }
	    
	},
    showModal : function(component, event){
        //var sCommentFull = event.target.getAttribute("data-val");
        var row = component.get("v.row");
        var sCommentFull = row.sComment;
        component.set('v.sComment', sCommentFull);
        component.set('v.bIsOpen', true);
    }
})