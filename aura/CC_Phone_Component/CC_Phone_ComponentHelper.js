({
    validate : function(component,callback) {
        
        
        this.triggerComponentValidators(component.find('PhoneNo'));
        this.triggerComponentValidators(component.find('PhoneType'));
        this.triggerComponentValidators(component.find('ConfirmPhone'));
        
        var bRequired = component.get('v.bRequired');
        var bConfirm = component.get('v.bConfirm');
        var mapLabels = component.get('v.mapLabels');
        var sPhoneNo = component.get('v.sPhoneNumber');
        var sPhoneConf = component.get('v.sPhoneConfirm');
        var sPrefix = component.get('v.sPrefix');
        var sPhoneExt = component.get('v.sPhoneExt');
        var sPhoneType = component.get('v.sPhoneType');
        var lstErrors = [];
        
        component.set('v.bPhoneError',false);
        component.set('v.bConfirmError',false); 
        component.set('v.bTypeError',false);
        component.set('v.bExtError',false);
        
        if($A.util.isEmpty(component.get('v.sPhoneType')) && bRequired){ 
            lstErrors.push(mapLabels.CC_Error_Phone_Type_Missing+' '+sPrefix);
            component.set('v.bTypeError',true);
        }
        if($A.util.isEmpty(sPhoneNo) && bRequired ){
            lstErrors.push(mapLabels.CC_Error_Phone_No_Missing+' '+sPrefix+' '+mapLabels.CC_Label_Phone_no);
            component.set('v.bPhoneError',true);
        }
        
        if((!$A.util.isEmpty(sPhoneNo)) && (sPhoneNo.length < '10')){
            lstErrors.push(mapLabels.CC_Error_Phone_Format+' '+sPrefix+' '+mapLabels.CC_Label_Phone_no);
            component.set('v.bPhoneError',true);
        }
        else if((!$A.util.isEmpty(sPhoneNo)) && (sPhoneNo.length > '10') && !(/^\d{3}-\d{3}-\d{4}$/.test(sPhoneNo)))
        {
            lstErrors.push(mapLabels.CC_Error_Phone_Format+' '+sPrefix+' '+mapLabels.CC_Label_Phone_no);
            component.set('v.bPhoneError',true);
        }
            else if((!$A.util.isEmpty(sPhoneNo)) && (sPhoneNo.length == '10') && !(/^\d+$/.test(sPhoneNo))){
                lstErrors.push(mapLabels.CC_Error_Phone_Format+' '+sPrefix+' '+mapLabels.CC_Label_Phone_no);
                component.set('v.bPhoneError',true);
            }
        
        if($A.util.isEmpty(sPhoneConf) && bRequired && bConfirm)
            lstErrors.push(mapLabels.CC_Error_Phone_Confirm_Missing+' '+sPrefix);
        if(bConfirm && (sPhoneNo !== sPhoneConf) ){
            lstErrors.push(mapLabels.CC_Error_Phone_Not_Matching+' '+sPrefix);
            component.set('v.bConfirmError',true);
        }
        
        if(!($A.util.isEmpty(sPhoneExt)) && !(/^\d+$/.test(sPhoneExt))){
            lstErrors.push(mapLabels.CC_Error_Phone_Ext_Format+' '+sPrefix);
            component.set('v.bExtError',true);
        }
        
        this.consoleLog('Validate Over',false,lstErrors);
        /*if(lstErrors.length===0)
			callback.call(this,'');
		else*/
        callback.call(this,lstErrors);
        
        
        
        
    },    
    phoneFormat:function(sPhone){
        this.consoleLog('sPhone: ' +sPhone);
        var formatted = this.autoFormatPhoneNo(sPhone);
        this.consoleLog('formatted: ' +formatted);
        return formatted;
    },
    
    confirmPhone:function(component){
        var sPhoneNo = component.get('v.sPhoneNumber');
        if( (!$A.util.isEmpty(sPhoneNo)) && component.get('v.bConfirm'))
            component.set('v.sPhoneConfirm',sPhoneNo);
        
        if($A.util.isEmpty(component.get('v.sPhoneExt')))
            component.set('v.sPhoneExt','');
    },
    
    splitPhone:function(component){
        if(!$A.util.isEmpty(component.get("v.sPhoneConcat")) && component.get("v.sPhoneConcat").includes('+')){
            var resStr=component.get("v.sPhoneConcat").split('+');	
            component.set("v.sPhoneNumber",resStr[0]);
            component.set("v.sPhoneExt",resStr[1]);  
        }
        else if(!$A.util.isEmpty(component.get("v.sPhoneConcat")))
        {
            component.set("v.sPhoneNumber",component.get("v.sPhoneConcat"));
        }
    },
    phoneChange:function(component,event,helper){
        if(!$A.util.isEmpty(component.get("v.sPhoneNumber"))){
            if(component.get("v.sPhoneNumber").length === 10  &&  /^\d+$/.test(component.get("v.sPhoneNumber")))
                component.set('v.sPhoneNumber', helper.phoneFormat(component.get('v.sPhoneNumber')) );
            
        }
    },
    phoneConfirmChange :function(component,event,helper){
        if(!$A.util.isEmpty(component.get("v.sPhoneConfirm"))){
            if(component.get("v.sPhoneConfirm").length === 10  && /^\d+$/.test(component.get("v.sPhoneConfirm")))
                component.set('v.sPhoneConfirm', helper.phoneFormat(component.get('v.sPhoneConfirm')) );
        }
        
    },
    concatPhone:function(component,event,helper){
        var concatPhone=component.get("v.sPhoneNumber")+'+'+component.get("v.sPhoneExt");
        component.set("v.sPhoneConcat",concatPhone);
        this.consoleLog('conPhone ' +concatPhone);
        
    }
})