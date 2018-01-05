({
    loadPage : function(component) {
        var sParams = this.getURLQueryStringValues();
        component.set('v.bPageLoaded',false);
        component.set('v.sCommentMasterId',component.get('v.sAppId'));
        
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
                label: mapLabels.CC_Documents,
                name: "CC_FileUpload_Component"
            },
            {
                label: mapLabels.CC_Targeting_Criteria,
                name: "CC_TargetingCriteria"
            },
            {
                label: mapLabels.CC_Urgency_of_Need,
                name: "CC_UrgencyComponent"
            },
            {
                label: mapLabels.CC_Manage_Allotment,
                name: "CC_Manage_Allotment"
            }
        ];
        component.set('v.navigationData',lstTabs);
        this.consoleLog('Left Nav set');
    },
    getChildComp : function(component) {
        var sCurrentTab= component.get('v.selectedTab');
        this.consoleLog('Save Tab: ' + sCurrentTab);
        var childComp = component.find(sCurrentTab);
        this.consoleLog('childComp', false, childComp);
        return childComp;
    },
    saveTab : function(component,isSaveExit) {

        //Saving Comments
        var sCurrentTab = component.get('v.selectedTab');
        var commentComp = component.find("CommentComp"); 
        console.debug('Comment save:',commentComp);
        if(!$A.util.isUndefined(commentComp) && commentComp !== null){
            commentComp.save(false);
            
        }

        var childComp = this.getChildComp(component);
        var bIsValid= true;
        //for manage allotment set comment value in Capacity_Review_Action_Comments__c field
        if(sCurrentTab === "CC_Manage_Allotment"){
            this.doManageAllotmentCommentChecks(childComp,commentComp);
        }

        //Debalina 05-Jan-18 Defect fix for Targeting
        if(sCurrentTab === "CC_TargetingCriteria"){
            if(isSaveExit){
                childComp.save(function(result){
                    if(Array.isArray(result) && !$A.util.isEmpty(result)){
                        bIsValid = false;
                    }
                });
            }else{
                childComp.submit(function(result){
                    if(Array.isArray(result) && !$A.util.isEmpty(result)){
                        bIsValid = false;
                    }else if(typeof result === 'string' && result === 'Submitted'){
                        bIsValid = true;
                        this.consoleLog('result-->' +result);
                    }
                }); 
            }
        }else{
            childComp.save(function(result){
            if(Array.isArray(result) && !$A.util.isEmpty(result))
                bIsValid = false;
            });
        }
        this.consoleLog('bIsValid-->' +bIsValid);
        //Debalina 05-Jan-18 Defect fix for Targeting
        return bIsValid;
    },
    changeTab : function(component,sTargetTab) {
        this.consoleLog('Changing tab to: ' + sTargetTab);
        
        if(!$A.util.isEmpty(sTargetTab) &&  
            (sTargetTab !== "CC_TargetingCriteria" 
                && sTargetTab !== "CC_UrgencyComponent" 
             && sTargetTab !== "CC_Manage_Allotment")){
            component.set('v.bCanAddComment',false);
            component.set('v.sModule','Application_Review');
            component.set('v.sCommentMasterId',component.get('v.sAppId'));
            component.set('v.sCommentLookup','Related_Application__c');
        }else{ 
            if(sTargetTab === "CC_TargetingCriteria"){
                component.set('v.sCommentLabel',component.get('v.mapLabels').CC_Label_TargetingCrit_Comment);
            }
            else{
               component.set('v.sCommentLabel',component.get('v.mapLabels').CC_LBL_Comment); 
               var commentComp = component.find("CommentComp"); 
               if(sTargetTab === "CC_Manage_Allotment")
                    commentComp.set('v.bCommentRequired',true);
                else
                    commentComp.set('v.bCommentRequired',false);
            }
            component.set('v.bCanAddComment',true);
            component.set('v.sModule','Capacity_Review');
            component.set('v.sCommentMasterId',component.get('v.sAppDetailId'));
            component.set('v.sCommentLookup','Application_Detail__c');
        }
      component.set('v.selectedTab',sTargetTab);      
    },
    nextTab : function(component,bIsValid) {
        var lstTabs = component.get('v.navigationData');
        var iCurrentIndex = this.getCurrentTab(component,lstTabs);
        this.setTabIcon(component,lstTabs,iCurrentIndex,bIsValid);
        if(!bIsValid)
            return;
        //Debalina 05-Jan-18 Defect fix for Targeting
        /*var sCurrentTab = component.get('v.selectedTab');
        this.consoleLog('sCurrentTab Tab: ' + sCurrentTab);
        if(!bIsValid && sCurrentTab !== 'CC_TargetingCriteria')
            return;
        else if(!bIsValid && sCurrentTab === 'CC_TargetingCriteria'){
            return;
        }
        else if(bIsValid && sCurrentTab === 'CC_TargetingCriteria'){
            this.redirectToHomePage(component);
            return;
        }*/
        //Debalina 05-Jan-18 Defect fix for Targeting
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
        var commentComp = component.find("CommentComp");
        this.doManageAllotmentCommentChecks(childComp,commentComp);
        childComp.submit(function(lstNotVisitedTabs){
            if(!$A.util.isEmpty(lstNotVisitedTabs)){//checks if any page to redirect to before submission
                if(!Array.isArray(lstNotVisitedTabs))
                    return;
                var lstTabs = component.get('v.navigationData');
                lstNotVisitedTabs.forEach(function(sTabName){
                    var iCurrentIndex = lstTabs.findIndex(function(wrapTab){
                        return wrapTab.name === sTabName;
                    });
                    if(iCurrentIndex!== -1)
                        helper.setTabIcon(component,lstTabs,iCurrentIndex,false);
                });
                if(lstTabs.includes(lstNotVisitedTabs[0]))
                    helper.changeTab(component,lstNotVisitedTabs[0]);
            }else{
                this.showToast('Success', 'Successfull', 'success', 'sticky', 5000);
                //Saving Comments
                if(!$A.util.isUndefined(commentComp) && commentComp !== null){
                    commentComp.save(true);
                }
                helper.redirectToHomePage(component);
            }
            
        });

    },
    doManageAllotmentCommentChecks :function(component,commentComp){
        var objAppDetail=component.get('v.AppDetObj');
        var sComment = commentComp.get('v.sCommentBody');
        this.consoleLog('sComment: ' + sComment);
        objAppDetail.Capacity_Review_Action_Comments__c = sComment;
        component.set('v.AppDetObj',objAppDetail);
        //if comment not given set error
        var commentTextArea = commentComp.find('LatestDraftComment');
        $A.util.removeClass(commentTextArea, 'slds-has-error');
        if($A.util.isEmpty(sComment)){
            $A.util.addClass(commentTextArea, 'slds-has-error');
        }
    }
})