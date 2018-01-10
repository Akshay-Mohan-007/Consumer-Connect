({
	doInit : function(component, event) {
        
        var columnHeader = component.get("v.column-header"); //array
        var rowData = component.get("v.row-data"); //object
        
       // console.log("col headers are:",columnHeader[0]);
        
         var newArray=[];
         columnHeader.forEach(function(element) {
           var obj = {
                name:element.sColumnName,
                classHeader:element.sClass,
                classCell:element.sValueCSS,
                type:element.sType,
                icon:element.sIcon,
                value:rowData[element.sValue]+''
            }
            
            newArray.push(obj);
        });
      
        console.log("new array",newArray);
        component.set('v.colDataArray',newArray);
		
	
		
	},
    fireRowEvent : function(component, iColumn) {
        
        var lstColumnData = component.get('v.column-header');
        var wrapData = component.get("v.row-data");
        this.consoleLog('lstColumnData',false,lstColumnData);
        this.consoleLog('Event type to be passed in event',false,lstColumnData[iColumn].sEventType);
        this.consoleLog('Data to be sent to event',false, wrapData);
        var actionEvent = component.getEvent("rowAction");
        actionEvent.setParams({ 
            action: lstColumnData[iColumn].sEventType,
            wrapData: wrapData
         });
        actionEvent.fire();
    }
})