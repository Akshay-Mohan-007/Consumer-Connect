({ 
	validateLangSec : function(component, event, callback) {

		var isError = false;
		var sMail = component.get("v.sEmail");
		var sSpokenLang = component.get("v.sSpokenLang");
        var sPreferredLang=component.get("v.sPreferredLang");
		var sWrittenLang = component.get("v.sWrittenLang");
		var mapLabel=component.get("v.mapLabels");
		var lstErrors = [];
              
		if(!$A.util.isEmpty(sMail)){
			if(this.checkEmailValidity(sMail))
			{
				component.set('v.bIsError',true);
				lstErrors.push(mapLabel.CC_Err_EmailFormatIsNotCorrect);
			}
		}
        
        if($A.util.isEmpty(sWrittenLang) && component.get('v.bHideWritSpokLang')){
	        component.set('v.bIsError',true);
			lstErrors.push(mapLabel.CC_Err_WrittenLangShdNotBlank);	
		}	
       
        if($A.util.isEmpty(sSpokenLang) && component.get('v.bHideWritSpokLang')){	
            component.set('v.bIsError',true);
			lstErrors.push(mapLabel.CC_Err_SpokenLangShdNotBlank);	
		}
      		
        if($A.util.isEmpty(sPreferredLang) && component.get('v.bShowPrefLang')){
			
            component.set('v.bIsError',true);
			lstErrors.push(mapLabel.CC_Err_PreferredLangShdNotBlank);	
		}
		
        component.set("v.lstOfPageErrors",lstErrors);
        if($A.util.isEmpty(lstErrors)){
        	component.set("v.bIsError",false);
			if (callback) callback(lstErrors);
        }
        else{
			if (callback) callback(lstErrors);
			component.set("v.bIsError",true);
			return;
		}
	},

	/*validateEmail : function(mail){
		console.log('valEmail :)');
	 if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(mail))  
	  { 
	    return true; 
	  }   
	    return false;  
	},*/
		
})