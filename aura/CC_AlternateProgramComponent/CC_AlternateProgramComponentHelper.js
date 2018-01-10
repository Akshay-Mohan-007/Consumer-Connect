({
	loadPage : function(component) {
		this.callServer(component, "c.getPageData", function(result) {                

			this.consoleLog('Alternate Prog-->');
            this.consoleLog(JSON.parse(result));
            var result = JSON.parse(result);
           

            if(!result.success){
            	component.set("v.bHasError", true);
            	component.set('v.lstErrors', result.messages);
            	return;
	        }

	        var response = JSON.parse(result.response);
            this.consoleLog(response);
            
            var lstAppDetails = response.lstAlternatePrograms;
            component.set("v.mapLabels",response.MapLabelError);
            var mapLabels = component.get("v.mapLabels");
            var lstColumnHeaders = [];
            lstColumnHeaders.push(mapLabels.CC_LBL_Application);
            lstColumnHeaders.push(mapLabels.CC_Label_Program_Name);
            lstColumnHeaders.push(mapLabels.CC_Urgency);
            lstColumnHeaders.push(mapLabels.CC_LBL_Allocation_Status);
            lstColumnHeaders.push(mapLabels.CC_LBL_Category);
            
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
		                    sValue: "sProgramName",
		                    sValueCSS: "",
		                    sType: "text",
		                    sIcon: ""
		                    },
		                    {
		                    sColumnName: lstColumnHeaders[2],
		                    sClass: "",
		                    sValue: "sUrgencyReason",
		                    sValueCSS: "",
		                    sType: "text",
		                    sIcon: "",
		                    },
		                    {
		                    sColumnName: lstColumnHeaders[3],
		                    sClass: "",
		                    sValue: "sStatus",
		                    sValueCSS: "",
		                    sType: "text",         
							sIcon: "",             
		                    },
		                    {
		                    sColumnName: lstColumnHeaders[4],
		                    sClass: "",
		                    sValue: "sCategory",
		                    sValueCSS: "",
		                    sType: "text",         
							sIcon: "",             
		                    }];

		   
		   component.set("v.lstHeaders",lstHeaders);
		   component.set("v.lstAppDetails",lstAppDetails);
		   component.set("v.bLoaded",true);

        },{"sAppDetailId" : component.get("v.sAppDetailId")});  
	}
})