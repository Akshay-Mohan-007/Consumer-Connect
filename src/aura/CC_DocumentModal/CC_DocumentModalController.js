({
    doInit : function(component, event, helper) {
        helper.initPage(component);
    },
	closeModel : function(component, event, helper) {
        helper.closePage(component);
	},
    handleUploadFinished : function(component, event, helper) {
        helper.fileUploaded(component,event.getParam("files"));
    },
    handleNo : function(component, event, helper) {
        helper.handleNo(component);
    },
    handleYes : function(component, event, helper) {
        helper.handleYes(component);
    },
    save : function(component, event, helper) {
        helper.validate(component);
    },
})