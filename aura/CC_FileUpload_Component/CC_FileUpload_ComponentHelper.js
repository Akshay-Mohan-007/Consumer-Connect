({
    loadPage : function(component) {
        
        this.consoleLog('Loading page');
        component.set('v.bPageLoaded',false);
        this.callServer(component, "c.loadData", function(response){
            var retObj = JSON.parse(response);
            this.consoleLog('Page loaded',false,retObj);
            component.set('v.mapLabels',retObj.mapLabels);
            component.set('v.lstDocs',retObj.lstDocs);
            component.set('v.lstDocTypes',retObj.lstDocTypes);
            component.set('v.lstReqDocs',retObj.lstReqDocs);
            component.set('v.wrapDummyDoc', retObj.wrapDummyDoc);
            component.set('v.bPageLoaded',true);
            component.set('v.lstStatus',retObj.lstStatus);
            
        },{
            sRecordId : component.get('v.masterRecordId'),
            sLookupField : component.get('v.lookupField'),
            sValidator : component.get('v.validator'),
            sModule : component.get('v.module')
        });    
    },
    saveDocument : function(component,event) {
        if(!this.isChangeTrue(event))
            return;
        var childComp = component.find('docGrid').find('documentModal');
        var wrapDoc = childComp.get('v.wrapDoc');
        var sRecord = component.get('v.masterRecordId');
        var sLookup = component.get('v.lookupField');
        var wrapParams = {
            sRecordId: sRecord,
            sLookupField: sLookup,
            sJSON: JSON.stringify(wrapDoc),
        };
        this.consoleLog('wrapParams',false,wrapParams);
        
        this.callServer(component, "c.saveDocumentDetail", function(response){
            this.consoleLog('Save done',false,response);
            this.consoleLog('wrapDoc',false,wrapDoc);
            this.consoleLog('childComp',false,childComp);
            wrapDoc.sId = response;
            childComp.set('v.wrapDoc',wrapDoc);
            component.set('v.bDoingSave',false);
        },wrapParams);
    },
    refreshDocList : function(component,event) {
        if(!this.isChangeTrue(event))
            return;
        
        component.set('v.bPageLoaded',false);
        this.callServer(component, "c.refreshDocumentGrid", function(response){
            var retObj = JSON.parse(response);
            this.consoleLog('Page loaded',false,retObj);
            component.set('v.lstDocs',retObj.lstDocs);
            component.set('v.wrapDummyDoc', retObj.wrapDummyDoc);
            component.set('v.lstReqDocs',retObj.lstReqDocs);
            component.set('v.bPageLoaded',true);
            component.set('v.bDoingRefresh',false);
            
        },{
            sRecordId : component.get('v.masterRecordId'),
            sLookupField : component.get('v.lookupField'),
            sValidator : component.get('v.validator')
        });    
    },
    validate : function(component,callback) {
        component.set('v.lstErrors',[]);
        var lstErrors=[];
        var mapLabels = component.get('v.mapLabels');
        var callbackDettable=false;
        var lstRemaining = component.get('v.lstReqDocs').filter(function(wrapReqDoc){
            return !wrapReqDoc.bUploaded && wrapReqDoc.bMandatory;
        });
        this.consoleLog('list of docs to be uploaded',false,lstRemaining);
        lstRemaining.forEach(function(wrapFound){
            lstErrors.push(mapLabels.CC_Error_Document_Missing + ' ' + wrapFound.sRequired.trim());
        });
        
       
        var bisreadOnly= component.get('v.bDoReview');
        if(bisreadOnly){
            var lstStattuschk = component.get('v.lstDocs').filter(function(wrapDoc){
               return $A.util.isEmpty(wrapDoc.sStatus);
         });
            this.consoleLog('Status missing',false,lstStattuschk);
            lstStattuschk.forEach(function(wrapDocFound){
            lstErrors.push(mapLabels.CC_Error_Status_missing + ' ' +wrapDocFound.sDocName.trim());
          });  
        }
        
        component.set('v.lstErrors',lstErrors);
        if(callback)
            callback.call(this,lstErrors);
        
        if($A.util.isEmpty(lstErrors))
            this.callServer(component, "c.setPageVisited", function(response){
                this.consoleLog('Page Visited set');
            },{
                sRecordId : component.get('v.masterRecordId'),
                sValidator : component.get('v.validator')
            });
    }
})