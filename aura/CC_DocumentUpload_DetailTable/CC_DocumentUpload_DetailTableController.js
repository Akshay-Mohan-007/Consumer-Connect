({
	doInit : function(component, event, helper) {
        
    },
    openModel:function(component, event, helper){
        helper.openModal(component);
    },
    modalChange:function(component, event, helper){
    	helper.checkModalClose(component,event);
    },
    rowAction:function(component, event, helper){
    	helper.doRowAction(component,event);
    },
    handleNo : function(component, event, helper) {
    	helper.closeConfirm(component);
    },
    handleYes : function(component, event, helper) {
        helper.deleteDoc(component);
    },
    deleteOldDoc : function(component, event, helper) {
        helper.deleteOldDoc(component,event);
    }
    
	

})