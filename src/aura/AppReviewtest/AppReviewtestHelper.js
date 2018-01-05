({
    loadPage : function(component) {
        var sParams = this.getURLQueryStringValues();
        component.set('v.bPageLoaded',false);
        var lstTabs = [
            {
                label: "Services",
                name: "CC_Services_Component"
            },
           
            {
                label: "Documents"   ,
                name: "CC_FileUpload_Component"
            },
             {
                label: "Living Situation",
                name: "CC_LivingSituation"
            },
            {
                label: "Summary"      ,
                name: "CC_WaiverConfirmation"
            }
        ];
        component.set('v.navigationData',lstTabs);
        var sAppId = component.get('v.sAppId');
        var sConId = component.get('v.sContactId');
        if($A.util.isEmpty(sAppId))
            component.set('v.sAppId', sParams['app']);
        if($A.util.isEmpty(sConId))
            component.set('v.sContactId', sParams['con']);
        this.callServer(component, "c.loadData", function(response){
            var objResult = JSON.parse(response);
            this.consoleLog('Page loaded',false,objResult);
            component.set('v.mapLabels',objResult.mapLabels);
            component.set('v.sCompleteIcon',objResult.mapLabels.CC_Tab_Complete_Icon);
            component.set('v.sIncompleteIcon',objResult.mapLabels.CC_Tab_Incomplete_Icon);
            component.set('v.bPageLoaded',true);
        });
        
    },
    getChildComp : function(component) {
        var sCurrentTab= component.get('v.selectedTab');
        this.consoleLog('Save Tab: ' + sCurrentTab);
        var childComp = component.find(sCurrentTab);
        this.consoleLog('childComp', false, childComp);
        return childComp;
    },
    saveTab : function(component) {

    

        var childComp = this.getChildComp(component);
        var bIsValid= true;
        childComp.save(function(result){
            if(Array.isArray(result) && !$A.util.isEmpty(result))
                bIsValid = false;
        });
        return bIsValid;
    },
    changeTab : function(component,sTargetTab) {
        this.consoleLog('Changing tab to: ' + sTargetTab);
        component.set('v.selectedTab',sTargetTab);
    },
    nextTab : function(component,bIsValid) {
        var lstTabs = component.get('v.navigationData');
        var iCurrentIndex = this.getCurrentTab(component,lstTabs);
        this.setTabIcon(component,lstTabs,iCurrentIndex,bIsValid);
        if(!bIsValid)
            return;
        var sTargetTab = lstTabs[iCurrentIndex+1].name;
        this.consoleLog('Changing to Next Tab: ' + sTargetTab);
        this.changeTab(component,sTargetTab);
    },
    backTab : function(component,bIsValid) {
        var lstTabs = component.get('v.navigationData');
        var iCurrentIndex = this.getCurrentTab(component,lstTabs);
        this.setTabIcon(component,lstTabs,iCurrentIndex,bIsValid);
        if(!bIsValid)
            return;
        var sTargetTab = lstTabs[iCurrentIndex-1].name;
        this.consoleLog('Changing to Back Tab: ' + sTargetTab);
        this.changeTab(component,sTargetTab);
    },
    getCurrentTab : function(component,lstTabs){
        var sCurrentTab = component.get('v.selectedTab');
        return lstTabs.findIndex(function(wrapTab){
            return wrapTab.name === sCurrentTab;
        });
    },
    setTabIcon : function(component,lstTabs,iCurrentIndex,bIsValid){
        if(bIsValid)
            lstTabs[iCurrentIndex].icon = component.get('v.sCompleteIcon');
        else
            lstTabs[iCurrentIndex].icon = component.get('v.sIncompleteIcon');
        component.set('v.navigationData',lstTabs);
    },
    redirectToHomePage : function(component){
        //redirects to the home page based on parent page
        this.consoleLog("redirectToHomePage");
        var mapLabels = component.get('v.mapLabels');
        var sURL = decodeURIComponent(mapLabels.CC_HOME_PAGE_URL);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": sURL
        });
        urlEvent.fire();
    },
    getIncompleteTabName : function(component,helper){
        var sTabName,sIncompleteIcon=component.get('v.sIncompleteIcon');
        component.get('v.navigationData').forEach(function(wrapTab){
            if(!$A.util.isEmpty(sTabName))
                return;
            helper.consoleLog('wrapTab',false,wrapTab);
            if(wrapTab.icon === sIncompleteIcon)
                sTabName = wrapTab.name;
        });
        return sTabName;
    },
    submit : function(component,helper){
        var childComp = this.getChildComp(component);
        childComp.submit(function(lstNotVisitedTabs){
            if(!$A.util.isEmpty(lstNotVisitedTabs)){
                if(!Array.isArray(lstNotVisitedTabs))
                    return;
                var lstTabs = component.get('v.navigationData');
                lstNotVisitedTabs.forEach(function(sTabName){
                    var iCurrentIndex = lstTabs.findIndex(function(wrapTab){
                        return wrapTab.name === sTabName;
                    });
                    helper.setTabIcon(component,lstTabs,iCurrentIndex,false);
                });
                helper.changeTab(component,lstNotVisitedTabs[0]);
            }else
                helper.redirectToHomePage(component);
            
        });

        //Saving Comments
     
    }
})