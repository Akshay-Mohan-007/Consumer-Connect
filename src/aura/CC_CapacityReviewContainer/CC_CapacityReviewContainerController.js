({
    doInit : function(component, event, helper) {
        helper.loadPage(component);
        
    },
    saveAndChangeTab : function(component, event, helper) {
        var lstTabs = component.get('v.navigationData');
        var bIsValid = helper.saveTab(component,false);
        helper.setTabIcon(component,lstTabs,helper.getCurrentTab(component,lstTabs),bIsValid);
        if(bIsValid)
            helper.changeTab(component,event.getParam("data"));
    },
    back : function(component, event, helper) {
        helper.backTab(component,helper.saveTab(component,false));
    },
    save : function(component, event, helper) {
        helper.saveTab(component,true);
        helper.redirectToHomePage(component);
    },
    next : function(component, event, helper) {
        helper.nextTab(component,helper.saveTab(component,false));
    },
    submit : function(component, event, helper) {
        var sIncompleteTab = helper.getIncompleteTabName(component,helper);
        if($A.util.isEmpty(sIncompleteTab)){
            helper.submit(component,helper);
        }else
            helper.changeTab(component,sIncompleteTab);
    },
    navigateTo : function(component, event, helper) {
        helper.changeTab(component,event.getParam("data"));
    }
})