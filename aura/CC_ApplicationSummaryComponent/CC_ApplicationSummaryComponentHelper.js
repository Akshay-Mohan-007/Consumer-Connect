({
    loadPage : function(component,event) {
        
        console.log('load called');
        var strAppId = component.get("v.strAppId");
        //component.set("v.bIsDataLoaded",false);
        console.log('Id is'+component.get("v.strAppId"));
        this.callServer(component, "c.loadSummaryData", function(response) { 
            
            var result=JSON.parse(response);
            
            
            component.set("v.objApp",result.ObjApplication);
            var objContact = result.ObjContact;
            objContact.Phone = this.autoFormat(objContact.Phone);
            objContact.OtherPhone = this.autoFormat(objContact.OtherPhone);

            if(!$A.util.isEmpty(result.ObjRepContact)){
                var objRepContact = result.ObjRepContact;
                var PhyAddress = objRepContact.Formatted_Physical_Address__c;
                var MailAddress = objRepContact.Formatted_Mailing_Address__c;
                if(!$A.util.isEmpty(PhyAddress) && PhyAddress.includes(",,"))
                    PhyAddress = PhyAddress.replace(",,",",");
                if(!$A.util.isEmpty(MailAddress) && MailAddress.includes(",,"))
                    MailAddress = MailAddress.replace(",,",",");
                component.set('v.sRepPhyAddress',PhyAddress);
                component.set('v.sRepMailAddress',MailAddress);
                objRepContact.Phone = this.autoFormat(objRepContact.Phone);
                objRepContact.OtherPhone = this.autoFormat(objRepContact.OtherPhone);
                component.set('v.objRepContact',objRepContact);
            } 

            component.set('v.sRepName',result.RepContactName);
            

            if(!component.get('v.objApp').CC_Individual_Also_Your_Legal_Guardian__c){
                if(!$A.util.isEmpty(result.ObjLegContact)){
                    var objLegContact = result.ObjLegContact;
                    var PhyAddress = objLegContact.Formatted_Physical_Address__c;
                    var MailAddress = objLegContact.Formatted_Mailing_Address__c;
                    if(!$A.util.isEmpty(PhyAddress) && PhyAddress.includes(",,"))
                        PhyAddress = PhyAddress.replace(",,",",");
                    if(!$A.util.isEmpty(MailAddress) && MailAddress.includes(",,"))
                        MailAddress = MailAddress.replace(",,",",");
                    component.set('v.sLegPhyAddress',PhyAddress);
                    component.set('v.sLegMailAddress',MailAddress);
                    objLegContact.Phone = this.autoFormat(objLegContact.Phone);
                    objLegContact.OtherPhone = this.autoFormat(objLegContact.OtherPhone);
                    component.set('v.objLegContact',objLegContact);
                    component.set('v.sLegalName',result.LegalContactName); 
                }
        }
        else{
            component.set('v.objLegContact',component.get('v.objRepContact'));
            component.set('v.sLegPhyAddress',component.get('v.sRepPhyAddress'));
            component.set('v.sLegMailAddress',component.get('v.sRepMailAddress'));
            component.set('v.sLegalName',component.get('v.sRepName')); 
        }

                   
           
            var bIsSituationWorking = (component.get("v.objApp").CC_Is_Living_Situation_Working__c) ? 'YES' : 'NO';
            var bIsWavierOnWaitingList = (component.get("v.objApp").CC_On_Any_Waiver_Waiting_List__c) ? 'YES' : 'NO';
			
            component.set("v.sVisitedPages",component.get("v.objApp").Visited_Pages__c);
            component.set("v.objContact",objContact);
            component.set("v.sName",result.ContactName);
            component.set("v.sMailingAddress",result.MailingAddress);
            component.set("v.sResidentAddress",result.ResidentAddress);
            component.set("v.lstSuffix",result.pickListWrapper);
            //component.set("v.lstAppDetailService",result.ServiceWrapper.AppDetailInfo.lstRelatedServiceDetail);
            component.set("v.mapLabels",result.MapLabels);
            component.set("v.bOnBehalfApplicant",result.ObjApplication.CC_Applying_on_behalf_of_applicant__c);
            component.set("v.bSignatureReceived",result.ObjApplication.CC_Hard_copy_Signature_received__c);
            component.set("v.bCorrectInfo",result.ObjApplication.CC_Information_is_correct__c);                        
            component.set('v.bIsSituationWorking',bIsSituationWorking);
            component.set('v.bIsWavierOnWaitingList',bIsWavierOnWaitingList);
            component.set('v.lstDocs',result.lstDocs);

            var lstRelService = result.ServiceWrapper.AppDetailInfo.lstRelatedServiceDetail;
            for(var i=0; i<lstRelService.length; i++){
                if(!lstRelService[i].bGettingCurrently){
                    if($A.util.isEmpty(lstRelService[i].sCurrentlyGettingProgramName))
                        lstRelService[i].sCurrentlyGettingProgramName = 'NA';
                    if($A.util.isEmpty(lstRelService[i].sServiceName) && !$A.util.isEmpty(lstRelService[i].sOtherServiceName)){
                        lstRelService[i].sServiceName = lstRelService[i].sOtherServiceName;
                        lstRelService[i].sOtherServiceName = '';
                    }  
                }
                if(lstRelService[i].sServiceName === 'Other' && !$A.util.isEmpty(lstRelService[i].sOtherServiceName)){
                    lstRelService[i].sServiceName =  lstRelService[i].sServiceName+
                             ' - ' + lstRelService[i].sOtherServiceName;
                }
                if(lstRelService[i].sCurrentlyGettingProgramName === 'Other' && !$A.util.isEmpty(lstRelService[i].sOtherProgName)){
                    lstRelService[i].sCurrentlyGettingProgramName =  lstRelService[i].sCurrentlyGettingProgramName+
                             ' - ' + lstRelService[i].sOtherProgName;
                }
            }

            component.set("v.lstAppDetailService",lstRelService);

            if(!$A.util.isEmpty(component.get("v.objApp").CC_Describe_why_services_are_needed__c)){
                if(component.get("v.objApp").CC_Describe_why_services_are_needed__c.length > 20){
                    component.set("v.bIsLongText",true);
                    var sShortText = component.get("v.objApp").CC_Describe_why_services_are_needed__c.substr(0,20);
                    component.set("v.sShortWhyServiceNeeded",sShortText);
                }
                else{
                    component.set("v.sShortWhyServiceNeeded",component.get("v.objApp").CC_Describe_why_services_are_needed__c);
                }
            }
              

        },{
        "appId": component.get("v.strAppId")
        });
        
    },
    
    validate:function(component, event){
        
        var firstName = component.get("v.sFirstName");
        var middleName = component.get("v.sMiddleName");
        var LastName = component.get("v.sLastName");
        var Suffix = component.get("v.sSuffix");
        var objApplication = component.get("v.objApp");
        var objContact = component.get("v.objContact");
        var lstErrors = [];
        var mapLabels = component.get("v.mapLabels")
        
        component.set('v.lstErrors',[]);
        component.set("v.bIsError",false);
        component.set("v.bIsFirstNameError",false);
        component.set("v.bIsMiddleNameError",false);
        component.set("v.bIsLastNameError",false);
        component.set("v.bIsSuffixError",false);
        

        if($A.util.isEmpty(firstName)){
            lstErrors.push(mapLabels.CC_Err_First_Name_Mandatory);
            component.set("v.bIsFirstNameError",true);
        }
        else if(firstName.toUpperCase() !== objContact.FirstName.toUpperCase()){
            lstErrors.push(mapLabels.CC_Err_First_Name_Not_Matching);
            component.set("v.bIsFirstNameError",true);
        }
        
         if(!$A.util.isEmpty(middleName)){
                if(middleName !== objContact.CC_Middle_Initial__c){
                    lstErrors.push(mapLabels.CC_Err_Middle_Name_Not_Matching);
                    component.set("v.bIsMiddleNameError",true);
            }
        }

        if(!$A.util.isEmpty(Suffix)){
                if(Suffix !== objContact.CC_Suffix__c){
                    lstErrors.push(mapLabels.CC_Err_Suffix_Not_Matching);
                    component.set("v.bIsSuffixError",true);
            }
        }
        
        if($A.util.isEmpty(LastName)){
            lstErrors.push(mapLabels.CC_Err_Last_Name_Mandatory);
            component.set("v.bIsLastNameError",true);
        }
        else if(LastName.toUpperCase() !== objContact.LastName.toUpperCase()){
            lstErrors.push(mapLabels.CC_Err_Last_Name_Not_Matching);
            component.set("v.bIsLastNameError",true);
        }
        
        if(!component.get('v.bOnBehalfApplicant')){
            lstErrors.push(mapLabels.CC_Err_confirm_Applying_onBehalf_Applicant);
            component.set("v.bIsError",true);
        }
        
        if(!component.get('v.bSignatureReceived')){
            lstErrors.push(mapLabels.CC_Err_confirm_Signature_received );
            component.set("v.bIsError",true);
        }
        
        if(!component.get('v.bCorrectInfo')){
            lstErrors.push(mapLabels.CC_Err_confirm_correct_information);
            component.set("v.bIsError",true);
        }

        component.set("v.lstErrors",lstErrors); 
        
    },
    
    savePage:function(component, event){
        
        var objApplication = component.get("v.objApp"); 
        
        var objwrapApp = {
            'bIntakeOnBehalfApplicant': component.get('v.bOnBehalfApplicant'),
            'bCorrectInfo': component.get('v.bCorrectInfo'),
            'bSignatureReceived': component.get('v.bSignatureReceived'),
            'sAppId': component.get("v.strAppId")
        };
        
        this.callServer(component, "c.saveSummaryData", function(response) {
            
            var result= response;
            if(response === 'SUCCESS'){
                component.set('v.sFirstName','');
                component.set('v.sMiddleName','');
                component.set('v.sLastName','');
                component.set('v.sSuffix','');
            }            
        },{
            "sJSON" : JSON.stringify(objwrapApp)
        });
        
    },

    submitApp : function(component, event,callback){
        var sAppId = component.get('v.strAppId');
        var sConId = component.get('v.objContact').Id;
        var sCurrentStatus = component.get('v.objApp').CC_App_Status__c;
		var sVisitedPage = component.get('v.sVisitedPages');
        var lstErrors = [];
        component.set('v.lstErrors',[]);
        var lstTabNames = [];
        if(!$A.util.isEmpty(sVisitedPage)){
                
                var bIsTabMissing = false;

            if(!sVisitedPage.includes('Contact Information')){
                lstTabNames.push('CC_ContactInformation');
                bIsTabMissing = true;
            }
            if(!sVisitedPage.includes('Representative Information')){
                lstTabNames.push('CC_RI_Infro');
                 bIsTabMissing = true;
            }
            if(!sVisitedPage.includes('Services')){
                lstTabNames.push('CC_Services_Component');
                 bIsTabMissing = true;
            }
            if(!sVisitedPage.includes('Living Situation')){
                lstTabNames.push('CC_LivingSituation');
                 bIsTabMissing = true;
            }
            if(!sVisitedPage.includes('Documents')){
                lstTabNames.push('CC_FileUpload_Component');
                 bIsTabMissing = true;
            }

            component.set('v.lstTabNames',lstTabNames);

            /*if(!bIsTabMissing){

                var bIsAlreadySubmitted = false;   

                if(sCurrentStatus === 'Revision Needed')
                    bIsAlreadySubmitted = true;
                        
                this.callServer(component, "c.submitApplication" , function(response){
                    //this.showToast('Success', response, 'success', 'sticky', 5000);
                    var result = response;
                    component.set('v.sFirstName','');
                    component.set('v.sMiddleName','');
                    component.set('v.sLastName','');
                    component.set('v.sSuffix','');
                }, {
                    "sAppId" : sAppId,
                    "sConId" : sConId,
                    "bIsAlreadySubmitted" : bIsAlreadySubmitted

                });
          }*/
        }
        else{
            lstTabNames = ['CC_ContactInformation','CC_RI_Infro','CC_Services_Component',
                                'CC_LivingSituation','CC_FileUpload_Component'];
            component.set('v.lstTabNames',lstTabNames);
        }
        this.consoleLog('lstTabNames',false,lstTabNames);
        if($A.util.isEmpty(lstTabNames)){

                var bIsAlreadySubmitted = false;   

                if(sCurrentStatus === 'Revision Needed')
                    bIsAlreadySubmitted = true;
                        
                this.callServer(component, "c.submitApplication" , function(response){
                    //this.showToast('Success', response, 'success', 'sticky', 5000);
                    if(callback)
                    	callback.call(this,[]);
                    var result = response;
                    component.set('v.sFirstName','');
                    component.set('v.sMiddleName','');
                    component.set('v.sLastName','');
                    component.set('v.sSuffix','');
                }, {
                    "sAppId" : sAppId,
                    "sConId" : sConId,
                    "bIsAlreadySubmitted" : bIsAlreadySubmitted

                });
          }else if(callback)
              callback.call(this,lstTabNames);
    },

    phoneFormat:function(sPhone){
        this.consoleLog('sPhone: ' +sPhone);
        var formatted = this.autoFormatPhoneNo(sPhone);
        this.consoleLog('formatted: ' +formatted);
        return formatted;
    },
    autoFormat:function(sPhone){
        if(!$A.util.isEmpty(sPhone)){
            var splitPhone = sPhone.split('+');
            if(splitPhone[0].length === 10)
                splitPhone[0] = this.phoneFormat(splitPhone[0]);
            return splitPhone[0];
    	}
     else
         return '';
    },

    saveMaster : function(component, event, callback){
        this.validate(component, event);
         var lstErrors = component.get('v.lstErrors');
         if(lstErrors.length === 0){
            this.savePage(component, event);
        }
        if(callback)
            callback.call(this,lstErrors);
    },

    submitMaster : function(component, event, callback){
        this.validate(component, event);
        var lstErrors = component.get('v.lstErrors');
        
        if($A.util.isEmpty(lstErrors))//lstErrors.length === 0 && component.get('v.lstTabNames').length === 0){
            this.submitApp(component, event,callback);
        else if(callback)/*{
            if($A.util.isEmpty(lstErrors))
            	callback.call(this,component.get('v.lstTabNames'));
        	else*/
                callback.call(this,"ERROR");
        //}
            
    }  
})