({
	checkModalClose : function(component,event) {
        if(event.getParam("value") === false)
        	component.set('v.bDoingRefresh',true);
	},
	doRowAction : function(component,event) {
		var wrapDoc = event.getParam("wrapDoc");

        if(event.getParam("action") === 'Edit'){//Edit action
        	this.consoleLog('Edit Doc',false,wrapDoc);
        	component.set('v.wrapDummyDoc',wrapDoc);
        	this.openModal(component);
        }else if(event.getParam("action") === 'Delete'){//delete action
        	this.consoleLog('Delete Doc',false,wrapDoc);
        	component.set('v.sDocDetailId',wrapDoc.sId);
        	component.set('v.bShowConfirm',true);
        }
	},
	deleteDoc : function(component){
		var sDocId = component.get('v.sDocDetailId');
		this.consoleLog('Deleting Doc: '+ sDocId);
		this.callServer(component, "c.deleteDocumentDetail", function(response){
				this.consoleLog('Delete successfull');
				component.set('v.bDoingRefresh',true);
			},{
	            sJSON : JSON.stringify([sDocId])
	        });    
		this.closeConfirm(component);
	},
	deleteOldDoc : function(component,event){
		var wrapDoc = event.getParam("wrapDoc");
		this.consoleLog('Deleting Doc ',false,wrapDoc);
		this.callServer(component, "c.deleteOldDocuments", function(response){
				this.consoleLog('Delete successfull');
				
			},{
	            sDocDetailID : wrapDoc.sId,
	            sLatestId : wrapDoc.sContentId,
	        });    
		this.closeConfirm(component);
	},
	closeConfirm : function(component){
		component.set('v.sDocDetailId',null);
        component.set('v.bShowConfirm',false);
	},
	openModal : function(component){
		component.set('v.isModalOpen',true);
	}
   
})