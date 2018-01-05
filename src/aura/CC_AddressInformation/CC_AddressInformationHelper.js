({
    InitPage : function(component,event) {
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
      
},

renderDepPicklistOptions:function(component,selectedOption){
    var dependentPicklist = component.get("v.dependentPicklist");
    if(!$A.util.isEmpty(dependentPicklist)){
        var counties=(dependentPicklist[selectedOption]);
        component.set("v.PhyCounty", counties);
        component.set("v.PhyStrCounty", '');
        this.setBlankCounty(component,component.get("v.PhyStrCounty"));
    }
},

setBlankCounty:function(component,selectedOption){
       //component.set("v.OtherCounty", '');
       //var otherCounty=component.get("v.OtherCounty");
       //if(component.get("v.PhyStrState")=='Other')
       
     if(selectedOption!='Other'){
        component.set("v.hideOtherCounty",'false');
       }
    else{
        component.set("v.hideOtherCounty",'true');
      }
      if(!component.get("v.hideOtherCounty"))
      component.set("v.OtherCounty", '');
},


checkAddressValidity:function(component,callback){
    var lstErrors = [];
    var addType=component.get("v.AddressType");
    var mapLabels = component.get('v.mapLabels');
    var addline1=component.get("v.AddressLine1");
    var addline2=component.get("v.AddressLine2");
    var City=component.get("v.City");
    var zipCode=component.get("v.ZipCode");
    var ZipExt=component.get("v.ZipExt");
    var OtherCounty=component.get("v.OtherCounty");
    var State=component.get("v.PhyStrState");
    var County=component.get("v.PhyStrCounty");
    var isValidAddress1=this.isValidAddress(addline1);
    var isValidAddress2=this.isValidAddress(addline2);
    
    
    if(!$A.util.isEmpty(addline1)) {
        
       if(!isValidAddress1)
            lstErrors.push(addType+ ' ' +mapLabels.CC_Err_Address_Format);
        component.set("v.bRequired",'True');
    }else {
        lstErrors.push(addType + ' ' +mapLabels.CC_ADDRESS_LINE_1 +' '+ mapLabels.CC_Err_Cannot_Be_Blank);
        component.set("v.bRequired",'True');
    }
    if(!$A.util.isEmpty(addline2)) {
        
       if(!isValidAddress2)
            lstErrors.push(addType + ' ' +mapLabels.CC_Err_Address_Format);
        component.set("v.bRequired",'True');
    }
    
    if(!$A.util.isEmpty(City) ) {
        
        
        if(!this.isValidCity(City))
            lstErrors.push(addType + ' ' +mapLabels.CC_Err_City_Format);
        component.set("v.bRequired",'True');
    }   
    else {
        lstErrors.push(addType + ' ' + mapLabels.CC_CITY +' '+mapLabels.CC_Err_Cannot_Be_Blank);
        component.set("v.bRequired",'True');
    }
    if(!$A.util.isEmpty(zipCode)) {
        
        
        if(!this.isValidPostal(zipCode))
            lstErrors.push(addType + ' ' +mapLabels.CC_Err_ZipCode_Format);
        component.set("v.bRequired",'True');
    }   
    else {
        lstErrors.push(addType+ ' ' +mapLabels.CC_ZIP_CODE +' '+ mapLabels.CC_Err_Cannot_Be_Blank);
        component.set("v.bRequired",'True');
    }
    
    if(!$A.util.isEmpty(ZipExt)) {
        
        
        if(!this.isValidPostal(ZipExt))
            lstErrors.push(addType + ' ' +mapLabels.CC_Err_ZipCode_Format);
        component.set("v.bRequired",'True');
    }   
    
    
    if($A.util.isEmpty(State)) {
        lstErrors.push(addType+ ' ' +mapLabels.CC_STATE +' '+ mapLabels.CC_Err_Cannot_Be_Blank);
        component.set("v.bRequired",'True');
    }
    if( $A.util.isEmpty(County)) {
        lstErrors.push(addType + ' ' +mapLabels.CC_COUNTY +' '+ mapLabels.CC_Err_Cannot_Be_Blank);
        component.set("v.bRequired",'True');
    }
    
    if(!$A.util.isEmpty(OtherCounty)) {
        
        
        if(!this.isValidCounty(OtherCounty))
            lstErrors.push(addType + ' ' +mapLabels.CC_Err_OtherCounty_Format);
        component.set("v.bRequired",'True');
    }  
    
    if($A.util.isEmpty(lstErrors)){
        
        var sAddressStreet;
        if($A.util.isEmpty(addline2))
            component.set("v.ConcatAddress",addline1+';;');
        else
            component.set("v.ConcatAddress",addline1+';;'+addline2);
            
        }else{
            
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