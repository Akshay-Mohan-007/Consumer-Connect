({
    InitPage : function(component,event) {
        /*console.log('Init Page');
        console.log('PicklistValues' ,  component.get("v.PhyState"));
        var params = {"sObjName" : "Contact", "sControllingField" : "CC_Mailing_Address_State__c", "sDependentField" : "CC_Mailing_Address_County__c"};                
        this.callServer(component, "c.getDependentOptions", function(response) {
            this.consoleLog('response',false,response);
            component.set("v.dependentPicklist", response);*/
            var conAdd=component.get("v.ConcatAddress");
            if(!$A.util.isEmpty(conAdd) && conAdd.includes(';;')){
                var resStr=conAdd.split(';;');
                component.set("v.AddressLine1",resStr[0]);
                if(resStr[1] !== '')	
                    component.set("v.AddressLine2",resStr[1]);  
                else
                    component.set("v.AddressLine2",''); 
            }
            else if(!$A.util.isEmpty(conAdd))
            {
                component.set("v.AddressLine1",conAdd);
            }
            
            
            var selectedCounty = component.get("v.PhyStrCounty");
            this.renderDepPicklistOptions(component, component.get("v.PhyStrState"));
            component.set("v.PhyStrCounty", selectedCounty);
           /* }, params);*/
    },
    
    renderDepPicklistOptions:function(component,selectedOption){
        var dependentPicklist = component.get("v.dependentPicklist");
        if(!$A.util.isEmpty(dependentPicklist)){
            var counties = [{"sValue" : "Select County","sKey" : ""}];
            counties = counties.concat(dependentPicklist[selectedOption]);
            component.set("v.PhyCounty", counties);
            component.set("v.PhyStrCounty", '');
            this.setBlankCounty(component,component.get("v.PhyStrCounty"));
        }
    },
    
    setBlankCounty:function(component,selectedOption){
        component.set("v.OtherCounty", '');
        if(selectedOption!='Other')
            component.set("v.hideOtherCounty",'false');
        else
            component.set("v.hideOtherCounty",'true');
    },
    
    
    checkAddressValidity:function(component,callback){
        var lstErrors = [];
        var addType=component.get("v.AddressType");
        var mapLabels = component.get('v.mapLabels');
        var addline1=component.get("v.AddressLine1");
        var addline2=component.get("v.AddressLine2");
        
        if(!$A.util.isEmpty(addline1)) {
            
            console.log('val ' +this.isValidAddress(component, event,addline1));
            if(!this.isValidAddress(component, event,addline1))
                lstErrors.push(mapLabels.CC_Err_Address_Format);
            component.set("v.bRequired",'True');
        }else {
            lstErrors.push(addType + ' ' +mapLabels.CC_ADDRESS_LINE_1 +' '+ mapLabels.CC_Err_Cannot_Be_Blank);
            component.set("v.bRequired",'True');
        }
        if(!$A.util.isEmpty(addline2)) {
            
            console.log('val ' +this.isValidAddress(component, event,addline2));
            if(!this.isValidAddress(component, event,addline2))
                lstErrors.push(component.get("v.AddressType") + '' +mapLabels.CC_Err_Address_Format);
            component.set("v.bRequired",'True');
        }
        
        if(!$A.util.isEmpty(component.get("v.City")) ) {
            
            console.log('val ' +this.isValidCity(component, event, component.get("v.City")));
            if(!this.isValidCity(component, event, component.get("v.City")))
                lstErrors.push(addType + ' ' +mapLabels.CC_Err_City_Format);
            component.set("v.bRequired",'True');
        }   
        else {
            lstErrors.push(addType + ' ' + mapLabels.CC_CITY +' '+mapLabels.CC_Err_Cannot_Be_Blank);
            component.set("v.bRequired",'True');
        }
        if(!$A.util.isEmpty(component.get("v.ZipCode"))) {
            
            console.log('val ' +this.isValidPostal(component, event, component.get("v.ZipCode")));
            if(!this.isValidPostal(component, event, component.get("v.ZipCode")))
                lstErrors.push(addType + ' ' +mapLabels.CC_Err_ZipCode_Format);
            component.set("v.bRequired",'True');
        }   
        else {
            lstErrors.push(addType+ ' ' +mapLabels.CC_ZIP_CODE +' '+ mapLabels.CC_Err_Cannot_Be_Blank);
            component.set("v.bRequired",'True');
        }
        
        if(!$A.util.isEmpty(component.get("v.ZipExt"))) {
            
            console.log('val ' +this.isValidPostal(component, event, component.get("v.ZipExt")));
            if(!this.isValidPostal(component, event, component.get("v.ZipExt")))
                lstErrors.push(addType + ' ' +mapLabels.CC_Err_ZipCode_Format);
            component.set("v.bRequired",'True');
        }   
        
        
        if($A.util.isEmpty(component.get("v.PhyStrState"))) {
            lstErrors.push(addType+ ' ' +mapLabels.CC_STATE +' '+ mapLabels.CC_Err_Cannot_Be_Blank);
            component.set("v.bRequired",'True');
        }
        if( $A.util.isEmpty(component.get("v.PhyStrCounty"))) {
            lstErrors.push(addType + ' ' +mapLabels.CC_COUNTY +' '+ mapLabels.CC_Err_Cannot_Be_Blank);
            component.set("v.bRequired",'True');
        }
        
        if(!$A.util.isEmpty(component.get("v.OtherCounty"))) {
            
            console.log('val ' +this.isValidCounty(component, event, component.get("v.OtherCounty")));
            if(!this.isValidCounty(component, event, component.get("v.OtherCounty")))
                lstErrors.push(addType + ' ' +mapLabels.CC_Err_OtherCounty_Format);
            component.set("v.bRequired",'True');
        }  
        
        if(lstErrors.length === 0 ){
            console.log('No Errors in Child');
            var sAddressStreet;
            if($A.util.isEmpty(addline2))
                component.set("v.ConcatAddress",addline1+';;');
            else
                component.set("v.ConcatAddress",addline1+';;'+addline2);
            console.log("ConcatAddress:" +component.get("v.ConcatAddress"));
        }else{
            console.log('Errors Exist in Child');
        }
        
        if (callback) callback(lstErrors);
        
    },
    
   
    
    showHideAddress : function(component){
        
        var isCheck = component.find("checkbox").get("v.checked");
        
        if(!isCheck){        
            component.set("v.AddressLine1",'');
            component.set("v.AddressLine2",'');
            component.set("v.City",'');
            component.set("v.PhyStrState",'');
            component.set("v.ZipCode",'');
            component.set("v.ZipExt",'');
            component.set("v.PhyStrCounty",'');
            component.set("v.OtherCounty",'');            
        }
    }   
    
})