({
	doInit : function(component, event, helper) {
	    console.debug('Parent doInit');
	    helper.loadPage(component, event);
	},
	save : function(component, event, helper) {
		helper.saveRecord(component, event);
	    
	},

	handleUploadFinished: function (component, event,helper) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        console.debug("Files uploaded : ", uploadedFiles);
    }

})