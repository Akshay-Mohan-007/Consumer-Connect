({
	doInit : function(component, event, helper) {
		console.log("Called........");
		
	},
	clickCreate : function(component, event, helper){
		console.log("save Operation.....");
		helper.method1(component, event, helper);
	}
})