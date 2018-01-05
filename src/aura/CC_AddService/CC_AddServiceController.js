({
    doInit:function(component, event, helper){
        
        
        component.set('v.serviceList',[
            {id:1, serviceName:'Service Name 1',otherServiceName:'',current:true, programName:'Service Name 1',otherProgramName:'',future:false},
            {id:2, serviceName:'Service Name 2',otherServiceName:'',current:true, programName:'Service Name 2',otherProgramName:'',future:true},
            {id:3, serviceName:'Service Name 3',otherServiceName:'',current:false,programName:'',otherProgramName:'',future:false},
            {id:4, serviceName:'Service Name 4',otherServiceName:'',current:true, programName:'Service Name 4',otherProgramName:'',future:false},
            {id:5, serviceName:'Service Name 5',otherServiceName:'',current:false, programName:'',otherProgramName:'',future:true},
            {id:6, serviceName:'Other',otherServiceName:'Test Service 1',current:false, programName:'',otherProgramName:'',future:true},
            {id:7, serviceName:'Other',otherServiceName:'Test Service 2',current:true, programName:'Other',otherProgramName:'Test Program',future:true}
            
        ]);
            
            console.clear();
    },
    openModel : function(component, event, helper) {
            
            component.set('v.isOpen','true');
           
	},
    saveRow: function(component, event, helper){
        
        //This function receives the data for add/edit from ServiceModal on click of 'Save' button
        var serviceList = [];
        console.log("adding...");
        var value = event.getParam("param");
        console.log("Received component event with param = ", value);
        
        var editRowEvent = component.getEvent("addEvent");
        editRowEvent.setParams({"param": component.get('v.serviceDetail') });
        editRowEvent.fire();
        //we have to check whether obj is present in array or not.If present we have to edit, if not we have to add
        /*var serviceList = component.get('v.serviceList');
        serviceList.push(value);
        component.set('v.serviceList',serviceList);*/
        
        //closing modal window
        component.set('v.isOpen','false');
        
    },         
   editRow:function(component, event, helper){
       
        //This function receives the data for edit from CC_ServiceTableRow on click of edit button and passes it on to ServiceModal
        console.log("edit");
        var value = event.getParam("param");
        console.log("Received component event with param = ", value);

        var editRowEvent = component.getEvent("editEvent");
        editRowEvent.setParams({"param": component.get('v.serviceDetail') });
        editRowEvent.fire();
        
        //var a = component.get('c.openModel');
        //$A.enqueueAction(a); 
        //opening modal window
        component.set('v.isOpen','true');
   
        /*passing data to modal window*/
        var modalComponent = component.find('serviceModal');
        console.log("modal is"+ modalComponent);
        //modalComponent.passService(value);
            
            
   },
   deleteRow:function(component, event, helper){
       
        //This function receives the data for delete on click of delete button from CC_ServiceTableRow
            
        console.log("delete");
        var value = event.getParam("param");
        console.log("Received component event with param = ", value);

        var editRowEvent = component.getEvent("deleteEvent");
        editRowEvent.setParams({"param": component.get('v.serviceDetail') });
        editRowEvent.fire();
           
   }
   
    
})