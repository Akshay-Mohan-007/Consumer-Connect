({ 
    
    initpage : function(component, event) {
        
        
        
        var strAppId = component.get("v.strAppId");
        
        component.set("v.bIsDataLoaded",false);
        this.callServer(component, "c.loadContactData", function(response) { 
            var result=JSON.parse(response);
            
            
            
            if(result.appInf.CC_Does_Individual_have_Auth_Rep__c){
                component.set("v.rDetailshide",'true');
                
            }
            else{
                component.set("v.rDetailshide","false");
            }
            
            if(result.appInf.CC_individual_have_LegalGuardian__c)               
                component.set("v.gDetailshide","true")            
                else
                    component.set("v.gDetailshide","false");
            
            
            if(result.appInf.CC_You_Your_Rep_LiveAt_Same_Place__c)
                component.set("v.LiveInSamePlaceValueRep","true");
            else
                component.set("v.LiveInSamePlaceValueRep","false");
            if(result.appInf.CC_You_Your_Guardian_LiveAt_Same_Place__c)
                component.set("v.LiveInSamePlaceValueLeg","true");
            else
                component.set("v.LiveInSamePlaceValueLeg","false");
            
            
            if((result.appInf.CC_Individual_Also_Your_Legal_Guardian__c) && (result.appInf.CC_individual_have_LegalGuardian__c) && (result.appInf.CC_Does_Individual_have_Auth_Rep__c))
                component.set("v.gDetailshide2","false");                
            else
                component.set("v.gDetailshide2","true");    
            
            component.set("v.bBothAddressSameForRep",result.repconObj.CC_Same_as_physical_address__c);
            component.set("v.bBothAddressSameForLeg",result.legconObj.CC_Same_as_physical_address__c);
            component.set("v.appInfo",result.appInf);
            component.set("v.repContactInfo",result.repconObj);
            component.set("v.legContactInfo",result.legconObj);
            component.set("v.lstMainPhnType",result.phonePickList.lstMainPhoneTypes);
            component.set("v.lstOtherPhnType",result.phonePickList.lstOtherPhoneTypes);
            component.set("v.lstPhyState",result.phonePickList.lstAddStates);
            component.set("v.lstPreferredLanguage",result.phonePickList.lstPreferredLanguage);
            component.set("v.lstSuffix",result.phonePickList.lstSuffix);
            component.set("v.lstRelatedToIndividual",result.phonePickList.lstRltntype);
            component.set("v.mapLabels",result.mapUiLabels);
            
            var opt1 = [
                { value: 'true', label: result.mapUiLabels.CC_LBL_YES },
                { value: 'false',label: result.mapUiLabels.CC_LBL_NO }
            ];
            var opt2 = [
                { value: 'true', label: result.mapUiLabels.CC_LBL_YES },
                { value: 'false',label: result.mapUiLabels.CC_LBL_NO }
            ];
            var opt3 = [
                { value: 'false', label: result.mapUiLabels.CC_LBL_YES },
                { value: 'true',label: result.mapUiLabels.CC_LBL_NO }
            ];
            component.set("v.options1", opt1);
            component.set("v.options2", opt1);
            component.set("v.options3", opt3);
            component.set("v.lLiveInSamePlace", opt2);
            component.set("v.bIsDataLoaded",true);
            
            
        },{"strAppId": strAppId});
        
        
        
        
    },
    
    
    
    savepage:function(component, event){
        
        
        
        var appObj=component.get("v.appInfo");
        var conObj=component.get("v.repContactInfo");
        var legCon=component.get("v.legContactInfo");
        
        this.callServer(component, "c.doSave", function(response) {
            
            
            var result=JSON.parse(response);
            component.set("v.appInfo",result.appInf);
            component.set("v.repContactInfo",result.repconObj);
            component.set("v.legContactInfo",result.legconObj);
            
            
        },              
                        {"sRepContact": JSON.stringify(conObj),
                         "sLegContact": JSON.stringify(legCon),
                         "sAppObj": JSON.stringify(appObj)}); 
        
    },
    
    validate : function(component, callback)    
    {
        component.set("v.bIsError",false);
        component.set("v.lstAllError",[]);
        var lstAllError = [];
        
        
        
        var bHasRep = component.get("v.rDetailshide") == 'true';
        var bHasLG = component.get("v.gDetailshide") == 'true';
        component.set("v.appInfo.CC_Does_Individual_have_Auth_Rep__c",bHasRep? true:false);
        
        component.set("v.appInfo.CC_individual_have_LegalGuardian__c",bHasLG? true:false);
        
        if(bHasRep)
            component.set("v.appInfo.CC_You_Your_Rep_LiveAt_Same_Place__c",component.get("v.LiveInSamePlaceValueRep") == 'true'? true:false);
        else
            component.set("v.appInfo.CC_You_Your_Rep_LiveAt_Same_Place__c",false);
        
        
        if(bHasLG){
            component.set("v.appInfo.CC_You_Your_Guardian_LiveAt_Same_Place__c",component.get("v.LiveInSamePlaceValueLeg") == 'true'? true:false);      
            if(bHasRep)
                component.set("v.appInfo.CC_Individual_Also_Your_Legal_Guardian__c",component.get("v.gDetailshide2" )== 'true' ? false : true);
            else
                component.set("v.appInfo.CC_Individual_Also_Your_Legal_Guardian__c",false);
        }
        else
        {
            component.set("v.appInfo.CC_Individual_Also_Your_Legal_Guardian__c",false);
            component.set("v.appInfo.CC_You_Your_Guardian_LiveAt_Same_Place__c",false);
        }
        
        
        
        
        
        if(component.get("v.appInfo.CC_Does_Individual_have_Auth_Rep__c")){
            var childCompRi = component.find('cRiChildcmp');
            if(!$A.util.isUndefined(childCompRi)){
                childCompRi.validate(function(resultchildCompRi){
                    if(!$A.util.isEmpty(resultchildCompRi)){
                        lstAllError=lstAllError.concat(resultchildCompRi);                        
                    }                     
                });
            }
            
        }
        
        
        if(component.get("v.appInfo.CC_individual_have_LegalGuardian__c")){ 
            var childCompLg = component.find('cLgChildcmp');
            if(!$A.util.isUndefined(childCompLg)){
                childCompLg.validate(function(resultchildCompLg){
                    if(!$A.util.isEmpty(resultchildCompLg)){
                        lstAllError=lstAllError.concat(resultchildCompRi);
                    }
                    
                });
            }
            
        } 
        
        
        if($A.util.isEmpty(lstAllError)){            
            this.savepage(component, event);
            
        }
        else{
            component.set("v.bIsError",true);
            component.set("v.lstAllError",lstAllError);          		           		
        }
        if(callback)
            callback.call(this,lstAllError);
        
    },  
    
    loadDependentPicklist : function(component) {
        this.callServer(component, "c.getDependentOptions", function(response) {  
            component.set("v.bIsDataLoaded",false);
            var obj = JSON.parse(response);
            this.consoleLog('obj: ' ,false,obj);  	
            component.set("v.mapStatePicklist", obj);
            component.set("v.bIsDataLoaded",true);
        }, {
            "sObjName" : "Contact", 
            "sControllingField" : "CC_Mailing_Address_State__c", 
            "sDependentField" : "CC_Mailing_Address_County__c"
        });
    }
    
})