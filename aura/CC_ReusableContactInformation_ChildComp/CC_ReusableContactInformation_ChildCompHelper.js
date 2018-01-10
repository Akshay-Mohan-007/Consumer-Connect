({ 
	validatePhnSec : function(component, event, callback) {
 
		console.log('aura method is working :)');

		var isError = false;
		var sMainPhnNo = component.get("v.sMainPhnNo");
		var sOtherPhnNo = component.get("v.sOtherPhnNo");
		var sMainPhnDup = component.get("v.sMainPhoneDup");
		var sOthrPhnDup = component.get("v.sOtherPhoneDup");
		var sMainPhnType = component.get("v.sMainPhnType");
		var sOtherPhnType = component.get("v.sOtherPhnType");

		var lstErrors = [];
		
		// Validations for Main Phone Fields
		if($A.util.isEmpty(sMainPhnType) ){
			lstErrors.push($A.get("$Label.c.CC_Err_MainPhnTypeMandatory"));
		}

		if($A.util.isEmpty(sMainPhnNo)){
			lstErrors.push($A.get("$Label.c.CC_Err_MainPhnMandatory"));
		}

	else{
			if($A.util.isEmpty(sMainPhnDup)){
				lstErrors.push($A.get("$Label.c.CC_Err_MainPhnDupMandatory"));
			}
			else if(!this.validatePhnFormat(sMainPhnNo)){
				lstErrors.push($A.get("$Label.c.CC_Err_MainPhnFormat"));
			}
			else if(sMainPhnNo != sMainPhnDup){
				lstErrors.push($A.get("$Label.c.CC_Err_MainPhnNotMatching"));
			}
	    }

	    // Validation for Other Phone fields
		if(!$A.util.isEmpty(sOtherPhnNo)){
			if($A.util.isEmpty(sOthrPhnDup)){
				lstErrors.push($A.get("$Label.c.CC_Err_OtherPhnDupMandatory"));
			}
			else if(!this.validatePhnFormat(sOtherPhnNo)){
				lstErrors.push($A.get("$Label.c.CC_Err_OtherPhnFormat"));
			}
			else if(sOtherPhnNo != sOthrPhnDup){
				lstErrors.push($A.get("$Label.c.CC_Err_OtherPhnNotMatching"));
			}
			else if($A.util.isEmpty(sOtherPhnType)){
				lstErrors.push($A.get("$Label.c.CC_Err_OtherPhnTypeBlank"));
			}
		}
	else if(!$A.util.isEmpty(sOthrPhnDup)){
			lstErrors.push($A.get("$Label.c.CC_Err_OtherPhnDupShdBlank"));
		} 
				


		/*if(!this.validatePhnNo(sMainPhnNo, sMainPhnDup)){

				isError = true;
				lstErrors.push($A.get("$Label.c.CC_Err_MainPhnNotMatching"));
				if(!isError)
				{
					if(!this.validatePhnFormat(sMainPhnNo))
					{
						isError = true;
						lstErrors.push($A.get("$Label.c.CC_Err_MainPhnFormat"));
					}
				}
		}

		if(!this.validatePhnNo(sOtherPhnNo, sOtherPhnNo)){

			isError = true;
			lstErrors.push($A.get("$Label.c.CC_Err_OtherPhnNotMatching"));
			
			if(!isError)
			{
				if(!this.validatePhnFormat(sOtherPhnNo))
				{
					isError = true;
					lstErrors.push($A.get("$Label.c.CC_Err_OtherPhnFormat"));
				}
			}
		}*/

		//var isValidated = "isError;
		console.log('errors'+lstErrors);
		console.log('isError in Phn sec:'+isError);
		//console.log('lstErrors size is'+ lstErrors.length);
		/*var saveEvent = component.getEvent("callSave");
        saveEvent.setParams({"bIsPhnDataValidated": isError});
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

	/*validatePhnNo : function(phnNo, dupNo){
			console.log('valPhn :)');

		if(phnNo!= '' || phnNo!= NULL){
			
			if(dupNo!= '' || dupNo!= NULL){

				if(phnNo == dupNo){

					return true;
				}
				else{
					return false;
				}
			}
			else{
				return false;
			}

		}
		else if(dupNo!= '' || dupNo!= NULL){
			return false;
		}
	},*/

	 validatePhnFormat : function(phnNo){

	 	var pattern = /^(\([0-9]{3}\))[0-9]{3}-[0-9]{4}$/;
	    if(pattern.test(phnNo)) {
	    return true;
 		 }
 		else {
	    return false;
  		}

	 } 
		
})