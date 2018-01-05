({
	initPage : function(component) {
		this.consoleLog('Loading the Modal');
        var wrapDoc = component.get('v.wrapDoc');
        this.consoleLog('Loading the Modal',false,wrapDoc);
        /*if($A.util.isEmpty(wrapDoc.sId))
            component.set('v.bNewDocument',true);
        else
            component.set('v.bNewDocument',true);
        this.consoleLog('bNewDocument',false,component.get('v.bNewDocument'));*/
        this.consoleLog('lstDocTypes',false,component.get('v.lstDocTypes'));
        /*var lstButtons = component.get('v.lstButtons');
        var helper = this;
        lstButtons.forEach(function(wrapButton){
            helper.consoleLog('wrapButton',false,wrapButton);
            if(!wrapButton.isValid()){
                wrapButton.set('destroyed',0);
            	wrapButton.set('valid',true);
            }
                
        });
        this.consoleLog('lstButtons',false,component.get('v.lstButtons'));*/
        
        
	},
    fileUploaded : function(component,lstFiles) {
        this.consoleLog('lstFiles',false,lstFiles);
        var wrapDoc = component.get('v.wrapDoc');
        if(!$A.util.isEmpty(wrapDoc.sContentId)){
            this.consoleLog('Deleting old document',false,wrapDoc);
            var deleteEvent = component.getEvent("deleteOld");
            wrapDoc.sContentId = lstFiles[0].documentId;
            deleteEvent.setParams({ 
                wrapDoc: wrapDoc
             });
        	deleteEvent.fire();
        }else
            wrapDoc.sContentId = lstFiles[0].documentId;
        
        component.set('v.wrapDoc',wrapDoc);
    },
    closePage : function(component) {
        this.consoleLog('Closig the Modal');
        var wrapDoc = component.get('v.wrapDoc');
        //Check if Doc detail is created without any document
        if($A.util.isEmpty(wrapDoc.sContentId) && !$A.util.isEmpty(wrapDoc.sId))
            component.set('v.bShowConfirm',true);
        else
        	component.set('v.bShowModal',false);
    },
    handleNo : function(component) {
        component.set('v.bShowConfirm',false);
    },
    handleYes : function(component) {
        component.set('v.bShowConfirm',false);
        component.set('v.bShowModal',false);
    },
    validate : function(component) {
        var wrapDoc = component.get('v.wrapDoc');
        this.consoleLog('wrapDoc',false,wrapDoc);
        var mapLabels = component.get('v.mapLabels');
        component.set('v.bhasError',false);
        component.set('v.bDocTypeError',false);
        var lstErrors = [];
        var bError = false;
        if($A.util.isEmpty(wrapDoc.sDocName)){
            this.consoleLog('Doc Type missing');
            lstErrors.push(mapLabels.CC_Error_DocName_missing);
            component.set('v.bDocTypeError',true);      
            bError = true;
        }
        var bisReadOnly = component.get('v.bDoReview');
        if(bisReadOnly){
        if($A.util.isEmpty(wrapDoc.sStatus)){
            this.consoleLog('Status missing');
            lstErrors.push(mapLabels.CC_Error_Status_missing);
            component.set('v.bDocStatus',true);
            bError = true;
        }
        if($A.util.isEmpty(wrapDoc.sReviewComments) && wrapDoc.sStatus=='Invalid'){
            this.consoleLog('Review Comments missing');
            lstErrors.push(mapLabels.CC_Error_ReviewComments_missing);
            component.set('v.bDocRevComments',true);
            bError = true;
        }
        }
        if(bError){
            component.set('v.bhasError',true);
            component.set('v.lstErrors',lstErrors);
        }
        else{
            component.set('v.bDoingSave',true);
            component.set('v.lstErrors',lstErrors);
        }
    }
})