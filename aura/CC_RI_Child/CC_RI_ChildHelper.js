({ 
    
    
    validateData:function(component, event,callback){        
        var lstAllError = [];
        
        
        var childCompMainPhn = component.find('cCompMainPhn');
        if(!$A.util.isUndefined(childCompMainPhn)){ 
            childCompMainPhn.validate(function(resultMainPhn){
                if(!$A.util.isEmpty(resultMainPhn)){
                   lstAllError= lstAllError.concat(resultMainPhn);
                }
                
            });}
        
        
        var childCompOtherPhn = component.find('cCompOtherPhn');
        if(!$A.util.isUndefined(childCompOtherPhn)){
            childCompOtherPhn.validate(function(resultOtherPhn){
                if(!$A.util.isEmpty(resultOtherPhn)){
                   lstAllError= lstAllError.concat(resultOtherPhn);
                }
                
            });}
        
        
        var childCompLang = component.find('cCompLang');
        if(!$A.util.isUndefined(childCompLang)){
            childCompLang.validateLangData(function(resultLang){
                if(!$A.util.isEmpty(resultLang)){
                   lstAllError= lstAllError.concat(resultLang);
                }
                
            }); }
        
        
        var childCompPhyAddress = component.find('cCompPhyAdd');
        if(!$A.util.isUndefined(childCompPhyAddress)){
            childCompPhyAddress.validateAddress(function(resultPhyAdd){
                if(!$A.util.isEmpty(resultPhyAdd)){
                    lstAllError=lstAllError.concat(resultPhyAdd);
                }           	
            }); 
            
        }
        
        
        if(!component.get("v.contactInformation.CC_Same_as_physical_address__c")){
            var childCompMailAddress = component.find('cCompMailAdd');
            if(!$A.util.isUndefined(childCompMailAddress)){
                childCompMailAddress.validateAddress(function(resultMailAdd){
                    
                    if(!$A.util.isEmpty(resultMailAdd)){
                       lstAllError= lstAllError.concat(resultMailAdd);
                    }
                    
                    
                }); 
            }
        }	
        
        
        if(component.get("v.contactInformation.CC_Same_as_physical_address__c")){
            
            var objContact = component.get("v.contactInformation");
            objContact.MailingStreet = objContact.OtherStreet;
            objContact.MailingCity = objContact.OtherCity;
            objContact.CC_Mailing_Address_State__c = objContact.CC_Physical_Address_State__c;
            objContact.MailingPostalCode = objContact.OtherPostalCode;
            objContact.CC_Zip4mailing__c = objContact.CC_Zip4__c;
            objContact.CC_Mailing_Address_County__c = objContact.CC_Contact_County__c;
            objContact.CC_Other_Mailing_Address_County__c = objContact.CC_Other_Physical_Address_County__c;
            component.set("v.contactInformation",objContact);
            
        }
        
        var childBasicInfo=component.find('cRepBasicInfo');
        if(!$A.util.isUndefined(childBasicInfo)){
            childBasicInfo.validatePage(function(resultBasicInfo){
                if(!$A.util.isEmpty(resultBasicInfo)){
                   lstAllError= lstAllError.concat(resultBasicInfo);
                }
                
            });
        }
        
        
        callback.call(this,lstAllError);
    },
})