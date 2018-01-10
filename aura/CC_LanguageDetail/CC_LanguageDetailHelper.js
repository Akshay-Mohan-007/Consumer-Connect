({
	validateLangSec : function(component, event, callback) {

		console.log('aura method is working :)');

		var isError = false;
		var sMail = component.get("v.sEmail");

		var lstErrors = [];
		
		if(!$A.util.isUndefined(sMail) && !$A.util.isEmpty(sMail)){

			if(!this.validateEmail(sMail))
			{
				isError = true;
				lstErrors.push($A.get("$Label.c.CC_Err_EmailFormatIsNotCorrect"));
			}
		}
		else{	
				isError = true;
				lstErrors.push($A.get("$Label.c.CC_Err_EmailShdNotBlank"));
		}

		if($A.util.isUndefined(component.get("v.sWrittenLang")) && $A.util.isEmpty(component.get("v.sWrittenLang"))){

			lstErrors.push($A.get("$Label.c.CC_Err_WrittenLangShdNotBlank"));	
		}

		if($A.util.isUndefined(component.get("v.sSpokenLang")) && $A.util.isEmpty(component.get("v.sSpokenLang"))){

			lstErrors.push($A.get("$Label.c.CC_Err_SpokenLangShdNotBlank"));	
		}
		/*console.log('isError in Lang sec:'+isError);
		var saveEvent = component.getEvent("callLangSave");
        saveEvent.setParams({"bIsLangDataValidated": isError});
        saveEvent.fire();*/

        component.set("v.lstOfPageErrors",lstErrors);
        if(lstErrors.length === 0 ){
        	component.set("v.bIsError",false);
			console.debug('callback',callback);
			if (callback) callback(lstErrors);
        }
        else{
			console.debug('callback',callback);
			if (callback) callback(lstErrors);
			component.set("v.bIsError",true);
			return;
		}
	},

	validateEmail : function(mail){
		console.log('valEmail :)');
	 if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(mail))  
	  { 
	    return true; 
	  }   
	    return false;  
	},
		
})