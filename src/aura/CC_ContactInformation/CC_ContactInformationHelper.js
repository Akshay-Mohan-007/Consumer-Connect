({   
	saveData : function(component) { 
		
			var objContact = component.get("v.contactInfo");
			if(component.get("v.contactInfo.CC_Same_as_physical_address__c"))
			{	
				objContact.MailingStreet = objContact.OtherStreet;
				objContact.MailingCity = objContact.OtherCity;
				objContact.CC_Mailing_Address_State__c = objContact.CC_Physical_Address_State__c;
				objContact.MailingPostalCode = objContact.OtherPostalCode;
				objContact.CC_Zip4mailing__c = objContact.CC_Zip4__c;
                objContact.CC_Mailing_Address_County__c = objContact.CC_Contact_County__c;
                objContact.CC_Other_Mailing_Address_County__c = objContact.CC_Other_Physical_Address_County__c;
			}
 
 			this.callServer(component, "c.doSave", function(result) {                       
			},{
				"sContact": JSON.stringify(objContact),
				"sAppId": component.get('v.sAppId')
				}); 
	},


	loadData : function(component){

		component.set("v.bIsDataLoaded",false);
		var strContactId = component.get("v.sContactId");

			this.callServer(component, "c.loadContactData", function(response) {
	                var result = JSON.parse(response);
	         
	                component.set("v.lstMainPhnType",result.phonePickList.lstMainPhoneTypes);
	                component.set("v.lstOtherPhnType",result.phonePickList.lstOtherPhoneTypes);
	                component.set("v.lstSpokenLang",result.phonePickList.lstSpokenLangs);
	                component.set("v.lstWrittenLang",result.phonePickList.lstWrittenLangs);
                    component.set("v.lstPhyState",result.phonePickList.lstAddStates);        
	                component.set("v.mapLabels",result.mapUiLabels);
	                component.set("v.contactInfo",result.conObj);
	                component.set("v.bBothAddressSame",result.conObj.CC_Same_as_physical_address__c);
	                component.set("v.bIsDataLoaded",true);

		},{
			"strConId": strContactId
			});				
	},	

	validateChildData : function(component, callback){
			var lstAllError = [];

			var childCompMainPhn = component.find('cCompMainPhn');
			childCompMainPhn.validate(function(resultMainPhn){
            	lstAllError = lstAllError.concat(resultMainPhn);
			});

			var childCompOtherPhn = component.find('cCompOtherPhn');
			childCompOtherPhn.validate(function(resultOtherPhn){
            	lstAllError = lstAllError.concat(resultOtherPhn);
			});

			var childCompPhyAddress = component.find('cCompPhyAdd');
			childCompPhyAddress.validateAddress(function(resultPhyAdd){
				lstAllError = lstAllError.concat(resultPhyAdd);      	
			}); 

			if(!component.get("v.contactInfo").CC_Same_as_physical_address__c){
				var childCompMailAddress = component.find('cCompMailAdd');
				childCompMailAddress.validateAddress(function(resultMailAdd){
	             	lstAllError = lstAllError.concat(resultMailAdd);  
					}); 
			}

			var childCompLang = component.find('cCompLang');
			childCompLang.validateLangData(function(resultLang){
            	lstAllError = lstAllError.concat(resultLang);     	
			}); 

			if($A.util.isEmpty(lstAllError)){

            		this.saveData(component);
            		component.set("v.bIsError",false);
            		component.set("v.lstAllError",null);
            		this.loadData(component);
            	 }
            	else{
            		component.set("v.bIsError",true);
            		component.set("v.lstAllError",lstAllError);          		           		
            	}

            	if(callback)
    				callback.call(this,lstAllError);

	},
	 loadDependentPicklist : function(component) {
     this.callServer(component, "c.getDependentOptions", function(response) {  
     	component.set("v.bIsDataLoaded",false);
     	var obj = JSON.parse(response);
     	this.consoleLog('obj: ' ,false,obj);  	
     	component.set("v.mapStatePicklist", obj);
     	component.set("v.bIsDataLoaded",true);
     	 }, {
     	 	"sObjName" : "Contact", 
     		"sControllingField" : "CC_Mailing_Address_State__c", 
     		"sDependentField" : "CC_Mailing_Address_County__c"
     		});
    }

})