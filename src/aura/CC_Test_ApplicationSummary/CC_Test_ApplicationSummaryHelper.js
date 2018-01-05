({
	validateData : function(component, event) {

		var firstName = component.get("v.sFirstName");
		var middleName = component.get("v.sMiddleName");
		var LastName = component.get("v.sLastName");
		var Suffix = component.get("v.sSuffix");
		var objApplication = component.get("v.objApp");
		var objContact = component.get("v.objContact");
		var lstErrors = [];
		var mapLabels = component.get("v.mapLabels")

		component.set("v.bIsError",false);
		component.set("v.bIsFirstNameError",false);
		component.set("v.bIsMiddleNameError",false);
		component.set("v.bIsLastNameError",false);
		component.set("v.bIsSuffixError",false);

		if($A.util.isEmpty(firstName)){
			lstErrors.push(mapLabels.CC_Err_First_Name_Mandatory);
			component.set("v.bIsFirstNameError",true);
		}
		else if(firstName !== objContact.FirstName){
			lstErrors.push(mapLabels.CC_Err_First_Name_Not_Matching);
			component.set("v.bIsFirstNameError",true);
		}

		if(middleName !== objContact.CC_Middle_Initial__c){
			lstErrors.push(mapLabels.CC_Err_Middle_Name_Not_Matching);
			component.set("v.bIsMiddleNameError",true);
		}

		if($A.util.isEmpty(LastName)){
			lstErrors.push(mapLabels.CC_Err_Last_Name_Mandatory);
			component.set("v.bIsLastNameError",true);
		}
		else if(LastName !== objContact.LastName){
			lstErrors.push(mapLabels.CC_Err_Last_Name_Not_Matching);
			component.set("v.bIsLastNameError",true);
		}

		if(Suffix !== objContact.CC_Suffix__c){
			lstErrors.push(mapLabels.CC_Err_Suffix_Not_Matching);
			component.set("v.bIsSuffixError",true);
		}

		if(!objApplication.Applying_on_behalf_of_applicant__c){
			lstErrors.push(mapLabels.CC_Err_confirm_Applying_onBehalf_Applicant);
			component.set("v.bIsError",true);
		}

		if(!objApplication.Hard_copy_Signature_received__c){
			lstErrors.push(mapLabels.CC_Err_confirm_Signature_received);
			component.set("v.bIsError",true);
		}

		if(!objApplication.Information_is_correct__c){
			lstErrors.push(mapLabels.CC_Err_confirm_correct_information);
			component.set("v.bIsError",true);
		}

		
	}
})