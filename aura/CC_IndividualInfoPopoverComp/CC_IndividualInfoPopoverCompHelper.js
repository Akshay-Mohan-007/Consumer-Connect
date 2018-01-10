({
	loadPagedata : function(component, event) {
        console.debug('loadpagedata:',component.get("v.sAppId"));
		this.callServer(component, "c.getInfoData", function(result) {                

            console.debug('JSON:', JSON.parse(result));
            component.set("v.sResult",result);
            var result = JSON.parse(result);
            
            component.set("v.mapLabels",result.MapLabelError);
            component.set("v.sGenderLBL",component.get("v.mapLabels").CC_LBL_Gender.toUpperCase());
            
            component.set("v.sAppName",result.Application.Name);
            component.set("v.sIndName",result.Application.CC_Individual__r.LastName.toUpperCase()+', '+result.Application.CC_Individual__r.FirstName.toUpperCase());
			component.set("v.sAge",result.Application.CC_Individual__r.Age__c);
            component.set("v.sGenderInfo",result.Application.CC_Individual__r.CC_Gender__c.toUpperCase());
            
            
                          
        },{"sAppId" : component.get("v.sAppId")});
	},
    popoverInit:function(component, event){
        component.set('v.bPopover','true');
    },
    showPopOver : function(component, event) {
        
        var showPopover = component.get("v.bPopover");
        
        if(showPopover){
            
       // alert("showPopover:"+showPopover);
            
    	var modalBody;
        $A.createComponent("c:CC_PopoverContent", {
            "sResult" : component.get("v.sResult"),
            "bPopover": component.get("v.bPopover")
           },
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   component.find('overlayLib').showCustomPopover({
                                       
                                       body: modalBody, 
                                       referenceSelector: ".mypopover",
                                       
                                       cssClass: "slds-popover,slds-popover_panel,no-pointer,popover-width,cCC_PopoverContent"
                                       
                                   }).then(function (overlay) {
                                       
                                       component.set("v.bPopover",false);
                                       //console.log("Popover initiated");
                                       //var pElement = document.getElementsByClassName('slds-popover');
                                       //console.log(pElement);
                                   });
                                   
                               }
                               
                           });  
         
         }
        else{
            //console.log("showPopover:"+showPopover);
            return false;
        }
    }
})