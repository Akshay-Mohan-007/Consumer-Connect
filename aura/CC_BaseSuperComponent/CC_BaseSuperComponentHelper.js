({    
    /* [Srivatsan 01-Feb-2017] Function for making server calls from a central place. All other components will inherit base super to call the server method. */
    /* [Wesly 28-Mar-2017] Updated the function to capture call stack and invoke errorLogger method */
    callServer : function(cmp, method, callback, params, cacheable,background) {
        try {
            /* retrieving the call stack before executing the server call */
            /*var sCallStack = "";//storing call stack
            try {   throw new Error();  }   catch(e)    {   sCallStack = String(e.stack);   }
            var callStackFinal = sCallStack.slice(0, sCallStack.indexOf("aura_proddebug.js:") + 25).trim();*/
            //this.consoleLog("callStackFinal:" + callStackFinal);
            this.consoleLog("Component: "+cmp.getName());
            var action = cmp.get(method);
            var baseComp = cmp.getSuper();
            //var isSpinnerActive = baseComp.get("v.isSpinnerActive");
            //this.consoleLog("isSpinnerActive complete: "+isSpinnerActive,false);
            baseComp.set("v.isSpinnerActive",true);
            if (params) {
                action.setParams(params);
            }
            if(background){
                //console.log("In background");
                action.setBackground();
            }
            if (cacheable) {
                action.setStorable();
            }
            
            action.setCallback(this,function(response) {
                this.consoleLog("execution complete: ",false, response);
                var state = response.getState();
                var lightningServerResponse = response.getReturnValue();
                this.consoleLog("lightningServerResponse: ",false, lightningServerResponse);
                baseComp.set("v.isSpinnerActive",false);
                if (state === "SUCCESS") { 
                	callback.call(this,lightningServerResponse);
                    // pass returned value to callback function
                    /*if(lightningServerResponse.isSuccessful){
                        callback.call(this, lightningServerResponse);*/
                        /* invoke method to log error message */
                        /*if(lightningServerResponse.mapErrorInfo !== undefined && lightningServerResponse.mapErrorInfo.length > 0)   {
                            this.consoleLog("error-1");
                            //this.errorLogger("Apex", cmp, method, callStackFinal, response);
                        }
                    } else {     */               
                        /* invoke method to log error message */
                        //this.consoleLog("error-2");
                        /*//console.log(JSON.stringify(lightningServerResponse));
                        //this.errorLogger("Apex", cmp, method, callStackFinal, response);
                    }*/
                } else if (state === "ERROR") {
                    //console.error("response: " + JSON.stringify(response.getError()));
                    /* invoke method to log error message */
                    this.consoleLog("Error calling the server",true,response.getError());
                    //this.errorLogger("Apex", cmp, method, callStackFinal, response);
                }
            });
            $A.enqueueAction(action);
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    /* [WeslyJ 15-Feb-2017] Function to create single/multiple components */
    generateComponent: function(containerComponent, placeholder, noOfComponents, 
                                componentType, componentAttributes, componentArray, callback) {
        try {
            /*Parameters: 
        containerComponent --> main component in which the new components will be created
        placeholder --> format "v.<attr>", specifies the attribute in containerComponent where the new components should be placed
        noOfComponents --> specifies "single" or "multiple"
        componentType --> specifies the tag of the new component. Example: ui:outputText, lightning:input, etc.,
        componentAttributes --> object containing the attributes for the componentType. example: { "label":"hello", "value":"world" }
        componentArray --> array of components to be created. example: [["lightning:input",{"type" : "text","name" : "test1","value" : "sample"}],["lightning:input",{"type" : "number","name" : "test2","value" : 23}]
    */
            if(noOfComponents === "single") {
                //[WeslyJ 15-Feb-2016] Create single component
                $A.createComponent(
                    componentType, componentAttributes, function(newComponent, status, errorMessage)    {
                        containerComponent.set(placeholder, newComponent);
                        if(callback) callback.call(this, newComponent);
                    }
                );
            }
            else    {
                //[WeslyJ 15-Feb-2016] Create multiple components
                $A.createComponents(
                    componentArray, function(newComponents, status, errorMessage)   {
                        containerComponent.set(placeholder, newComponents);
                        if(callback) callback.call(this, newComponent);
                    }
                );
            }
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    /*[Srivatsan 17-Feb-2017] Function to navigate to a new page*/
    /* [Chirag 11-Aug-2017] Added changes so that relative paths can be used when page is not at current level */
    /* [Chirag 20-Sept-2017] Added newTab parameter so that URLs can be opened in a new tab when needed */
    navigateToPage: function(page, redirect, newTab, useEvent) {
        try {
            /*Parameters:
            page (string) --> the page to be navigated. for example: "isd-needs-assessment-domain-selection?AssessmentID=a0135000000iR2RAAU"
            redirect (boolean) --> value for the isredirect parameter of force:navigateToURL event
            newTab (boolean) --> if this is true, link will open in new tab. This will only work for URLs which start with '.' */
            if (page[0] === '.' && (useEvent === undefined || !useEvent)) {
            /*if (page[0] === '.' || newTab) {*/
                if (newTab) {
                    window.open(page, '_blank');
                } else {
                    var tempLink = document.createElement('a');
                    tempLink.href = page;
                    document.location = tempLink.href;
                    
                }
            }
            else {
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": (useEvent) ? page : '/' + page,
                    /*"url": '/' + page,*/
                    "isredirect" : redirect
                });
                urlEvent.fire();    
            }
        } catch(e) { 
            this.consoleLog(e.stack, true); 
        }
        
    },
    
    /* [WeslyJ 01-Mar-2017] Function to retrieve the attributes (as object) from the URL query string */
    getURLQueryStringValues: function() {
        try {
            /* Example URL: /s/isd-needs-assessment-domain-selection?attr1=value1&attr2=value2 
            oQueryString will be as follows:
            {"attr1":"value1", "attr2";"value2" }*/
            // [Chirag - 03-July-2017] - Changed this from window.location / new URL because of MS browser problems
            var url = document.createElement('a');
            url.href = document.URL;
            //var url = new URL(document.URL);
            var sQueryString = url.search.substring(1);
            //var sQueryString = window.location.search.substring(1);
            var aQueryString = sQueryString.split("&");
            var oQueryString = {};
            oQueryString["PathName"] = url.pathname;
            for(var i=0; i<aQueryString.length; i++)
            {
                var aStr = aQueryString[i].split("=");
                oQueryString[aStr[0]] = aStr[1];
            }
            return oQueryString;
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    /* [Wesly 15-Feb-2017] Function to display message in browser console */
    consoleLog: function(message, error,objGeneric)    {
        try {
            /*Parameters:
            message (string) --> message to be displayed
            error (boolean) --> parameter to be set only for error messages primarily from catch blocks */
            var sCallStack = "";//storing call stack
            try {   throw new Error();  }   catch(e)    {   sCallStack = String(e.stack);   }
            var originalLine = sCallStack.split("\n")[2].trim();
            var sConsoleLog = $A.get("$Label.c.CC_Console_Logger");
            var sShowError = sConsoleLog.split("|")[0];
            var sShowMessage = sConsoleLog.split("|")[1];
            if(error && sShowError === "Yes")   {
                if(objGeneric)
                    console.error(message,objGeneric);
                else
                    console.error(message);
                
            }
            else if(sShowMessage === "Yes") {
                // [Chirag - 05-July-2017] - Printing a table for easier readability when applicable
                if (((Array.isArray(message) && typeof(message[0]) === "object")) && (console.table !== undefined)) {
                    console.table(message);
                } else if(objGeneric){
					console.debug(message,objGeneric);
                } else {
                    console.debug(message);
                }
                //console.log(message);
                console.debug(originalLine);
            }
            //this.errorLogger("Lightning", null, null, null, message);
        } catch(e) {
            console.error(e.stack);
        }
    },
    
    //[Srivatsan 15-Mar-2017] for formatting all generic phone number formats
    getPhonenoFormatted: function(phonenumber)  {
        try {
        	this.consoleLog('phonenumber: ' + phonenumber);
            if(phonenumber) return phonenumber.match(new RegExp('\\d{4}$|\\d{3}', 'g')).join("-");
            else
                return "ERROR";
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    //[Devashree 5-May-2017] for formatting all generic zip code formats
    getZipCodeFormatted: function(zipCode)  {
        try {
            if(zipCode) return zipCode.match(new RegExp('\\d{4}$|\\d{5}', 'g')).join("-");
            else
                return "ERROR";
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    //[Devashree 15-May-2017] for formatting all generic ssn format
    /*getSSNFormatted: function(ssn)    { 
        if(ssn) return ssn.match(new RegExp('.{1,4}$|.{1,3}', 'g')).join("-");
        else
            return "ERROR";
    },*/
    
    //[Srivatsan 16-Mar-2017] for merging null values into object record values
    //obj1 - dataformatarray , obj2 - actual data array
    merge : function(obj1, obj2){
        try {
            var obj3 = {};
            var attrname;
            for (attrname in obj1) { obj3[attrname] = obj1[attrname]; }
            for (attrname in obj2) { obj3[attrname] = obj2[attrname]; }
            return obj3;
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    /* [Wesly 23-Feb-2017] Function to log error message in the error log object */
    errorLogger : function(source, component, method, callStack, lResponse) {
        try
        {
            var sMaskErrorLog = $A.get("$Label.c.ISDErrorMaskMsg");
            var sMaskMsgToUI = sMaskErrorLog.split("|")[0];
            var sMaskMsgText = sMaskErrorLog.split("|")[1];
            var sErrorLog = $A.get("$Label.c.ISDErrorLog");
            var sLogLightningErrorToObject = sErrorLog.split("|")[0];
            var sLogLightningErrorToUI = sErrorLog.split("|")[1];
            var sLogApexErrorToObject = sErrorLog.split("|")[2];
            var sLogApexErrorToUI = sErrorLog.split("|")[3];
            var sLogErrorToObject = (source === "Lightning" ? sLogLightningErrorToObject : (source === "Apex" ? sLogApexErrorToObject : "No"));
            var sLogErrorToUI = (source === "Lightning" ? sLogLightningErrorToUI : (source === "Apex" ? sLogApexErrorToUI : "No"));
            if(sLogErrorToObject === "Yes" || sLogErrorToUI === "Yes")  {
                var mapErrorInfo = new Map();
                if(source === "Apex")   {
                    switch(lResponse.getState())    {
                        case "SUCCESS":
                            if(lResponse.getReturnValue().mapErrorInfo !== undefined)   {
                                mapErrorInfo = lResponse.getReturnValue().mapErrorInfo;
                            }
                            mapErrorInfo["Response JSON"] = JSON.stringify(lResponse.getReturnValue().objectData);
                            break;
                        case "ERROR":
                            var arrError = lResponse.getError();
                            var sError = "";
                            for(var i=0; i<arrError.length; i++)    {
                                sError += arrError[i].message;
                            }
                            mapErrorInfo["Error Message"] = sError;
                            mapErrorInfo["Severity"] = "High";
                            break;
                        default:
                            break;
                    }
                    
                    /* Get calling component name & method stack */
                    mapErrorInfo["Component Name"] = component.toString();
                    mapErrorInfo["Component Method"] = callStack;
                    
                    mapErrorInfo["Class Method"] = method.substring(2);
                    mapErrorInfo["Request JSON"] = JSON.stringify(lResponse.getParams());
                }
                if(source === "Lightning")  {
                    /* pending - might be introduced later */
                }
                
                /* Get device information */
                var sDevice = $A.get("$Browser.formFactor");
                mapErrorInfo["Device"] = sDevice;
                
                /* Get browser information */
                mapErrorInfo["Browser"] = navigator.userAgent;
                mapErrorInfo["Language"] = navigator.language;
                
                this.consoleLog("mapErrorInfo:" + JSON.stringify(mapErrorInfo));
                var baseComp;
                if(source === "Apex")   {   baseComp = component.getSuper();    }
                /* Condition to avoid recursive server call */
                if(method !== "c.logApplicationError" && baseComp !== undefined)    {
                    /* Show error message in UI as banner */
                    if(sLogErrorToUI === "Yes") {
                        baseComp.set("v.ISDShowMessage", true);
                        if(sMaskMsgToUI === "Yes")             {
                            baseComp.set("v.ISDErrorMessage", sMaskMsgText);
                        }
                        else             {
                            baseComp.set("v.ISDErrorMessage", mapErrorInfo["Error Message"]);
                        }
                    }
                    /* Create error log record through an async call */
                    if(sLogErrorToObject === "Yes") {
                        this.callServer(baseComp, "c.logApplicationError", function(response){
                            /* In case of error, show error message in UI */
                            if(response.mapErrorInfo.length > 0)    {
                                var sActualError = mapErrorInfo["Error Message"];
                                var sInnerError = response.mapErrorInfo !== undefined ? response.mapErrorInfo["Error Message"] : "";
                                baseComp.set("v.ISDShowMessage", true);
                                baseComp.set("v.ISDErrorMessage", "Actual Error:" + sActualError 
                                             + "\n Inner Error:" + sInnerError); 
                            }
                        }, {
                            sErrorInfoFromComp : JSON.stringify(mapErrorInfo)
                        }, false);
                    }
                }
            }
        }
        catch(e)    { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    /* [Chirag 15-May-2017]: Scroll the page to the element (passed as parameter). Element must be an html tag and not a lightning tag */
    scrollToElement: function(element) {
        try {
            var currentScrollPos = pageYOffset;
            var targetScrollPos = (currentScrollPos + element.getBoundingClientRect().top + parseInt(getComputedStyle(element).height.match(/\d+/)[0],10) - (innerHeight / 2));
            this.consoleLog(('currentScrollPos: ' + currentScrollPos + ', top: ' + element.getBoundingClientRect().top + ', height: ' + parseInt(getComputedStyle(element).height.match(/\d+/)[0], 10) + ', innerHeight / 2: ' + (innerHeight / 2) + ', targetScrollPos: ' + targetScrollPos));
            var scrollToStep = setInterval(function() {
                if (currentScrollPos < targetScrollPos) {
                    scrollTo(0, currentScrollPos);
                    currentScrollPos += 3;
                } else {
                    clearInterval(scrollToStep);
                }
            }, 5);
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    /* [Chirag 16-May-2017]: Split custom label into an array of strings. To be used when you've a paragraph of text with a few words bold in it. Label string has to be separated by '||' where you wish to start and end bold text */
    /*splitLabelToArr: function(label) {
        return $A.get(label).split('||');
    }*/
    
    /* [Raghav 14-Aug-2017] : Split meta data field content based on the delimiter '|' */
    splitMetaDataLabels : function(field){
        try {
            var temp=''; 
            var lstLabels = [];
            lstLabels = field.split('|');
            this.consoleLog(lstLabels);
            for(var label in lstLabels){
                temp = temp + $A.get("$Label.c."+lstLabels[label]);                                                                     
            } 
            
            return temp;
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    /*Devashree 07/05/2017 generic code to remove non-digit and non-hyphen character */
    removeNonDigitHyphenCharacters: function(inputString){
        try{
            if(!/^[0-9-]+$/.test(inputString.slice(-1))){
                inputString = inputString.slice(0, -1);
            }
            return inputString;
        }
        catch (e) {
            this.consoleLog(e.stack, true);
            return "ERROR";
        }
    },        
    /*Devashree [24/05/2017] Auto formatting of phone number. This method does not allow to enter any characters other than digits and hyphen*/
    autoFormatPhoneNo: function(phonenumber){
        try{
            if(phonenumber){
                /* Ashutosh [13/10/2017] replacing all the hyphens before proceeding */
                var updatedValue = phonenumber.replace(/-/g, "");
                if(/^\d{10}$/.test(updatedValue)){ //
                    phonenumber = updatedValue.match(new RegExp('\\d{4}$|\\d{3}', 'g')).join("-");
                }
                else{
                    phonenumber = this.removeNonDigitHyphenCharacters(phonenumber);
                }
            }  
            return phonenumber;
        }
        catch (e) {
            this.consoleLog(e.stack, true);
            return "ERROR";
        }
    },
    /*Devashree [24/05/2017] Auto formatting of zip code. This method does not allow to enter any characters other than digits and hyphen*/
    autoFormatZipCode: function(zipCodeNumber){
        try{
            if(zipCodeNumber !== undefined){
                if(/^\d{5}$/.test(zipCodeNumber) || /^\d{9}$/.test(zipCodeNumber)){
                    zipCodeNumber = zipCodeNumber.match(/\d{4}$|\d{5}/g).join("-");
                }
                //Check Entered character is not digit or hyphen
                else{
                    zipCodeNumber = this.removeNonDigitHyphenCharacters(zipCodeNumber);
                }
            }  
            return zipCodeNumber;
        }
        catch (e) {
            this.consoleLog(e.stack, true);
            return "ERROR";
        }
    },
    /*Devashree [24/05/2017] Auto formatting of SSN. This method does not allow to enter any characters other than digits and hyphen*/
    autoFormatSSN: function(originalSSN){
        try{
            if(originalSSN !== undefined){
                if(/^\d{9}$/.test(originalSSN)){
                    originalSSN = originalSSN.replace(/(\d{3})\-?(\d{2})\-?(\d{4})/,'$1-$2-$3');
                }
                else{
                    originalSSN = this.removeNonDigitHyphenCharacters(originalSSN);
                }
            }  
            return originalSSN;
        } 
        catch (e) {
            this.consoleLog(e.stack, true);
            return "ERROR";
        }
    },
    
    /*Devashree [25/05/2017] Check for invalid and future date 
    *Error Message : ISD_HA_invalidDate_Error [Rule : 6197]*/
    checkDobValidity: function(originalDob){
        try{
            if(originalDob){
                //invalid year
                if(originalDob.substr(originalDob.length - 4) === '0000'){
                    return true;
                }
                var dobDate = new Date(originalDob.replace(/-/g, '/')); 
                var today = new Date();
                //valid calendar date
                //var dobArray = originalDob.split('/');
                ////|| dobDate.getDate() !== parseInt(dobArray[1], 10)
                if (dobDate.toString() === "Invalid Date" ) {
                    return true;
                } 
                //check for future date
                if( dobDate > today ){                    
                    return true;
                }
                //age cannot be greater than 120 years
                var age = today.getFullYear() - dobDate.getFullYear();
                var m = today.getMonth() - dobDate.getMonth();
                if (m < 0 || (m === 0 && today.getDate() < dobDate.getDate())) 
                {
                    age--;
                }
                if(age > 120){
                    return true;
                }
                //date has to be between January 1, 1700 and Dec 31 4000
                var minDate = new Date($A.get("$Label.c.ISD_Minimum_Valid_Date"));
                var maxDate = new Date($A.get("$Label.c.ISD_Maximum_Valid_Date"));
                if(originalDob < minDate || originalDob > maxDate){  
                    return true;
                }
            }
            else{return false;}
        }
        catch (e) {
            this.consoleLog(e.stack, true);
            return "ERROR";
        }
    },
    /*Devashree [23/08/2017] Check for future date */
    checkFutureDob: function(originalDob){
        try {
            originalDob = new Date(originalDob.replace(/-/g, '/'));
            if(originalDob){
                var dobDate = new Date(originalDob); 
                var today = new Date();
                if(dobDate > today ){                    
                    return true;
                }
                else{
                    return false;
                }
            }
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    /*Devashree [23/08/2017] Check for Invalid calendar date */
    checkInValidDate: function(originalDob){
        try {
            if(originalDob){
                var dobDate = new Date(originalDob);
                var dobArray = originalDob.split('/');
                if (dobDate.toString() === "Invalid Date" || dobDate.getDate() !== parseInt(dobArray[1], 10)) {
                    return true;
                }
            }
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    /*Devashree [24/05/2017] Auto formatting of DOB. This method does not allow to enter any characters other than digits and forward slash*/
    autoFormatDOB: function(originalDob){
        try{
            if(originalDob !== undefined){
                if(/^\d{8}$/.test(originalDob) || /^\d{2}\/\d{2}\/\d{4}$/.test(originalDob)){
                    originalDob = originalDob.replace(/(\d\d)(\d\d)(\d\d\d\d)/g, '$1/$2/$3');
                }
                //Entered character is not digit 
                else if(!/^[0-9/]+$/.test(originalDob.slice(-1))){
                    originalDob = originalDob.slice(0, -1);
                }
            }
            return originalDob;
        }
        catch (e) {
            this.consoleLog(e.stack, true);
            return "ERROR";
        }
    },
    /* [Radhika 08-Aug-2017 function to format DOB to  MM/DD/YYYY format  */
    formatDOB : function(dob) {   
        try{   
            var finalDob  = '';
            var dobDate = new Date(dob.replace(/-/g, '/'));  //yyyy-mm-dd format
            //added by K.R.Srivatsan for defect 13794 to fix date getting converted based on users machines timezone
            //https://stackoverflow.com/questions/33090987/convert-date-of-birth-to-javascript-date?noredirect=1&lq=1
            this.consoleLog("dobDate" + dobDate);
            var dd = dobDate.getDate(); 
            var mm = dobDate.getMonth()+1; 
            var yyyy = dobDate.getFullYear();
            if(dd<10){ dd='0'+dd; } 
            if(mm<10){ mm='0'+mm; } 
            finalDob = mm+'/'+dd+'/'+yyyy; // MM/DD/YYYY format
            
        }
        catch (e) {
            this.consoleLog(e.stack, true);
        }   
        return finalDob;  
    },
    /* [Wesly 12-Jun-2017] function to clone javascript object */
    cloneObject: function(obj)  {
        try
        {
            if (obj===undefined || obj===null) return undefined;
            function ClonedObject() {};  
            var clone = new ClonedObject();
            for (var p in obj) {
                var d=Object.getOwnPropertyDescriptor(obj, p);
                if (d && (d.get || d.set)) Object.defineProperty(clone, p, d); else clone[p] = obj[p];
            }
            Object.setPrototypeOf(clone, obj);
            return clone;
        }
        catch(e)    {
            this.consoleLog(e.stack, true);
        }
    },
    
    /* [Khushboo 3-July-2017] function for browser back button functionality of NASP */
    checkBrowserBack: function(component) {
        try{
            var baseComp = component.getSuper();
            if(!(this.localStorageGetItem('stepPageMeta') && this.localStorageGetItem('nsstep'))){
                this.callServer(component, "c.getNSStepPageMapping", function(response){
                    this.localStorageSetItem('stepPageMeta',JSON.stringify(response.objectData["stepPageMeta"]));
                    this.localStorageSetItem('nsstep',response.objectData["NSStep"]);
                    this.checkBrowserBackWithMeta();
                },{},false);
            }
            else
                this.checkBrowserBackWithMeta();
        }
        catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    /* [Khushboo 4-July-2017] function for browser back button functionality of NASP after the stepPageMeta session variable is defined*/
    checkBrowserBackWithMeta: function() {
        try{
            var currPage = document.URL.match(/[^\/]+$/)[0].split('?')[0];
            var stepPage = '';
            var currPageStep = '';
            console.log('Step :'+this.localStorageGetItem('nsstep'));
            if(this.localStorageGetItem('nsstep') !== null && this.localStorageGetItem('nsstep') !== ''){
                var stepMeta = JSON.parse(this.localStorageGetItem('stepPageMeta'));
                for(var i=0;i<stepMeta.length;i++)
                {
                    if(stepMeta[i].Step__c === this.localStorageGetItem('nsstep')){
                        stepPage = stepMeta[i].Community_Page_Name__c;
                    } 
                    if(stepMeta[i].Community_Page_Name__c === currPage){
                        currPageStep = stepMeta[i].Step__c;
                    }
                }
                if(currPage !== stepPage){
                    switch(this.localStorageGetItem('nsstep')){
                        case "NS My Resources":
                            this.navigateToPage(stepPage);
                            break;
                        case "NS Topic Questions":
                            this.localStorageSetItem('backclicked','true');
                            this.navigateToPage(stepPage);
                            break;
                        default:
                            this.localStorageSetItem('nsstep',currPageStep);
                            break;
                    }
                }
            }
        }
        catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    /* [Chirag - 03-July-2017] - A shim for browsers that don't support position sticky. Pass an HTML element (not aura component) here and it will stick to the header when the user scrolls past it
     * Second parameter is optional, only needed when scrolling inside a container element (not scrolling on page's parent container)
    */
    stickyOnScroll: function(element, containerElement) {
        try {
            element = element || document.querySelector('.slds-is-sticky');
            // Check for sticky support in browser
            if(element!==null){ 
                var elementPosition = window.getComputedStyle(element).position;
                if ((elementPosition !== 'sticky') && (elementPosition !== '-webkit-sticky')) {
                    containerElement = containerElement || window;
                    var elementTop = element.offsetTop;
                    var elementHeight = element.offsetHeight;
                    containerElement.onscroll = function(scrollEvent) {
                        if (element !== null && element.parentElement !== null) {
                            //var scrollLimit = elementTop + elementHeight;
                            if (containerElement.pageYOffset > elementTop) {
                                element.classList.add('slds-is-fixed');
                                element.style.top = 0;
                                element.parentElement.style.padding = elementHeight + 'px 0 0';
                                //element.style.padding = elementHeight + 'px 0 0 0'; // need this else position fixed causes flicker
                            } else {
                                element.classList.remove('slds-is-fixed');
                                element.style.top = '';
                                element.parentElement.style.padding = '';
                            }
                        }
                    }                    
                }
            }
        }
        catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    /* [Chirag - 05 July 2017] - A function that sorts an Object Array [first parameter] based on the key [passed as second parameter].
     * This function will return a new array and not modify the original array
    */
    sortArrByKey: function(arr, key) {
        try {
            var arrCopy = JSON.parse(JSON.stringify(arr));
            arrCopy.sort(function(a, b){
                var keyA = a[key],
                    keyB = b[key];
                // Compare the 2 objects
                if(keyA < keyB) return -1;
                if(keyA > keyB) return 1;
                return 0;
            });
            return arrCopy;
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    /* [Samidha - 25 July 2017] - A function to shift the focus to required elements and to scroll to top of the page */
    scrollAndFocus:function(main){
        try{
            //To scroll the page to the top
            document.body.scrollTop = document.documentElement.scrollTop = 0;
            //To focus to the element
            if (main !== undefined && main!==null) {
                main.setAttribute('tabindex', '0');
                main.focus();
                main.removeAttribute('tabindex');
            }
        }catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    replaceStringAt: function(str, replaceText, index) {
        try {
            return str.substr(0, index) + replaceText + str.substr(index + replaceText.length);
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    /* [Shibabrata - 3 Aug 2017] - To create a {name : isSelected} Map for the multiselect pills
     * Params: multiSelList - Attribute storing the metadata object's field values
               *         comaSeparatedList - Attribute storing the multiselect's selected values
     * Returns: {name : isSelected} Map for the multiselect pills
               */
    createMultiSelectData : function(multiSelList, comaSeparatedList){
        try{
            var options=[];
            if(multiSelList !== null){
                var mulLength = multiSelList.length;
                for(var i=0; i<mulLength; i++){
                    var newOption = { 'Name' : multiSelList[i] , 'isSelected' : false};
                    options.push(newOption);
                }
            }        
            if(comaSeparatedList !== undefined){            
                //if the list is not null then the init is called onclick of back button
                //comaSeparatedList needs to be converted to array 
                //now find these elements in the multiSelList and mark them selected 
                var flag = -1;            
                var selectedItems = comaSeparatedList.split(';');
                var selLength = selectedItems.length;
                for(var i=0; i<selLength; i++){
                    //for each element search the multiSelList 
                    var flag = multiSelList.indexOf(selectedItems[i]);
                    if(flag!==-1){
                        //set the multiSelList isSelected flag as true
                        options[flag].isSelected = true;
                    }
                }
            }
            return options;
        } catch (e) {
            this.consoleLog(e.stack, true);
        } 
    },
    
    /* [Shibabrata - 3 Aug 2017] - To create semi-colon separated values for multiselect picklist to save in backend
     * Params: options - Attribute storing the multiselect's selected values in {name : isSelected} Map format
     * Returns: semiColonSeparatedList
               */ 
    createSemiColonSepValMultiSelect : function(options){
        try{
            var multiSelList = [];
            var len = options.length;
            var comaSeparatedList = '';
            if(len > 0){
                for(var i=0;i<len ;i++){                    
                    if(options[i].isSelected === true)
                        multiSelList.push(options[i].Name);                    
                }
                comaSeparatedList = multiSelList.join(';');
            }
            return comaSeparatedList;
        } catch (e) {
            this.consoleLog(e.stack, true);
        } 
    },
    
    arrayObjectIndexOf: function(myArray, searchTerm, property) {
        try {
            var arrlength = myArray.length;
            for (var i = 0; i < arrlength; i++) {
                if (myArray[i][property] === searchTerm) return i;
            }
            return -1;
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    //[21/08/2017 : Anoop ] Function to smoothly scroll to the element
    //parameters : toElement - target element
    //Dependant function : easeInOutQuad
    scrollIntoView : function(toElement){
        try {
            var currentScrollPos = pageYOffset;
            var thresholdScrollPos = toElement.offsetTop;
            var change = thresholdScrollPos - currentScrollPos;
            var currentTime=0;
            var increment=20;
            var duration = 1500;
            var thisPointer = this;
            if(currentScrollPos !== thresholdScrollPos)
                var intervalID = setInterval(function() {
                    currentTime += increment;
                    // find the value with the quadratic in-out easing function
                    var val = thisPointer.easeInOutQuad(currentTime, currentScrollPos, change, duration);
                    if(currentTime < duration){
                        window.scrollTo(0,val);
                    }else{
                        clearInterval(intervalID);
                    }
                }, 10);
        }catch(e){
            this.consoleLog(e.stack, true);
        }
    },
    //[17/8/2017 : Anoop ] : Function to control the timing of the animation for scroll
    easeInOutQuad: function(currentTime,start,change,duration){
        try {
            //currentTime = stores the current time value
            //start = start value : initial scroll position
            //change = change in value of the scroll position
            //duration = duration for which the animation should occur
            currentTime /= duration / 2;
            if (currentTime < 1){
                return change / 2 * currentTime * currentTime + start
            }
            currentTime--;
            return -change / 2 * (currentTime * (currentTime - 2) - 1) + start;
        }catch(e){
            this.consoleLog(e.stack, true);
        }
    },
    /* [Chirag - 21st Aug 2017] - This is to fix JAWS by overriding lightning's default behavior where pressing up / down arrow cycles through tabs when it shouldn't  */
    restrictTabKeyPress: function (component, event) {
        try {
            var tabs = document.querySelectorAll('.slds-tabs--default__link');
            
            if (tabs !== null && tabs !== undefined && tabs.length > 0) {
                for (var i = 0; i < tabs.length; i++) {
                    
                    // This needs to be triggered after aura sets tabindex to 0 again
                    (function() {
                        var j = i;
                        setTimeout($A.getCallback(function() {
                            if (tabs[j] !== undefined && tabs[j] !== null) {
                                //this.consoleLog('outerHTML: ' + tabs[j].outerHTML);
                                tabs[j].setAttribute('tabindex', '-1'); 
                            }
                        }), 1000);
                    })();
                    if (tabs[i].querySelector('a')) {
                        tabs[i].querySelector('a').setAttribute('tabindex', '0');
                    }
                }
            }
        } catch(e){
            this.consoleLog(e.stack, true);
        }
    },
    
    // [Chirag - 22nd Aug] - Check if local Storage is supported by browser. A feature detection fails since Safari Incognito mode doesn't respect it, so we need to rely on try catch measures
    isLocalStorageSupported: function() {
        try {
            localStorage.setItem('test', 'test');
            localStorage.removeItem('test');
            return true;
        } catch (e) {
            return false;
        }
    },
    
    // [Chirag - 22nd Aug] - Wrapper for getting localStorage
    localStorageGetItem: function(key) {
        try {
            if (this.isLocalStorageSupported()) {
                return localStorage.getItem(key);   
            } else {
                return this.getCookie(key);
            }
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    // [Chirag - 22nd Aug] - Wrapper for setting localStorage
    localStorageSetItem: function(key, value) {
        try {
            if (this.isLocalStorageSupported()) {
                localStorage.setItem(key, value);
            } else {
                var cookieVal = this.getCookie(key);
                if (cookieVal.length === 0) {
                    return undefined;
                }
                return cookieVal;
            }
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    // [Chirag - 22nd Aug] - Wrapper for getting sessionStorage
    sessionStorageGetItem: function(key) {
        try {
            if (this.isLocalStorageSupported()) {
                return sessionStorage.getItem(key);   
            } else {
                var cookieVal = this.getCookie(key);
                if (cookieVal.length === 0) {
                    return undefined;
                }
                return cookieVal;
            }
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    // [Chirag - 22nd Aug] - Wrapper for setting sessionStorage
    sessionStorageSetItem: function(key, value) {
        try {
            if (this.isLocalStorageSupported()) {
                sessionStorage.setItem(key, value);
            } else {
                this.setCookie(key, value);
            }
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    // [Chirag - 29th Aug] - Wrapper for removing item from localStorage
    localStorageRemoveItem: function(key) {
        try {
            if (this.isLocalStorageSupported()) {
                localStorage.removeItem(key);
            } else {
                this.setCookie(key, '');
            }
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    // [Chirag - 29th Aug] - Wrapper for removing item from sessionStorage
    sessionStorageRemoveItem: function(key) {
        try {
            if (this.isLocalStorageSupported()) {
                sessionStorage.removeItem(key);
            } else {
                this.setCookie(key, '');
            }
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    // [Chirag - 22nd Aug] - Wrapper for getting cookie value
    getCookie: function(cname) {
        try {
            var pattern = new RegExp('(^|.*;\\s)' + cname + '=([^;]+).*')
            var cookie = document.cookie.match(pattern);
            if (cookie !== null && cookie.length > 2) {
                return cookie[2];
            } else {
                return undefined;
            }
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    // [Chirag - 22nd Aug] - Wrapper for setting cookie value
    setCookie: function(cname, cvalue) {
        try {
            //var today = new Date();
            //var expire = new Date(today.getYear() + 1, today.getMonth() + today.getDate());
            //document.cookie = cname + '=' + cvalue + '; expires=' + expire;
            if (cvalue.indexOf(';') !== -1) {
                throw 'Saving semi colons in cookies are not supported!!';
            }
            document.cookie = cname + '=' + cvalue + ';';
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    // [Chirag - 22nd Aug] - Wrapper for clearing localStorage
    localStorageClear: function() {
        try {
            if (this.isLocalStorageSupported()) {
                localStorage.clear();
            } else {
                this.clearCookie();
            }
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    // [Chirag - 22nd Aug] - Wrapper for clearing sessionStorage    
    sessionStorageClear: function() {
        try {
            if (this.isLocalStorageSupported()) {
                sessionStorage.clear();
            } else {
                this.clearCookie();
            }        
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    
    // [Chirag -- 22nd Aug] - Clearing all custom cookies made by our application
    clearCookie: function() {
        try {
            var cookie = document.cookie.split(';');
            for (var i = 0; i < cookie.length; i++) {
                var chip = cookie[i].trim(),
                    entry = chip.split("="),
                    name = entry[0];
                //document.cookie = name + '=; expires=Thu, 01 Jan 1970 00:00:01 GMT;';
                document.cookie = name + '=;';
            }
        } catch(e) {
            this.consoleLog(e.stack, true);
        }
    },
    /*[Devashree 16-Aug-2017 ]
    * checkForSpecialChar method checks if first character is special character
    * return true is first charater is invalid */
    checkForSpecialChar : function(inputText) {
        try {
            if(inputText) return /[^A-Za-z0-9]/.test(inputText.charAt(0));
            else if(inputText === null || inputText === '') return false; 
                else 
                    return "ERROR";
        }catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    /*[Devashree 16-Aug-2017 ]
     *checkEmailValidity method checks if email is x@x.x format
     *return true if email is invalid
     *Error Message : ISD_EmailValidationError [Rule : 6286]*/
    checkEmailValidity : function(OriginalEmailId) {
        try{
                                             var pattern = /^[^\.]([a-zA-Z0-9_+.-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/; //MI login email regex. defect-14986
            //var pattern = /^[a-zA-Z0-9._-]+@[A-Za-z0-9-]+(.[A-Za-z]{2,3})+$/; 
            // var pattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;  
            if(OriginalEmailId){
                //check pattern
                if(!pattern.test(OriginalEmailId) || OriginalEmailId.length < 5)
                    return true;
                //check restricted email domains
                var strDomains = $A.get("$Label.c.ISD_RestrictedEmailDomains");
                var domainsArray = strDomains.split(',');
                var emailArr = OriginalEmailId.split('@');
                var emailInRestrictedDomain = false;
                if(emailArr.length > 1){
                    for(var i=0; i < domainsArray.length; i++){
                        if(emailArr[1].trim() === domainsArray[i].trim()){
                            emailInRestrictedDomain = true;
                        }
                    }
                }
                if(emailInRestrictedDomain) return true;
            }
            return false; 
        }catch(e) { 
            this.consoleLog(e.stack, true); 
        }     
    },
    
   
    
    /*[Devashree 16-Aug-2017 ]
     *checkCityValidity method checks if city has only alphabets and [,-.:] special characters
     *return true if city is invalid
     *Error Meaage : ISD_CityValidationError [Rule:10542]*/
    checkCityValidity : function(OriginalCity) {
        try{
            if(OriginalCity) return !/^[A-Za-z,-.: ]*$/.test(OriginalCity);
            else if(OriginalCity === null || OriginalCity === '') return false; 
                else 
                    return "ERROR";
        }catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    /*[Devashree 16-Aug-2017 ]
     *checkZipCodeValidity method checks if zip code if of xxxxx or xxxxx-xxxx pattern and first five are not zero
     *return true if zip code is invalid 
     *Error Message : ISD_ZipCodeValidationError [Rule: 6196]*/
    checkZipCodeValidity : function(OriginalZip) {
        try{
            var invalid = false;
            if(OriginalZip){           
                if(!/((^\d{5}$)|(^\d{5}(-\d{4})?$))/.test(OriginalZip) || /((^[0]{5}$)|(^([0]{5})\-?(\d{4})$))/.test(OriginalZip)) 
                    invalid = true;
                return invalid;
            }
            else if(OriginalZip === null || OriginalZip === '') return false;
                else 
                    return "ERROR";
        }catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    /*[Devashree 16-Aug-2017 ]
     *checkSSNValidity method checks if SSN is not all 0s
     *return true if SSN is invalid
     *Error Message : ISD_SSNValidationError [Rule : 7706]*/
    checkSSNValidity : function(OriginalSSN, strDobDate) {
        try{
            //this.consoleLog('checkSSNValidity called');
            var invalid = false; //strDobDate
            if(OriginalSSN){    
                //invalid pattern other than xxx-xx-xxxx
                if(/(^((?!\d{3}-\d{2}-\d{4}).)*$)/.test(OriginalSSN)){
                    invalid = true;
                }
                // Cannot be all zeroes
                //All 9 digits cannot be the same.
                else if(/(^[0-]+$)/.test(OriginalSSN)){
                    invalid = true;
                }
                // First digit cannot be 0.
                if (/^0/.test(OriginalSSN)) {
                    console.log('First digit cannot be 0');
                    invalid = true;
                }
                // First 3 digits cannot be between 900 and 999, 000, or 666.
                 console.log('SSN test');
                // The 4th and 5th digits cannot both be zeroes.
               
                // The last 4 digits cannot all be zeroes.
                
                return invalid;
            }
            else if(OriginalSSN === null || OriginalSSN === '') return false;
                else 
                    return "ERROR";
        }catch(e) { 
            this.consoleLog(e.stack, true); 
        }
        
    },
    
    /*[Devashree 16-Aug-2017 ]
     *checkPhoneValidity method checks if phone matched pattern 000-xxx-xxxx or 000-000-0000 or not matching xxx-xxx-xxxx
     *return true if phone is invalid
     * Error Message : ISD_PhoneValidationError [Rule : 6285]*/
    checkPhoneValidity : function(OriginalPhone) {
        try {
            var pattern = /(^[0-]+$)|(([0]{3})\-?(\d{3})\-?(\d{4}$))|(^((?!\d{3}-\d{3}-\d{4}).)*$)/; 
            if(OriginalPhone) return pattern.test(OriginalPhone);
            else if(OriginalPhone === null || OriginalPhone === '') return false;
                else 
                    return "ERROR";
        }catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    /*[Devashree 14-Aug-2017 ]
     *checkFirstNameValidity method check first name validation [Rule : 10538] 
     *Checks : 1) Required
               2) First character cannot be special character
               3) length less than 40 characters
     *Returns : true if input is invalid 
     *Message : ISD_FirstNameValidationError */
    checkFirstNameValidity : function(originalfName) {
        try{
            if(originalfName && originalfName.trim() && !/[^A-Za-z0-9]/.test(originalfName.charAt(0)) && originalfName.length <= 40 && originalfName.length >= 2 ){
                return false;
            }
            else{
                return true;
            }
        }catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    /*[Devashree 14-Aug-2017 ]
     *checkLastNameValidity method check Last name validation [Rule 10539]
     *Checks : 1) Required
               2) First character cannot be special character
               3) length less than 80 characters
               4) Cannot be less than two characters
     *Returns : true if input is invalid      
     *Message : ISD_LastNameValidationError */   
    checkLastNameValidity : function(originalLName) {
        try{
            if(originalLName && originalLName.trim() && !/[^A-Za-z0-9]/.test(originalLName.charAt(0)) && originalLName.length <= 80 && originalLName.length >= 2){
                return false;
            }
            else{
                return true;
            }
        }catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    
    /*[Devashree 14-Aug-2017 ]
     *formatName method formats the name text
     *Formats :  By capitization of First letter
     *Returns : formatted name text */
    formatName : function(originalInput){
        try{
            if(originalInput && originalInput.trim()){
                originalInput = originalInput.charAt(0).toUpperCase() + originalInput.slice(1, originalInput.length);
            }
            return originalInput;
        }catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },  
    /*[Devashree 21-Sept-2017 ]
     *formatDateOfBirth method formats the DOB from mm/dd/yyyy to yyyy-mm-dd */
    formatDateOfBirth : function(inputDate) {
        try{
            if(inputDate){
                var date = new Date(inputDate);
                var month = date.getMonth()+1 ;
                console.log(date.getFullYear() +'-'+ month +'-'+ date.getDate());
                console.log(date);
                return date.getFullYear() +'-'+ month +'-'+ date.getDate();
                
            }
            return inputDate;
        }catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
   
    /*[WeslyJ 31-Oct-2017] Function to check whether the logged in user has access to the page being accessed using Michigan_ContentLayout and ISD_HA_ContentLayout */
    checkPageAccess : function(component)            {
        try  {
            var sOrigin = document.URL; 
            if(sOrigin.indexOf("sitestudio") > -1 || sOrigin.indexOf("livepreview") > -1)              { //do not check page access inside community builder
               component.set("v.showContent", true);
            }
            else          {
                var oUrlVals = this.getURLQueryStringValues();
                var sPathName = oUrlVals.PathName;
                var sPageName = sPathName.substr(sPathName.indexOf("/s/") + 3);
                var sAllowPageList = "isd-access-error;isd-help;isd-postlogging";
                if(sAllowPageList.indexOf(sPageName) < 0)         {
                             this.callServer(component, "c.getPagesProfilePermissions", function(response)               {
                        var lstMenuItems = response.objectData["MenuItems"];
                        var iMenuLen = lstMenuItems.length;
                        var sProfile = response.objectData["Profile"];
                        var lstPermissions = response.objectData["Permissions"];
                        var bAllowAccess = false;
                        if(iMenuLen > 0)     {
                            for(var i=0; i<iMenuLen; i++)        {
                                var menuItem = lstMenuItems[i];
                                if(menuItem.PageName__c === sPageName)    {
                                    /* if CheckAccess__c is true, only then verify access. Else, allow access. */
                                    if(menuItem.CheckAccess__c)             {
                                        /* check if user's profile has access to the page */
                                        if(menuItem.ProfileAccess__c.indexOf(sProfile) > -1)           {
                                            /* check if the user's permission has access to the page (if applicable) */
                                            if(menuItem.UserPermissions__c !== undefined)               {
                                                var bPresent = false;
                                                var permissionFunc = function(element)            {
                                                    if(menuItem.UserPermissions__c.indexOf(element)> -1)
                                                        bPresent = true;  
                                                };
                                                lstPermissions.forEach(permissionFunc);
                                                if(bPresent){
                                                    bAllowAccess = true;
                                                }
                                            }
                                           else       {
                                                bAllowAccess = true;
                                            }
                                        }
                                    }
                                    else {
                                        bAllowAccess = true;
                                    }
                                }
                                if(bAllowAccess)            break;
                            }
                        }
                        if(!bAllowAccess)    {
                            this.navigateToPage("isd-access-error", true);
                        }
                        else             {
                            component.set("v.showContent", true);
                        }
                    }, {}, true);   
                }
                else      {
                    component.set("v.showContent", true);
                }
            }
        }
        catch(e)       {
            this.consoleLog(e.stack, true);
        }
    },  
    /*[Akshay Mohan 04-Nov-2017 ]
     * trigger lightning input tag's validations
     */
    triggerComponentValidators : function(inputNode) {
        try{
            if(inputNode)
            	inputNode.showHelpMessageIfInvalid();
        }catch(e) { 
            this.consoleLog(e.stack, true); 
        }
    },
    /*[Akshay Mohan 17-Nov-2017 ]
     * check if change event was true
     */
    isChangeTrue : function(event){
        return event.getParam("value") === true;
    },
    /*[Akshay Mohan 29-Nov-2017 ]
     * launch indiv summary popover
     */
    /*[Sayari Mandal 06-Dec-2017 ]
     * changed popover to modal window
     */
     
    /*[Nidhin 06-Dec-2017 ]
     * added contact id param
     */
    launchIndivSummaryPopover :function(component,helper,sTaskId,sContactId){
        helper.consoleLog('sTaskId: ' + sTaskId);
        var modalBody;
        var baseComp = component.getSuper();
        $A.createComponent("c:CC_IndividualSummary", 
            {"sTaskId" : sTaskId,"bShowPrograms" : false,"sContactId" : sContactId},
           function(content, status) {
               if (status === "SUCCESS") {
                   modalBody = content;
                   baseComp.find('overlayLib').showCustomModal({
                       body: modalBody, 
                       referenceSelector: ".indSummary",
                       showCloseButton: true,
                       cssClass: "slds-modal slds-modal_large",
                       closeCallback: function() {
                            helper.consoleLog('closed pop over');
                       }
                   })
               }
           });
    },
    /*[Nidhin 29-Nov-2017 ]
     * show toast
     */
    showToast : function(sTitle, sMessage, sType, mode, duration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : sTitle,
            message : sMessage,
            duration : duration,
            mode: mode,
            type: sType
        });
        toastEvent.fire();
    },
    /*[Akshay Mohan 29-Nov-2017 ]
     * Go to page URL
     */
    redirectToPageURL : function(sRedirectURL){
        //redirects to the page URL based on URL passed
        this.consoleLog("redirectToPageURL: " + sRedirectURL);
        var sURL = decodeURIComponent(sRedirectURL);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": sURL
        });
        urlEvent.fire();
    },

    /*Start [Debalina  08-DEC-2017 ]
     * Regex
     */

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
    /*End [Debalina  08-DEC-2017 ]*/
    
    /*Start[Akash 08-DEC-17]
     * Regex
     */
    
    // Validation for City. Only \s.- allowed
    isValidCity:function (cityString){
        
        if(!$A.util.isEmpty(cityString)) {
            var pattern = /^[a-zA-Z\s.-]*$/;
            return pattern.test(cityString.trim());
            
        }else{
            return false;
        }
    },
    
    //Validation for Postal Code.Only Numerics allowed.
    isValidPostal:function (zipString){
        
        if(!$A.util.isEmpty(zipString)) {
            var pattern = /^[0-9]*$/;
            return pattern.test(zipString.trim());
            
        }else{
            return false;
        }
    },
    
    //Validation for County.Only spaces allowed
    isValidCounty:function (countystring){
        
        if(!$A.util.isEmpty(countystring)) {
            var pattern = /^[a-zA-Z\s]*$/;
            return pattern.test(countystring.trim());
            
        }else{
            return false;   
            
        }
    },
    
    //Validation for address.only \s#.&,/- are allowed.
    isValidAddress:function (addString){
        
        if(!$A.util.isEmpty(addString)) {
            var pattern = /^[a-zA-Z0-9\s#.&,/-]*$/;
            return pattern.test(addString.trim());
            
        }else{
            return false;
        }
    },

    
    /*End [Akash  08-DEC-2017 ]*/
     /*[Akshay Mohan 17-Nov-2017 ]
     * check if change event has changed the value
     */
    isValueChange : function(event){
        return event.getParam("oldValue") !== event.getParam("value");
    },

    /*Start [Debalina  11-DEC-2017 ]*/
    formatToJSDateObject : function(dateString) {
        if(!$A.util.isUndefined(dateString) && !$A.util.isEmpty(dateString)) {
            dateString = dateString.trim();
            if(dateString.indexOf('/') !== -1)
                //  Start [Debalina  09-Jan-2018 ] dateString in MM/DD/YYYY format
                return new Date(dateString.split('/')[2],dateString.split('/')[0]-1,dateString.split('/')[1]);
            else if(dateString.indexOf('-') !== -1)
                return new Date(dateString.split('-')[0],dateString.split('-')[1]-1,dateString.split('-')[2]);
        }else
            return '';
    },
    maskInputSSN : function(sString) {
        if( !$A.util.isEmpty(sString) ) {
            return sString.replace(/^(\d{5})/,'XXXXX');
        }else
            return sString;
    },

    matchPatternSSN : function(sString) {
        if(!$A.util.isEmpty(sString)) {
            var pattern = /^[X]{5}\d{4}$/;
            return pattern.test(sString);
        }else
            return false;

    },

    /*End [Debalina  11-DEC-2017 ]*/

    /*Start [Debalina  14-DEC-2017 ]*/
    isValidDate : function(stringDate){
        //this.consoleLog(stringDate.length);
        var pattern = /^((0?[13578]|10|12)(-|\/)(([1-9])|(0[1-9])|([12])([0-9]?)|(3[01]?))(-|\/)((19)([2-9])(\d{1})|(20)([01])(\d{1})|([8901])(\d{1}))|(0?[2469]|11)(-|\/)(([1-9])|(0[1-9])|([12])([0-9]?)|(3[0]?))(-|\/)((19)([2-9])(\d{1})|(20)([01])(\d{1})|([8901])(\d{1})))$/;
        //this.consoleLog(pattern.test(stringDate));

        if(stringDate.length === 10 && pattern.test(stringDate)){
            return true;
        }else
            return false;
    }
    /*End [Debalina  14-DEC-2017 ]*/
})