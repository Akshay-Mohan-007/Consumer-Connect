({
	redirectToNextpage : function(component, event){
        //redirects to the next page based on parent page
        //console.log("redirectToNextpage");
        var row = component.get("v.row");
        var sAppId = row.sRecordId;
        var sConId = row.sIndividualId;
        //console.log("sAppId>>" + sAppId);
        var sSiteName = component.get("v.sSiteName");
        var mapLabels = component.get("v.mapLabels");
        //console.log("sSiteName>>" + sSiteName);
        var sURL = "";
        
        if(sSiteName === undefined || sSiteName === null) {
            var cmpEvent = $A.get("e.force:navigateToComponent");
            cmpEvent.setParams({
                componentDef: "c:CC_ApplicationContainer",
                componentAttributes: {
                	sAppId : sAppId,
                	sContactId : sConId,
                	sModule : mapLabels.CC_ApplicationIntake
                }
            });
            cmpEvent.fire();
        } else {
            if(sSiteName === mapLabels.CC_SITE_NAME_SELF_SERVICE)
                sURL = "/application?sAppId=" + sAppId + "&sContactId=" + sConId + "&sModule=" + mapLabels.CC_ApplicationIntake;
            else if(sSiteName === mapLabels.CC_SITE_NAME_SERVICE_PROVIDER)
                sURL = "/application?sAppId=" + sAppId + "&sContactId=" + sConId + "&sModule=" + mapLabels.CC_ApplicationIntake;
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": sURL
            });
            urlEvent.fire();
        }
    }
})