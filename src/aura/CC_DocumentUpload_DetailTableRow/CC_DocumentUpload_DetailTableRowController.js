({
	doInit : function(component, event, helper) {
        
        helper.doInit(component, event);
    },
    openCommentModal:function(component,event,helper){
        
        helper.openCommentModal(component,event);
    },
    openRcommentModal:function(component,event,helper){
        
        helper.openRcommentModal(component,event);
    },
    editRecord:function(component,event,helper){
        helper.doRowAction(component,'Edit');
    },
    deleteRecord:function(component,event,helper){
        helper.doRowAction(component,'Delete');
    },
    openFile:function(component,event,helper){
        $A.get('e.lightning:openFiles').fire({
            recordIds : [component.get('v.docDetail').sDocId]
        });
    }
})