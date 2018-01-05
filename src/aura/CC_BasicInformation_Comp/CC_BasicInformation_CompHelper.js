({
    loadPage : function(component, event){
        this.consoleLog('Loading page',false);
        component.set('v.bLoaded',false);
        this.callServer(component, "c.getPageData", function(result) {                
            //console.debug('result:',result);
            var retObj = JSON.parse(result);     
            var lstGender = retObj.lstGenderOptions;
            var lstSuffix = retObj.lstSuffixOptions;
            console.debug('retObj:', retObj);
                
            var lstOption = [];
            lstGender.forEach(function(value,iIndex){
                var objOption = {
                    label : value,
                    value : value
                }
                
                lstOption.push(objOption);
                
            });
                
            //console.debug('MapLabelError:',retObj.MapLabelError);
            component.set("v.mapCustomMessages",retObj.MapLabelError);
            component.set("v.lstGenderOptions",lstOption);
            component.set("v.lstSuffixOptions",lstSuffix);
            component.set("v.sSiteName", retObj.SiteName);
            //console.debug('sSiteName:', component.get("v.sSiteName"));

            if(retObj.CurrentProfile === component.get("v.mapCustomMessages").CC_Self_Service_Intake_Profile) {
                //console.debug('ContactInfo:',retObj.ContactInfo);
                component.set("v.objContact",retObj.ContactInfo);
            }

            component.set('v.bLoaded',true);
        },{}); 
        
    },
    
    saveRecord : function(component, event){
        console.log('Inside saveRecord');
        component.set("v.bErrorExists",false);
        //console.debug('ObjectContact',component.get("v.objContact"));
        
        var objContactToSend = JSON.parse(JSON.stringify(component.get("v.objContact")));
        this.consoleLog('objContactToSend.CC_Gender__c:'+ objContactToSend.CC_Gender__c);

        if(Array.isArray(objContactToSend.CC_Gender__c)) 
            objContactToSend.CC_Gender__c = objContactToSend.CC_Gender__c[0];

        //console.debug('objContactToSend',JSON.stringify(objContactToSend));
        
        this.callServer(component, "c.createIndividualBasicInfo", function(result) {                
            this.consoleLog('result:'+ result);
            var returnObj = JSON.parse(result);     
            //console.debug('returnObj:', returnObj.BasicInfoResponseWrapper);
            
            if(returnObj.BasicInfoResponseWrapper.objMessage.bHasError) {
                component.set("v.bErrorExists",true); 
                var listErr = [];
                listErr.push(returnObj.BasicInfoResponseWrapper.objMessage.sMessage);
                component.set("v.lstAllPageErrors",listErr);
                return;
            }else{
                this.redirectToNextpage(component,event,returnObj.BasicInfoResponseWrapper);
            }
            

        },{"sJSON" : JSON.stringify(objContactToSend) });  
       
    },

    redirectToNextpage : function(component, event, response){
        //redirects to the next page based on parent page
        var sSiteName = component.get("v.sSiteName");
        //console.log("sSiteName>>" + sSiteName);
        var sURL = "";
        var sAppId = response.sApplicationId;
        var sConId = response.sContactId;
        var mapLabels = component.get("v.mapCustomMessages");

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