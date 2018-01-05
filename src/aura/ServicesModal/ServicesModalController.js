({
	loadOptions: function (component, event, helper) {
        var opts = [
            { value: "Service Name 1", label: "Service Name 1" },
            { value: "Service Name 2", label: "Service Name 2" },
            { value: "Service Name 3", label: "Service Name 3" },
            { value: "Service Name 4", label: "Service Name 4" },
            { value: "Service Name 5", label: "Service Name 5" },
            { value: "Other", label: "Other" },
         ];
         component.set("v.options", opts);
    },
  
   showProgram:function (component, event, helper) {
            
            var check = component.find('current').get('v.checked');
            //console.log(check);
            if(check == true)
            {
               component.set('v.showProgram',true);
            }
            else{
                component.set('v.showProgram',false);
            }
      },
   saveData : function(component,event, helper){
        //this function is used get the data from the form and pass it to CC_AddService via an event
        
        var serviceName,otherServiceName,current,programName,otherProgramName,future;
        serviceName = component.find("serviceName").get("v.value");
        if( serviceName == 'Other'){
             otherServiceName = component.find("otherService").get("v.value");
            }
        else{
            otherServiceName = "";
            }
        current = component.find("current").get("v.checked");
         if(current == true){
                programName = component.find("programName").get("v.value");
                if(programName == 'Other'){
                    otherProgramName = component.find("otherProgram").get("v.value");
                  }
                else{
                    otherProgramName = "";
                 }
            }
            else{
              programName="";
              otherProgramName="";
            }
        var future = component.find("future").get("v.checked");
            
        var serviceObj = {id:111, 
                          serviceName:serviceName,
                          otherServiceName:otherServiceName,
                          current:current, 
                          programName:programName,
                          otherProgramName:otherProgramName,
                          future:future}
        console.log("added obj",serviceObj);
            
            
            
        var addRowEvent = component.getEvent("addEvent");
        addRowEvent.setParams({"param": serviceObj });
        addRowEvent.fire();        
     },
   passService : function (component, event, helper) {
        
        //this function is used to pass data from the CC_AddService and set it to the form inside modal window
        console.log("In services Modal");
        var params = event.getParam('arguments');
        var data = JSON.parse(JSON.stringify(params));
        console.log('Params:',data);
        
        
        /*component.find("serviceName").set("v.value", data.selectedService.serviceName);
            if( data.selectedService.serviceName == 'Other'){
              component.find("otherService").set("v.value", data.selectedService.otherServiceName);
            }
        component.find("current").set("v.checked", data.selectedService.current);
            if( data.selectedService.current == true){
                component.set('v.showProgram',true);
                component.find("programName").set("v.value", data.selectedService.programName);  
                if(data.selectedService.programName == 'Other'){
                    component.find("otherProgram").set("v.value", data.selectedService.otherProgramName);
                  }
            }
        component.find("future").set("v.checked", data.selectedService.future);*/
    },
    closeModel: function(component, event, helper){
           component.set("v.showModal", false); 
    }
  })