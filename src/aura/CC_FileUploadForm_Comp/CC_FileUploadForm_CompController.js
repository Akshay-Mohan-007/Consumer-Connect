({
	doInit: function (component, event,helper) {
		console.debug('In init');
	},
	handleUploadFinished: function (component, event,helper) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        console.debug("Files uploaded : ", uploadedFiles);
    }
})