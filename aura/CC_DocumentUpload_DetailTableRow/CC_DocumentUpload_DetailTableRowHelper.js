({
	doInit : function(component,event) {
        var docDetail = JSON.parse(JSON.stringify(component.get("v.docDetail")));
        if(!$A.util.isEmpty(docDetail.sComments)){
            var comment = docDetail.sComments;
            var shrtComment = comment.substr(0,20);
            component.set('v.comments',shrtComment);
        }

        if(!$A.util.isEmpty(docDetail.sReviewComments)){
            var rComment = docDetail.sReviewComments;
            var shrtRComment = rComment.substr(0,20);
            component.set('v.rcomments',shrtRComment);
        }
        
	},
    openCommentModal:function(component,event){
        
        component.set('v.commentPassed',component.get("v.docDetail").sComments);
        component.set('v.commentType','Comment');
        component.set('v.isOpen',true);
    },
    openRcommentModal:function(component,event){
        
        component.set('v.commentPassed',component.get("v.docDetail").sReviewComments);
        component.set('v.commentType','Review Comment');
        component.set('v.isOpen',true);
    },
    doRowAction:function(component,sAction){
        var actionEvent = component.getEvent("rowAction");
        actionEvent.setParams({ 
            action: sAction,
            wrapDoc: component.get('v.docDetail')
         });
        actionEvent.fire();
    }
    
})