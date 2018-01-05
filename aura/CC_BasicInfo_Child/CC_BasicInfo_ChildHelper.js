({
	initPage : function(component) {
		component.set("v.sDOBLabel",component.get("v.mapCustomMessages").CC_LBL_DOB);
	},
	validate : function(component, event, callback) {
		//this.consoleLog('Inside validate code review changes done.');

		var lstErrors = [];
		var msgError = component.get("v.mapCustomMessages");
		component.set("v.bIsError",false);
		component.set("v.bErrNoGender",false);

		var dtDOB = component.get("v.dDOB");
		//this.consoleLog('Err' +dtDOB);
		if( !$A.util.isEmpty(dtDOB) ){
			this.consoleLog('Err' +dtDOB);
			//var today = new Date();
			//var dToday = new Date(today.getFullYear(), today.getMonth(), today.getDate(),0,0,0,0);
			var dToday = new Date();
			dToday.setMilliseconds(0);
			dToday.setSeconds(0)
			dToday.setMinutes(0);
			dToday.setHours(0);
			
			var dDateOfBirth = this.formatToJSDateObject(dtDOB);

			if(dDateOfBirth.getTime() >= dToday.getTime() )
				lstErrors.push(msgError.CC_Err_DOB_Future_Date);
		}else{
			lstErrors.push(msgError.CC_Err_DOB_Required);
			component.set("v.bIsError",true);
		}

		var sFirstName = component.get("v.sFirstName");
		//this.consoleLog('Err' +sFirstName);
		if( !$A.util.isEmpty(sFirstName) ){
            if(!this.isValidName(component, event, sFirstName)) {
				lstErrors.push(msgError.CC_LBL_FirstName+': '+ msgError.CC_Err_Name_Contains_Numbers);
            }
		}else{
			lstErrors.push(msgError.CC_LBL_FirstName+' '+ msgError.CC_Err_Cannot_Be_Blank); 
			component.set("v.bIsError",true);
		}

		var sLastName = component.get("v.sLastName");
		if( !$A.util.isEmpty(sLastName) ) {
            if(!this.isValidName(component, event, sLastName))
				lstErrors.push(msgError.CC_LBL_LastName+': '+msgError.CC_Err_Name_Contains_Numbers);
		}else {
			lstErrors.push(msgError.CC_LBL_LastName +' '+ msgError.CC_Err_Cannot_Be_Blank);
			component.set("v.bIsError",true);
		}

		var sMiddleInitial = component.get("v.sMiddleInitial");
		if( !$A.util.isEmpty(sMiddleInitial) ) {
            if(!this.isValidMiddleInitial(component, event, sMiddleInitial))
				lstErrors.push(msgError.CC_Err_Midle_Initial);
		}

		var bShowSSN = component.get("v.bShowSSN");
		if( bShowSSN &&  $A.util.isEmpty(component.get("v.sGender")) ) {
			//console.log(component.get("v.sGender"));
		    lstErrors.push(msgError.CC_LBL_Gender +' '+ msgError.CC_Err_Cannot_Be_Blank);
		    component.set("v.bErrNoGender",true);
		}

		var sSSNDisplay = component.get("v.sSSNDisplay");
		if( bShowSSN
			&& !$A.util.isEmpty(sSSNDisplay)
			&& sSSNDisplay.trim().length !== 9){

			component.set("v.sSSN",sSSNDisplay);
			lstErrors.push(msgError.CC_LBL_SSN +' '+ msgError.CC_Err_SSN_Len_Less_Than_9);
		}

		var sConfirmSSNDisplay = component.get("v.sConfirmSSNDisplay");
		if( bShowSSN
			&& !$A.util.isEmpty(sConfirmSSNDisplay)
			&& sConfirmSSNDisplay.trim().length !== 9){
			
			component.set("v.sConfirmSSN",sConfirmSSNDisplay);
		    lstErrors.push(msgError.CC_LBL_Confirm_SSN +' '+ msgError.CC_Err_SSN_Len_Less_Than_9);
		}

		if( bShowSSN
			&& !$A.util.isEmpty(component.get("v.sSSN"))
			&& ($A.util.isEmpty(component.get("v.sConfirmSSN"))) ) {
			
		    lstErrors.push(msgError.CC_Err_Enter_Confirm_SSN);
		}

		if( bShowSSN
			&& !$A.util.isEmpty(component.get("v.sSSN"))
			&& !$A.util.isEmpty(component.get("v.sConfirmSSN"))
			&& (component.get("v.sSSN").trim() !== component.get("v.sConfirmSSN").trim())) {
			
		    lstErrors.push(msgError.CC_Err_SSN_Mismatch);
		}

		if( component.get("v.relatedToIndividualHide") 
			 && $A.util.isEmpty(component.get("v.sRelatedToIndividual")) ) {
			component.set("v.bIsError",true);
		    lstErrors.push(msgError.CC_Error_Person_Related_To_Ind_Cannot_Blank);
		}
		
		//component.set("v.lstOfPageErrors",lstErrors);
		//console.debug('lstOfPageErrors:',component.get("v.lstOfPageErrors"));
		if(lstErrors.length === 0 ){
			console.log('No Errors in Child');
		}else{
			console.log('Errors Exist in Child');
		}

		//call parent save
		//console.debug('callback',callback);
	    if (callback) callback(lstErrors);
	
	},

	checkAndMaskSSN : function(component, event, sourceField, targetField) {
		var sourceValue = component.get(sourceField);
		if( !$A.util.isEmpty(sourceValue) ) {
			if( !this.isNumerical(component, event, sourceValue) 
				&& !this.matchPatternSSN(sourceValue) ){
				var sSubSSN = sourceValue.slice(0,sourceValue.length -1);
				component.set(sourceField,sSubSSN);
			}else if( this.isNumerical(component, event, sourceValue) 
					  && !this.matchPatternSSN(sourceValue) ){
				if(sourceValue.length === 9) {
					//console.debug('Here maskInputSSN' );
					component.set(targetField, sourceValue);
					var sMaskedSSN = this.maskInputSSN(sourceValue);
					//console.debug(this.maskInputSSN(component.get("v.sSSNDisplay")));
					console.debug('sMaskedSSN:'+sMaskedSSN);
					component.set(sourceField,sMaskedSSN);
					//console.debug('match:' + this.matchPatternSSN('XXXXX6789'));
				}
			}else if( !this.isNumerical(component, event, sourceValue) 
					  && this.matchPatternSSN(sourceValue) ){
				console.debug('here:');
				return;	
			}			
		}
		
		console.debug('sSSNDisplay:' +component.get("v.sSSNDisplay"));
		console.debug('sSSN:' +component.get("v.sSSN"));

		
		console.debug('sConfirmSSNDisplay:' +component.get("v.sConfirmSSNDisplay"));
		console.debug('sConfirmSSN:' +component.get("v.sConfirmSSN"));
	}

	

	
})