({
	validate : function(component,event) {
		console.debug('Inside Modal validate');

		component.set("v.bDisableSave",true);
		//console.debug("SAVE DISABLE val:",component.get("v.bDisableSave"));

		component.set("v.bErrNoCurrentFuture",false);
		component.set("v.bErrOtherService",false);
		component.set("v.bErrOtherProgram",false);
		component.set('v.bSelectedServiceError',false);
		component.set("v.bSelectedProgramError",false);
		component.set('v.bServiceProgCombinationError',false);

 		var concateServProg = component.get('v.sConcatServProg');
 		var split = concateServProg.split('+');

		var lstService = component.get('v.lstSelectedService');
		var sSelectedService = component.get('v.selectedService');
		var sSelectedProg = component.get('v.selectedProgram');
		var sOtherServiceName = component.get('v.sOtherServiceName');
		var sOtherProgName = component.get('v.sOtherProgName');
		var lstError = [];
		var mapLabels = component.get('v.mapLabels');
		var currentConcateVal = sSelectedService +'+'+ sOtherServiceName +'+'+ sSelectedProg +'+'+ sOtherProgName;

		if(lstService.length > 0){
			if(!$A.util.isEmpty(sSelectedService) 
				&& !$A.util.isEmpty(sSelectedProg) 
				&& (currentConcateVal !== concateServProg)){
				for(var i=0; i<lstService.length ; i++){
					if(sSelectedService === 'Other' && sSelectedProg === 'Other'){	

						if(sSelectedService === lstService[i].sServiceName 
							&& sSelectedProg === lstService[i].sCurrentlyGettingProgramName
							&& sOtherServiceName.toUpperCase() === lstService[i].sOtherServiceName.toUpperCase()  
							&& sOtherProgName.toUpperCase() === lstService[i].sOtherProgName.toUpperCase()){
								
								component.set('v.bServiceProgCombinationError',true);
								lstError.push(mapLabels.CC_Err_Service_Prog_already_exist);
								break;
						    }
						}
					else if(sSelectedService === 'Other' && sSelectedProg !== 'Other'){

						if(sSelectedService === lstService[i].sServiceName 
							&& sOtherServiceName.toUpperCase() === lstService[i].sOtherServiceName.toUpperCase() 
							&& sSelectedProg === lstService[i].sCurrentlyGettingProgramName){
								
								component.set('v.bServiceProgCombinationError',true);
								lstError.push(mapLabels.CC_Err_Service_Prog_already_exist);
								break;
						    }
						}
					else if(sSelectedService !== 'Other' && sSelectedProg === 'Other'){

						if(sSelectedService === lstService[i].sServiceName 
							&& sSelectedProg === lstService[i].sCurrentlyGettingProgramName
							&& sOtherProgName.toUpperCase() === lstService[i].sOtherProgName.toUpperCase()){
								
								component.set('v.bServiceProgCombinationError',true);
								lstError.push(mapLabels.CC_Err_Service_Prog_already_exist);
								break;
						    }
						}
					else if(sSelectedService !== 'Other' && sSelectedProg !== 'Other'){
						if(sSelectedService === lstService[i].sServiceName 
							&& sSelectedProg === lstService[i].sCurrentlyGettingProgramName){
								
								component.set('v.bServiceProgCombinationError',true);
								lstError.push(mapLabels.CC_Err_Service_Prog_already_exist);
								break;
						    }
						}
					}		
				}
			}
 	
		//console.debug('split:',split);
		if(lstService.length > 0){
			if(!$A.util.isEmpty(sSelectedService) 
				&& $A.util.isEmpty(split[0]) ){
				//console.debug('split 0:',split[0]);
				for(var i=0; i<lstService.length; i++){
					if(sSelectedService === lstService[i].sOtherServiceName 
						&& component.get("v.bNeededInFuture") === lstService[i].bNeededInFuture
						&& component.get("v.bNeededInFuture") === true
						&& component.get("v.bCurrentlyGetting") === lstService[i].bGettingCurrently
						&& component.get("v.bCurrentlyGetting") === false){
							//console.debug('service existing:',lstService[i]);
							lstError.push(mapLabels.CC_Err_Service_Needed_Exists);
							break;
					}
				}		
			}
		}


		if(component.get("v.bCurrentlyGetting") === false && component.get("v.bNeededInFuture") === false) {
			component.set("v.bErrNoCurrentFuture",true);
			lstError.push(mapLabels.CC_Err_No_Current_Future_Service);
		}

		if(component.get("v.bCurrentlyGetting") && $A.util.isEmpty(component.get("v.selectedProgram")) ) {
			component.set("v.bSelectedProgramError",true);
		}

		if(!$A.util.isEmpty(component.get("v.selectedProgram")) 
				&& component.get("v.selectedProgram") === component.get('v.mapLabels').CC_LBL_OTHER
				&& $A.util.isEmpty(component.get("v.sOtherProgName"))) {
			component.set("v.bErrOtherProgram",true);
		}

		if($A.util.isEmpty(component.get("v.selectedService")) ) {
            component.set('v.bSelectedServiceError',true);
			console.debug('selectedService',component.get("v.selectedService"));
		}

		if(!$A.util.isEmpty(component.get("v.selectedService")) 
			    && component.get("v.selectedService") === component.get('v.mapLabels').CC_LBL_OTHER
			    && $A.util.isEmpty(component.get("v.sOtherServiceName"))) {
			component.set("v.bErrOtherService",true);

		}

		var bValidationErr = component.get("v.bErrNoCurrentFuture") 
							|| component.get("v.bSelectedServiceError")
							|| component.get("v.bErrOtherService")
							|| component.get("v.bSelectedProgramError")
							|| component.get("v.bErrOtherProgram");

		component.set('v.lstAllError',lstError);
		//console.debug('lstError',component.get('v.lstAllError'));

		if(bValidationErr || lstError.length > 0){
			console.debug('bValidationErr:',bValidationErr);
			console.debug('lstError:',lstError);
			component.set("v.bDisableSave",false);
			return;
		}

		this.saveRecord(component,event);

	},

	saveRecord : function(component,event) {
		console.debug('Inside Modal Save');
		console.debug('Params:',component.get("v.objParameters"));
		var callback = component.get("v.objParameters").callback;

		var mapProgServices = component.get('v.mapProgramService');
        var lstAllServices = mapProgServices[component.get("v.selectedProgram")]; 
        var selectedServiceId = '';

        if(component.get("v.bCurrentlyGetting")){
	        lstAllServices.forEach(function(value,iIndex){
	          if(component.get("v.selectedService") === value.sServiceName) {
	             selectedServiceId = value.sServiceId;
	             return;
	          }
	        });
		    console.debug('selectedServiceId:',selectedServiceId);
	    }else{

	    	component.set("v.sOtherProgName","");
	    	component.set("v.selectedProgram","");
	    }

		var objServiceToSend = {
			sOtherProgName : component.get("v.sOtherProgName"),
            sOtherServiceName : (!$A.util.isEmpty(selectedServiceId)) ? 
            					component.get("v.sOtherServiceName") : component.get("v.selectedService"),
        	sRelatedAppId : (component.get("v.objParameters").objService === null) ? 
        					 '' : component.get("v.objParameters").objService.sRelatedAppId,
            sServiceId : selectedServiceId,
            sAppdetailId : (component.get("v.objParameters").objService === null) ? 
        					 '' : component.get("v.objParameters").objService.sAppdetailId,
       		bGettingCurrently : component.get("v.bCurrentlyGetting"),
       		bNeededInFuture : component.get("v.bNeededInFuture")
		};

		console.debug(objServiceToSend);
		if (callback) callback(objServiceToSend);

	},

	setFieldValues : function(component,event) {

	  console.log('Inside Service Modal setValues:');

      var params = event.getParam('arguments');
      console.debug('Object Received ',params.objService);
      component.set("v.objParameters",params);
      component.set("v.sOtherLabel",component.get('v.mapLabels').CC_LBL_OTHER);

        //This is value set for picklist
          var lstProgramsToDisplay = [];
          var programOptions = component.get('v.lstPrograms');
          programOptions.forEach(function(value,iIndex){
              lstProgramsToDisplay.push(value.label);
          });

          lstProgramsToDisplay.sort();
          component.set("v.lstProgramOptions",lstProgramsToDisplay);
          console.debug('lstPrograms-->',lstProgramsToDisplay);

          var mapProgServices = component.get('v.mapProgramService');
          
          var lstServicesToDisplay = [];
          for (var key in mapProgServices) {
              lstServicesToDisplay = mapProgServices[key];
              break;
          }

          var lstServiceOptions = [];
          lstServicesToDisplay.forEach(function(value,iIndex){
                lstServiceOptions.push(lstServicesToDisplay[iIndex].sServiceName);
          });
          lstServiceOptions.sort();

          //lstServiceOptions.push(component.get('v.mapLabels').CC_LBL_OTHER);
          component.set('v.lstServiceOptions',lstServiceOptions);

          //console.debug('lstServicesToDisplay:',lstServicesToDisplay);
          //console.debug('lstServiceOptions:',component.get('v.lstServiceOptions'));

          if(!$A.util.isEmpty(params.objService)) {

	          var selectedService;
	          var selectedProgram;
	          component.set("v.sOtherServiceName",params.objService.sOtherServiceName);
	          component.set("v.sOtherProgName",params.objService.sOtherProgName);

	          if(!$A.util.isEmpty(params.objService.sServiceId)) {
	              selectedService = params.objService.sServiceName;
	              selectedProgram = params.objService.sCurrentlyGettingProgramName;            
	          }
	          else {
	              //lstServiceOptions;
	              var bExist = false;
	              lstServiceOptions.forEach(function(value,iIndex){
	                  if(params.objService.sOtherServiceName === value) {
	                      bExist = true;
	                      return;
	                  }
	              });

	              if(bExist){
	                  selectedService = params.objService.sOtherServiceName;              
	              }else{
	                  selectedService = component.get('v.mapLabels').CC_LBL_OTHER;
	              }
	              selectedProgram = '';
	          }
	          component.set("v.selectedProgram",selectedProgram);
	          component.set("v.selectedService",selectedService);
	          component.set("v.bCurrentlyGetting",params.objService.bGettingCurrently);
	          component.set("v.bNeededInFuture",params.objService.bNeededInFuture);
      }else{
          	console.debug('Add Invoked');
      }
      component.set('v.sConcatServProg',component.get('v.selectedService')+'+'+component.get('v.sOtherServiceName')
      					+'+'+component.get('v.selectedProgram')+'+'+component.get('v.sOtherProgName'));
      console.debug('concat++++++  :'+component.get('v.sConcatServProg'));
      component.set('v.bLoaded',true);
      console.debug('Otherval:',component.get("v.sOtherLabel"));
	}
     
})