({
    loadData : function(component, event){

        this.callServer(component, "c.getPageData", function(result) {                

            console.debug('JSON:', JSON.parse(result));
            var result = JSON.parse(result);
            component.set("v.mapLabels",result.MapLabelError);
            component.set("v.currentlivingSituationOptions",result.PicklistWrapper.lstCurrentLivingSituation);
            component.set("v.preferredOptions",result.PicklistWrapper.lstPreferToLive);
            component.set("v.objApplication",result.Application);

            //console.debug('objApplication:',component.get("v.objApplication"));
            console.debug('maplabels:',component.get("v.mapLabels"));
            

        },{"sAppId" : component.get("v.sAppId")});   
        
       
        
    },
    validateAndSave :  function(component, callback){
        
        var lstErrors = [];
        var mapLabels = component.get("v.mapLabels");
        
        component.set("v.bIsError",false);
        if($A.util.isEmpty(component.get("v.objApplication.CC_Where_does_the_individual_live__c"))){
            lstErrors.push(mapLabels.CC_Err_CurrentLiving);
            component.set("v.bIsError",true);
        }
        
        if(component.get("v.objApplication.CC_Where_does_the_individual_live__c") === mapLabels.CC_LBL_OTHER
             && $A.util.isEmpty(component.get("v.objApplication.CC_Explain_living_situation__c")) ){
            lstErrors.push(mapLabels.CC_Err_Explain_CurrentLiving);
            component.set("v.bIsError",true); 
        }
        
        if(component.get("v.objApplication.CC_Is_Living_Situation_Working__c") === false
            && $A.util.isEmpty(component.get("v.objApplication.CC_Where_do_you_Prefer__c"))){
            lstErrors.push(mapLabels.CC_Err_Mandatory);
            component.set("v.bIsError",true);
        }

        if(!$A.util.isEmpty(component.get("v.objApplication.CC_Where_do_you_Prefer__c"))
            && component.get("v.objApplication.CC_Where_do_you_Prefer__c") === mapLabels.CC_LBL_OTHER
            && $A.util.isEmpty(component.get("v.objApplication.CC_Explain_Where_do_you_prefer__c"))){
            lstErrors.push(mapLabels.CC_Err_Mandatory);
            component.set("v.bIsError",true);
        }

       component.set("v.lstErrors",lstErrors);
       console.debug('lstErrors:',lstErrors);

       if(callback)
            callback.call(this,lstErrors);

       if(component.get("v.lstErrors").length > 0)
           return;
        //Start: [TKT-000823] Remove event as it is not being used in the method nor is it defined
        this.saveData(component);
        //End: [TKT-000823] Remove event as it is not being used in the method nor is it defined
    },
    //Start: [TKT-000823] Remove event as it is not being used in the method nor is it defined
    saveData : function(component){
    //End: [TKT-000823] Remove event as it is not being used in the method nor is it defined  
        var obj = component.get("v.objApplication");
        var mapLabels = component.get("v.mapLabels");

        if(obj.CC_Where_does_the_individual_live__c !== mapLabels.CC_LBL_OTHER)
            obj.CC_Explain_living_situation__c = '';

        if(obj.CC_Where_do_you_Prefer__c !== mapLabels.CC_LBL_OTHER)
            obj.CC_Explain_Where_do_you_prefer__c = '';

        component.set("v.objApplication",obj);
        this.callServer(component, "c.saveApplicationData", function(result) {                
            console.debug('result is : ', result);
        },{"sJSON" : JSON.stringify(component.get("v.objApplication"))});        
    },

    resetValue : function(component, event) {
        var obj = component.get("v.objApplication");
        if(obj.CC_Is_Living_Situation_Working__c === true){
            obj.CC_Where_do_you_Prefer__c = '';
            obj.CC_Explain_Where_do_you_prefer__c = '';
            component.set("v.objApplication",obj);
        }
    }

})