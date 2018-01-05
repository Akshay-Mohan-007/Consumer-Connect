({
	proceed: function (component, event, helper) {
        helper.redirectToNextpage(component, event);
    },
    launchPopOver : function (component, event, helper) {
        helper.launchIndivSummaryPopover(component,helper,component.get("v.row").sRecordId, null);
    },
    showModal : function(component, event, helper) {
		helper.showModal(component, event);
	}
})