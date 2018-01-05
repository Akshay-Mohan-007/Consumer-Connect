({
	loadData : function(component,event) {
		console.debug('Inside loadData');
		 this.callServer(component, "c.getPageData", function(result) {                

            console.debug('JSON:', JSON.parse(result));
            var result = JSON.parse(result);
            if(!result.success){
                component.set("v.bIsError", true);
                component.set('v.lstErrors', result.messages);
                return;
            }
            var response = JSON.parse(result.response);
            this.consoleLog(response);

            component.set("v.mapLabels",response.MapLabelError);
            component.set("v.lstReason",response.lstReason);
            
            var objAppDetail = response.AppDetail;
            objAppDetail.Urgency_Request_Date__c = !$A.util.isEmpty(objAppDetail.Urgency_Request_Date__c)?
            										objAppDetail.Urgency_Request_Date__c: '';
            component.set("v.objAppDetail",objAppDetail);
            component.set("v.sUrgencyDateLabel",response.MapLabelError.CC_LBL_UrgencyRequestDate);
            this.consoleLog(component.get("v.objAppDetail"));
            this.consoleLog(component.get("v.sUrgencyDateLabel"));
            
            component.set("v.bLoaded",true);
        },{"sAppDetailId" : component.get("v.sAppDetailId")});   
	},

	validate : function(component,callback) {
		var lstErrors = [];
        var mapLabels = component.get("v.mapLabels");
        component.set("v.bIsError",false);

        var dtUrgencyReqDate =  component.get("v.objAppDetail.Urgency_Request_Date__c");
        if( !$A.util.isEmpty(dtUrgencyReqDate) ){
            if(!this.isValidDate(this.formatDOB(dtUrgencyReqDate))){
                lstErrors.push(mapLabels.CC_Err_Urgency_Date_Format);
            }else{
                var dToday = new Date();
                dToday.setMilliseconds(0);
                dToday.setSeconds(0)
                dToday.setMinutes(0);
                dToday.setHours(0);
                
                var dtDateUrgency= this.formatToJSDateObject(dtUrgencyReqDate);

                if(dtDateUrgency.getTime() > dToday.getTime() )
                    lstErrors.push(mapLabels.CC_LBL_UrgencyRequestDate +' '+ mapLabels.CC_Err_Cannot_Be_Future);
            }
        }else{
            lstErrors.push(mapLabels.CC_LBL_UrgencyRequestDate +' '+ mapLabels.CC_Err_Cannot_Be_Blank);
            component.set("v.bIsError",true);
        }

        var sReason = component.get("v.objAppDetail.Reason__c");
        if( $A.util.isEmpty(sReason) ){
            lstErrors.push(mapLabels.CC_LBL_Reason +' '+ mapLabels.CC_Err_Cannot_Be_Blank);
            component.set("v.bIsError",true);
        }

        var sUrgencyComment = component.get("v.objAppDetail.Urgency_Comment__c");
        if( $A.util.isEmpty(sUrgencyComment) ){
           lstErrors.push(mapLabels.CC_Label_Comments +' '+ mapLabels.CC_Err_Cannot_Be_Blank);
           component.set("v.bIsError",true);   
        }

        component.set("v.lstErrors",lstErrors);
        if(callback)
            callback.call(this,lstErrors);

       if(component.get("v.lstErrors").length > 0)
           return;

		this.saveData(component,callback);
	},

	saveData : function(component,callback) {
		this.consoleLog('Inside Save');
		var objToUpdate = component.get("v.objAppDetail");
		this.consoleLog(objToUpdate);
		this.consoleLog(component.get("v.dUrgencyDate"));
		this.callServer(component, "c.saveAppDetail", function(response) {                
   			this.consoleLog(response);
            var objResult = JSON.parse(response);
            if(!objResult.success){
                this.consoleLog('Urgency Page Not Saved');
                if(callback)
                    callback.call(this,objResult.messages);
            }else{
                this.consoleLog('Urgency Saved');
                if(callback)
                    callback.call(this,[]);
            }
            
        },{"sJSON" : JSON.stringify(objToUpdate)});
	}
})