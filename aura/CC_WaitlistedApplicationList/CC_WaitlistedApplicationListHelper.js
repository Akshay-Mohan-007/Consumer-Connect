({
    loadData : function(component) {
        //loads the page data
        //console.log("loadData");
        var params = {"sSortField" : component.get("v.sSortField"),"sSortOrder" : component.get("v.sSortOrder")};                
        this.callServer(component, "c.loadData", function(response) {
            //console.log("response>>" + response);
            var objResult = JSON.parse(response);
            if(!objResult.success){
            	component.set("v.bHasError", true);
            	component.set('v.lstErrors', objResult.messages);
            	return;
            }
            var result = JSON.parse(objResult.response);
            //console.log(result);
            var mapLabels = result.mapLabels;
            var iListSize = result.iListSize;
            var lstColumnHeaders = result.lstColumnHeaders;
            var lstTotalApps = result.lstMyApps;
            var iPageSize = result.iPageSize;
            var sSiteName = result.sSiteName;
            var iPagesPerChunk = result.iPagesPerChunk;
            var lstHeaders = [{
		                    sColumnName: lstColumnHeaders[0],
		                    sClass: "",
		                    sValue: "sAppNumber",
		                    sValueCSS: "",
		                    sType: "text",
		                    sIcon: ""
		                    },
		                    {
		                    sColumnName: lstColumnHeaders[1],
		                    sClass: "",
		                    sValue: "sIndividualName",
		                    sValueCSS: "",
		                    sType: "link",
		                    sIcon: "",
		                    sEventType: "IndividualNameClick"
		                    },
		                    {
		                    sColumnName: lstColumnHeaders[2],
		                    sClass: "",
		                    sValue: "sWLProgramName",
		                    sValueCSS: "",
		                    sType: "text",
		                    sIcon: ""  
		                    },
		                    {
		                    sColumnName: lstColumnHeaders[3],
		                    sClass: "",
		                    sValue: "sAction",
		                    sValueCSS: "",
		                    sType: "link",         
							sIcon: "",             
							sEventType: "ActionClick"  
		                    }];
	        
            component.set("v.mapLabels", mapLabels);
            component.set("v.sSiteName", sSiteName);
            component.set("v.iListSize", iListSize);
            component.set("v.lstTotalApps", lstTotalApps);
            component.set("v.iPageSize", iPageSize);
            component.set("v.iPagesPerChunk", iPagesPerChunk);
            component.set("v.iChunkSize", iPageSize * iPagesPerChunk);
            component.set("v.lstHeaders", lstHeaders);
	        
            this.updateTable(component);
        }, params);
    },
    first : function(component, event, helper) {
        //loads the first page
        //server side pagination
        //console.log("first");
        this.getDataList(component, false);
    },
    gotoSelectedPage : function(component, iSelectedPage){
        //navigate to the selected page
        //it is just client side pagination
        //console.log("gotoSelectedPage");
        component.set("v.iSelectedPage", iSelectedPage);
        component.set("v.iOffsetClient", ((iSelectedPage - 1) % component.get("v.iPagesPerChunk")) * component.get("v.iPageSize"));
        this.updateTable(component);
    },
    setVariablesAndCall : function(component, iOffset){
        //set the variables and call data list
        //console.log("setVariablesAndCall/iOffset");
        component.set("v.iOffset", iOffset);
        component.set("v.iOffsetClient", 0);
        component.set("v.iSelectedPage", (iOffset / component.get("v.iPageSize")) + 1);
        this.getDataList(component, false);
    },
    getDataList : function(component, gotoLastPage) {
        //pass the variables and call task list
        //console.log("getDataList");
        this.getAppList(component,
                        component.get("v.iOffset"), 
                        component.get("v.sSortField"), 
                        component.get("v.sSortOrder"),
                        component.get("v.sSearchText"),
                        gotoLastPage);
    },
    getAppList : function(component, iOffset, sSortField, sSortOrder, sSearchText, gotoLastPage) {
        //returns the filtered data
        //console.log("getAppList");
        var params = {"iOffset" : iOffset,"sSortField" : sSortField,"sSortOrder" : sSortOrder, "sSearchText" : sSearchText, "gotoLastPage" : gotoLastPage};
        
        this.callServer(component, "c.getMyAppListAsString", function(response) {
            //console.log("response>>" + response);
            var objResult = JSON.parse(response);
            if(!objResult.success){
            	component.set("v.bHasError", true);
            	component.set('v.lstErrors', objResult.messages);
            	return;
            }
            var result = JSON.parse(objResult.response);
            //console.log(result);
            component.set("v.iListSize", result.iListSize);
            component.set("v.lstTotalApps", result.lstApps);
            component.set("v.iOffset", result.iOffset);
            if(gotoLastPage){
                var iPageSize = component.get("v.iPageSize");
                var iTotalSize = (result.iOffset + result.iListSize);
                var iQuotient = iTotalSize % iPageSize;
                var iSelectedPage = (iQuotient > 0) ? ((iTotalSize - iQuotient) / iPageSize) + 1 : iTotalSize / iPageSize;
                component.set("v.iSelectedPage", iSelectedPage);
                var iOffsetClient = result.iListSize - (iQuotient > 0 ? iQuotient : iPageSize);
                component.set("v.iOffsetClient", iOffsetClient);
            }
            this.updateTable(component);
        }, params);
    },
    updateTable : function(component) {
        //updates the table list with pagination
        //console.log("updateTable");
        var lstApps = [], iOffset = 0, iOffsetClient = 0;
        var bIsNext = false, bIsPrev = false;
        var iPageSize = component.get("v.iPageSize");
        var iSelectedPage = component.get("v.iSelectedPage");
        var iOffsetClient = component.get("v.iOffsetClient");
        var iOffset = component.get("v.iOffset");
        var lstTotalApps = component.get("v.lstTotalApps");
        var iListSize = component.get("v.iListSize");
        var iPagesPerChunk = component.get("v.iPagesPerChunk");
        var iChunkSize = iPageSize * iPagesPerChunk;
        if((iOffsetClient + iPageSize) < iListSize){
            lstApps = lstTotalApps.slice(iOffsetClient, iOffsetClient + iPageSize);
        } else if(iOffsetClient < iListSize){
            lstApps = lstTotalApps.slice(iOffsetClient, iListSize);
        }
        component.set("v.lstApps", lstApps);
        this.updateButtons(component);
    },
    updateButtons : function(component) {
        //updates the pagination buttons
        //console.log("updateButtons");
        var iChunkSize = component.get("v.iChunkSize");
        var iOffset = component.get("v.iOffset");
        var iListSize = component.get("v.iListSize");
        if(iOffset > 0){
			component.set("v.bDisableFirst", false);
			component.set("v.bDisablePrevSet", false);
		}else{
			component.set("v.bDisableFirst", true);
			component.set("v.bDisablePrevSet", true);
		}
		if(iListSize > iChunkSize){
			component.set("v.bDisableLast", false);
			component.set("v.bDisableNextSet", false);
		}else{
			component.set("v.bDisableLast", true);
			component.set("v.bDisableNextSet", true);
		}
        this.updateSerialButtons(component, iListSize);
    },
    updateSerialButtons : function(component, iListSize){
        //updates the pagination serial buttons
        //console.log("updateSerialButtons");
        var iSelectedPage = component.get("v.iSelectedPage");
        var iPageSize = component.get("v.iPageSize");
        var iPagesPerChunk = component.get("v.iPagesPerChunk");
        iListSize = (iListSize > (iPageSize * iPagesPerChunk)) ? iListSize - 1 : iListSize;
        var iQuotient = iListSize % iPageSize;
        var iPageLimit = (iQuotient > 0) ? ((iListSize - iQuotient) / iPageSize) + 1 : iListSize / iPageSize;
        var firstPage = iSelectedPage - ((iSelectedPage % iPagesPerChunk) == 0 ? (iPagesPerChunk - 1) : (iSelectedPage % iPagesPerChunk) - 1);
        var lstPageNumbers = [];
        for(var iPageNumber = 0; iPageNumber < iPageLimit; iPageNumber++){
            lstPageNumbers[iPageNumber] = iPageNumber + firstPage;
        }
        component.set("v.lstPageNumbers", lstPageNumbers);
    },
    redirectToNextpage : function(row){
		//redirects to the next page based on parent page
		this.consoleLog("redirectToNextpage");
        var sContactId = row.sIndividualId;
        var sAppDetailId = row.sRecordId;
        var sAppId = row.sAppId;
        this.consoleLog("sAppDetailId>>" + sAppDetailId);
        this.consoleLog("sAppId>>" + sAppId);
        this.consoleLog("sContactId>>" + sContactId);
		var cmpEvent = $A.get("e.force:navigateToComponent");
        cmpEvent.setParams({
            componentDef: "c:CC_CapacityReviewContainer",
            componentAttributes: {
            	sAppDetailId : sAppDetailId,
            	sAppId : sAppId,
            	sContactId : sContactId,
            	sModule : "Capacity_Review"
            }
        });
        cmpEvent.fire();
	}
})