({
    loadPage : function(component) {
        var sParams = this.getURLQueryStringValues();
        component.set('v.bPageLoaded',false);
        
        var sAppId = component.get('v.sAppId');
        var sConId = component.get('v.sContactId');
        var sTaskId = component.get('v.sTaskId');
        var sModule = component.get('v.sModule');
        if($A.util.isEmpty(sAppId))
            component.set('v.sAppId', sParams['sAppId']);
        if($A.util.isEmpty(sConId))
            component.set('v.sContactId', sParams['sContactId']);
        if($A.util.isEmpty(sTaskId))
            component.set('v.sTaskId', sParams['sTaskId']);
        if($A.util.isEmpty(sModule))
            component.set('v.sModule', sParams['sModule']);
        this.callServer(component, "c.loadData", function(response){
            var objResult = JSON.parse(response);
            this.consoleLog('Page loaded',false,objResult);
            component.set('v.mapLabels',objResult.mapLabels);
            this.setLeftNav(component,objResult.mapLabels);
            component.set('v.bShowCommentAndHistory',objResult.bShowCommentAndHistory);
            console.debug('bShowCommentAndHistory:', component.get('v.bShowCommentAndHistory'));
            component.set('v.sCompleteIcon',objResult.mapLabels.CC_Tab_Complete_Icon);
            component.set('v.sIncompleteIcon',objResult.mapLabels.CC_Tab_Incomplete_Icon);
            component.set('v.bPageLoaded',true);
        },{"sAppId"    : component.get("v.sAppId"), "sModuleName" : component.get("v.sModule")});
        
    },
    setLeftNav : function(component,mapLabels) {
        var lstTabs = [
            {
                label: mapLabels.CC_Services,
                name: "CC_Services_Component"
            },
            {
                label: mapLabels.CC_Living_Situation,
                name: "CC_LivingSituation"
            },
            {
                label: mapLabels.CC_Documents ,
                name: "CC_FileUpload_Component"
            },
            {
                label: mapLabels.CC_Waiver_Confirmation ,
                name: "CC_WaiverConfirmation"
            }
        ];
        component.set('v.navigationData',lstTabs);
    },
    getChildComp : function(component) {
        var sCurrentTab= component.get('v.selectedTab');
        this.consoleLog('Save Tab: ' + sCurrentTab);
        var childComp = component.find(sCurrentTab);
        this.consoleLog('childComp', false, childComp);
        return childComp;
    },
    saveTab : function(component) {
        
        //Saving Comments
        var sCurrentTab = component.get('v.selectedTab');
        var commentComp = component.find("CommentComp"); 
        console.debug('Comment save:',commentComp);
        if(!$A.util.isUndefined(commentComp) && commentComp !== null){
            commentComp.save(false);
        }        

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
        this.redirectToPageURL(mapLabels.CC_HOME_PAGE_URL);
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
    }
})