({
	doInit : function(component, event, helper) {
	    console.log("This is test comp");
        
       
        
        /*component.set('v.thead',[{sColumnName: 'Name',
                                    sClass :'slds-text-color_error',
                                    sValue :'sName',
                                    sValueCSS: 'slds-text-color_error',
                                    sType:'text',
                                    sIcon:''
                                    },
                                    {
                                    sColumnName: 'Address',
                                    sClass :'some-css',
                                    sValue :'sAddress',
                                    sValueCSS: 'row-css',
                                    sType:'text',
                                    sIcon:''
                                    },
                                    {
                                    sColumnName: 'Phone',
                                    sClass :'some-css',
                                    sValue :'sPhone',
                                    sValueCSS: 'row-css',
                                    sType:'link',
                                    sIcon:'',
                                    sEventType:'hyperlink'
                                    },
                                    {
                                    sColumnName: 'Gender',
                                    sClass :'some-css',
                                    sValue :'sGender',
                                    sValueCSS: 'row-css',
                                    sType:'text',
                                    sIcon:''
                                    },
                                    {
                                    sColumnName: 'View',
                                    sClass :'',
                                    sValue :'sView',
                                    sValueCSS: '',
                                    sType:'icon',
                                    sIcon:'utility:preview',
                                    sEventType:'iconLink'
                                    },
                                    
                                    ]);
                                    
                                 component.set("v.tList",[{sName: 'Test Guy',sAddress: 'Some address',sPhone: '123',sGender:'Female',sView:'View'},
                                 {sName: 'Test Guy 2',sAddress: 'Some address',sPhone: '13',sGender:'Female',sView:'View'},
                                 {sName: 'Test Guy 3',sAddress: 'Some address',sPhone: '1',sGender:'Female',sView:'View'}]);*/

        
        //component.set('dialogTitle','Confirmation');
       // component.set("v.demoList",[{name:'Alan', date:'03/04/2017',content:'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'},
                                  //  {name:'Bond',date:'03/04/2017',content:'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'},
                                  // {name:'Chad',date:'03/04/2017',content:'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'},
                                  // {name:'Dickens',date:'03/04/2017',content:'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'}]);
        
      
        
        
         var demoArray = component.get("v.demoList");
         var result = demoArray.map(function(o) {
         o.shrtText = o.content.substring(0,100);
         return o;
        })
         
         //console.log("New Array",result);
       // component.set("v.demoList",result);
        
	},	
    
    showMore: function(component,evt, helper){
         
        
        var index = evt.target.dataset.index;
        console.log("index:",index);
        var selectedObj = component.get("v.demoList")[index];
        var id1 = index+'_less';
        var elem = document.getElementById(id1);
        elem.classList.remove("show");
        elem.classList.add("hide");
        
        var id2 = index+'_more';
        var elem = document.getElementById(id2);
        elem.classList.remove("hide");
        elem.classList.add("show");
        
    },
    showLess: function(component,evt, helper){
         
        
        var index = evt.target.dataset.index;
        console.log("index:",index);
        var selectedObj = component.get("v.demoList")[index];
        
        var id1 = index+'_less';
        var elem = document.getElementById(id1);
        elem.classList.remove("hide");
        elem.classList.add("show");
        
        var id2 = index+'_more';
        var elem = document.getElementById(id2);
        elem.classList.remove("show");
        elem.classList.add("hide");
       
        
    },
    
    
    handleShowModal: function(component, evt, helper) {
        var modalBody;
        var showForModal = component.set('v.hideSection',false);
        
        var modalBody;
        $A.createComponent("c:CC_IndividualSummary", {
            "hideSection" : component.get("v.hideSection")
           },
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   component.find('overlayLib').showCustomModal({
                                       
                                       body: modalBody, 
                                       header: "Individual Summary",
                                       referenceSelector: ".indSummary",
                                       showCloseButton: true,
                                       cssClass: "slds-modal,slds-modal_large",
                                       closeCallback: function() {
                                          // alert('You closed the alert!');
                                       }
                                       
                                   }).then(function (overlay) {
                                      // console.log("Popover initiated");
                                       
                                   });
                                   
                               }
                               
                           }); 

       /* $A.createComponent("c:CC_IndividualSummary", {"showForModal" : component.get("v.showForModal")},
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   modalBody = content;
                                   component.find('overlayLib').showCustomPopover({
                                       body: modalBody, 
                                       referenceSelector: ".mypopover",
                                       closeCallback: function() {
                                           alert('You closed the alert!');
                                       }
                                   })
                               }
                           });*/
    },
    
    
    openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },
 
   closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "false"  
      component.set("v.isOpen", false);
   },
    
    
    handleShowNotice : function(component, event, helper) {
        component.find('notifLib').showNotice({
            "variant": "error",
            "header": "Something has gone wrong!",
            "message": "Unfortunately, there was a problem updating the record.",
            closeCallback: function() {
                alert('You closed the alert!');
            }
        });
    },
    handleMouseEnter : function(component, event, helper) {
        var popover = component.find("popover");
        $A.util.removeClass(popover,'slds-hide');
    },
    showConfirmation1:function(component, event, helper) {
        component.set('v.showDialog',true);
    },
    
    handleYes:function(component, event, helper){
        console.log("Yes");
    },
    handleNo:function(component, event, helper){
        console.log("No");
    }
   
   
})