({
	initPage : function(component) {
		component.set("v.sDOBLabel",component.get("v.mapCustomMessages").CC_LBL_DOB);
	},
	validate : function(component, event, callback) {
		console.log('Inside validate');
		//console.log('DOB:' +component.get("v.dDOB"));

		var lstErrors = [];
		//component.set("v.bErrorExists",false);
		var msgError = component.get("v.mapCustomMessages");
		component.set("v.bIsError",false);
		component.set("v.bErrNoGender",false);

		if( !$A.util.isUndefined(component.get("v.dDOB")) && !$A.util.isEmpty(component.get("v.dDOB")) ){
			console.log('Err' +component.get("v.dDOB"));
			var today = new Date();
			var dToday = new Date(today.getFullYear(), today.getMonth(), today.getDate(),0,0,0,0);
			var dDateOfBirth = this.formatToJSDateObject(component, event, component.get("v.dDOB"));

			//console.log('converted' +dDateOfBirth);
			if(dDateOfBirth.getTime() >= dToday.getTime() )
				lstErrors.push(msgError.CC_Err_DOB_Future_Date);
		}else {
			lstErrors.push(msgError.CC_Err_DOB_Required);
			component.set("v.bIsError",true);
		}


		if( !$A.util.isUndefined(component.get("v.sFirstName")) && !$A.util.isEmpty(component.get("v.sFirstName")) ) {

			//console.log('val ' +this.isValidName(component, event, component.get("v.sFirstName")));
            if(!this.isValidName(component, event, component.get("v.sFirstName"))) {
				lstErrors.push(msgError.CC_LBL_FirstName+': '+ msgError.CC_Err_Name_Contains_Numbers);
            }
		}else {
			lstErrors.push(msgError.CC_LBL_FirstName+' '+ msgError.CC_Err_Cannot_Be_Blank); 
			component.set("v.bIsError",true);
		}


		if( !$A.util.isUndefined(component.get("v.sLastName")) && !$A.util.isEmpty(component.get("v.sLastName")) ) {

			//console.log('val ' +this.isValidName(component, event, component.get("v.sLastName")));
            if(!this.isValidName(component, event, component.get("v.sLastName")))
				lstErrors.push(msgError.CC_LBL_LastName+': '+msgError.CC_Err_Name_Contains_Numbers);
		}else {
			lstErrors.push(msgError.CC_LBL_LastName +' '+ msgError.CC_Err_Cannot_Be_Blank);
			component.set("v.bIsError",true);
		}


		if( !$A.util.isUndefined(component.get("v.sMiddleInitial")) && !$A.util.isEmpty(component.get("v.sMiddleInitial")) ) {

			console.log('val sMiddleInitial ' +this.isValidMiddleInitial(component, event, component.get("v.sMiddleInitial")));
            if(!this.isValidMiddleInitial(component, event, component.get("v.sMiddleInitial")))
				lstErrors.push(msgError.CC_Err_Midle_Initial);
		}

		if( $A.util.isUndefined(component.get("v.sGender")) 
			|| $A.util.isEmpty(component.get("v.sGender")) 
			|| component.get("v.sGender").length === 0 ) {
			console.log(component.get("v.sGender"));
		    lstErrors.push(msgError.CC_LBL_Gender +' '+ msgError.CC_Err_Cannot_Be_Blank);
		    component.set("v.bErrNoGender",true);
		}


		if( !$A.util.isUndefined(component.get("v.sSSNDisplay")) 
			&& !$A.util.isEmpty(component.get("v.sSSNDisplay"))
			&& component.get("v.sSSNDisplay").trim().length !== 9){

			component.set("v.sSSN",component.get("v.sSSNDisplay"));
			lstErrors.push(msgError.CC_LBL_SSN +' '+ msgError.CC_Err_SSN_Len_Less_Than_9);
		}

		
		if( !$A.util.isUndefined(component.get("v.sConfirmSSNDisplay")) 
			&& !$A.util.isEmpty(component.get("v.sConfirmSSNDisplay"))
			&& component.get("v.sConfirmSSNDisplay").trim().length !== 9){
			
			component.set("v.sConfirmSSN",component.get("v.sConfirmSSNDisplay"));
		    lstErrors.push(msgError.CC_LBL_Confirm_SSN +' '+ msgError.CC_Err_SSN_Len_Less_Than_9);
		}

		if( !$A.util.isUndefined(component.get("v.sSSN")) && !$A.util.isEmpty(component.get("v.sSSN"))
			&& ($A.util.isUndefined(component.get("v.sConfirmSSN")) || $A.util.isEmpty(component.get("v.sConfirmSSN"))) ) {
			
		    lstErrors.push(msgError.CC_Err_Enter_Confirm_SSN);
		}

		if( (!$A.util.isUndefined(component.get("v.sSSN")) && !$A.util.isEmpty(component.get("v.sSSN")))
			&& (!$A.util.isUndefined(component.get("v.sConfirmSSN")) && !$A.util.isEmpty(component.get("v.sConfirmSSN")))
			&& (component.get("v.sSSN").trim() !== component.get("v.sConfirmSSN").trim())) {
			
		    lstErrors.push(msgError.CC_Err_SSN_Mismatch);
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

	checkAndMaskSSN : function(component, event, sSSNfieldNo) {

		if(sSSNfieldNo === 'ssn'){
			if( !$A.util.isUndefined(component.get("v.sSSNDisplay")) && !$A.util.isEmpty(component.get("v.sSSNDisplay")) ) {
				console.log(this.isNumerical(component, event,component.get("v.sSSNDisplay")));
				if(!this.isNumerical(component, event, component.get("v.sSSNDisplay"))){
					var sSubSSN = component.get("v.sSSNDisplay").slice(0,component.get("v.sSSNDisplay").length -1);
					component.set("v.sSSNDisplay",sSubSSN);
				}else {
					if(component.get("v.sSSNDisplay").length === 9) {
						component.set("v.sSSN", component.get("v.sSSNDisplay"));
						var sMaskedSSN = component.get("v.sSSNDisplay").replace(/^(\d{5})/,'XXXXX');
						component.set("v.sSSNDisplay",sMaskedSSN);
					}
				}			
			}
		}
		else {
			if( !$A.util.isUndefined(component.get("v.sConfirmSSNDisplay")) && !$A.util.isEmpty(component.get("v.sConfirmSSNDisplay")) ) {
				console.log(this.isNumerical(component, event,component.get("v.sConfirmSSNDisplay")));
				if(!this.isNumerical(component, event, component.get("v.sConfirmSSNDisplay"))){
					var sSubSSN = component.get("v.sConfirmSSNDisplay").slice(0,component.get("v.sConfirmSSNDisplay").length -1);
					component.set("v.sConfirmSSNDisplay",sSubSSN);
				}else {
					if(component.get("v.sConfirmSSNDisplay").length === 9) {
						component.set("v.sConfirmSSN", component.get("v.sConfirmSSNDisplay"));
						var sMaskedSSN = component.get("v.sConfirmSSNDisplay").replace(/^(\d{5})/,'XXXXX');
						component.set("v.sConfirmSSNDisplay",sMaskedSSN);
					}
				}			
			}
		}
	},

	isNumerical : function(component, event, sString) {
		if(!$A.util.isUndefined(sString) && !$A.util.isEmpty(sString)) {
			var pattern = /^[0-9]*$/;
	    	return pattern.test(sString);

		}else
			return false;
		
	},

	//only . - `space characters accepted
	isValidName : function(component, event, sString) {
		console.log('isValidName');
		if(!$A.util.isUndefined(sString) && !$A.util.isEmpty(sString)) {
			var pattern = /^[a-zA-Z][a-zA-Z .`-]*$/;
			return pattern.test(sString.trim());

		}else
			return false;
	},

	//only . - `space single char accepted
	isValidMiddleInitial : function(component, event, sString) {
		console.log('isValidName');
		if(!$A.util.isUndefined(sString) && !$A.util.isEmpty(sString)) {
			var pattern = /^[a-zA-Z .`-]$/;
			return pattern.test(sString);

		}else
			return false;
	},

	formatToJSDateObject : function(component, event, dateString) {
		if(!$A.util.isUndefined(dateString) && !$A.util.isEmpty(dateString)) {
			dateString = dateString.trim();
			return new Date(dateString.split('-')[0],dateString.split('-')[1]-1,dateString.split('-')[2]);
		}else
			return '';
	}
})