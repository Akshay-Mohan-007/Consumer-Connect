({
	proceed: function (component, event, helper) {
        helper.redirectToNextpage(component, event);
    },
    launchPopOver : function (component, event, helper) {
        helper.launchIndivSummaryPopover(component,helper,null,component.get("v.row").sIndividualId);
    }
})