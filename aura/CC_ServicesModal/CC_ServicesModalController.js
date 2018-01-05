({
  loadOptions: function (component, event, helper) {
      console.log('Inside Services Modal');
  },
  saveData : function(component,event, helper){
      helper.validate(component,event);         
  },

  clearOtherProg : function(component,event, helper){
     if(!$A.util.isEmpty(component.get("v.selectedProgram")) 
        && component.get("v.selectedProgram") !== component.get('v.mapLabels').CC_LBL_OTHER )
        component.set("v.sOtherProgName",'');         
  },
  clearOtherService : function(component,event, helper){
     if(!$A.util.isEmpty(component.get("v.selectedService")) 
          && component.get("v.selectedService") !== component.get('v.mapLabels').CC_LBL_OTHER)
        component.set("v.sOtherServiceName",'');         
  },

  setValues : function (component, event, helper) {
      helper.setFieldValues(component, event);
  },

  closeModel: function(component, event, helper){
        component.set("v.showModal", false); 
  }
})