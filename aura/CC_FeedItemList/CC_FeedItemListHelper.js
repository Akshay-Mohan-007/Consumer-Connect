({
	loadData : function(component) { 
		                
        this.callServer(component, "c.loadData", function(response) {
        	console.log("response>>" + response);
            var result = JSON.parse(response);
            console.log(result);
            var dtCreatedDateTime = result.SelectedFeed.sCreatedDate;    
            result.SelectedFeed.sCreatedDate = this.getDateTimeInFormat(dtCreatedDateTime,result.MapLabel);

            component.set("v.FeedInfo", result.SelectedFeed);
            console.debug('Date :'+result.SelectedFeed);
            component.set("v.lstHisFeeds",result.HistoricFeeds); 

            component.set("v.iSelectedPage",1);
            component.set("v.iOffsetClient",0);
            component.set("v.iOffset",0);
            component.set("v.iListSize", result.iListSize);
            component.set("v.iPageSize", result.iPageSize);
            component.set("v.iPagesPerChunk", result.iPagesPerChunk);
            component.set("v.iChunkSize", result.iPageSize * result.iPagesPerChunk);
            component.set("v.bDisableFirst", false);
            component.set("v.bDisablePrevSet", false);
            component.set("v.bDisableLast", false);
            component.set("v.bDisableNextSet", false);
            component.set("v.mapLabels",result.MapLabel);

            this.updateTable(component);

            component.set("v.bLoaded", true);

        }, {
            "feedItemId" : component.get("v.feedItemId")
	       });
    },

    first : function(component, event, helper) {
    //loads the first page
    //server side pagination
    this.getDataList(component, false);
  },
  gotoSelectedPage : function(component, iSelectedPage){
    //navigate to the selected page
    //it is just client side pagination
    component.set("v.iSelectedPage", iSelectedPage);
    component.set("v.iOffsetClient", ((iSelectedPage - 1) % component.get("v.iPagesPerChunk")) * component.get("v.iPageSize"));
    this.updateTable(component);
  },
  setVariablesAndCall : function(component, iOffset){
    //set the variables and call data list
    component.set("v.iOffset", iOffset);
    component.set("v.iOffsetClient", 0);
    component.set("v.iSelectedPage", (iOffset / component.get("v.iPageSize")) + 1);
    this.getDataList(component, false);
  },
  getDataList : function(component, gotoLastPage) {
    //pass the variables and call task list
    this.getCommentList(component,component.get("v.iOffset"),gotoLastPage);

  },
  getCommentList : function(component, iOffset, gotoLastPage) {
    //returns the filtered data                      
        this.callServer(component, "c.getFeedAsString", function(response) {
         
            var result = JSON.parse(response);
            console.debug('result:' +result);
            /*var lstHistoric = result.lstSubmitted;
           
            if(!$A.util.isEmpty(lstHistoric)){
              for(var i = 0; i<lstHistoric.length ;i++){
                var sDateInNewFormat = this.getDateTimeInFormat(lstHistoric[i].sCreatedDate, component.get('v.mapLabels'));
                lstHistoric[i].sCreatedDate = sDateInNewFormat;
              }
            }*/
            
            component.set("v.iListSize", result.iListSize);
            component.set("v.lstHisFeeds", result.lstSubmitted);
            component.set("v.iOffset", result.iOffset);
            if(gotoLastPage){
              var iPageSize = component.get("v.iPageSize");
              var iTotalSize = (result.iOffset + result.iListSize);
              var iQuotient = iTotalSize % iPageSize;
              var iSelectedPage = (iQuotient > 0) ? ((iTotalSize - iQuotient) / iPageSize) + 1 : iTotalSize / iPageSize;
              component.set("v.iSelectedPage", iSelectedPage);
              var iOffsetClient = result.iListSize - (iQuotient > 0 ? iQuotient : iPageSize);
              component.set("v.iOffsetClient", iOffsetClient);
          }
            this.updateTable(component);
        },{"feedItemId" : component.get("v.feedItemId"),
           "iOffset"         : iOffset,
           "gotoLastPage"   : gotoLastPage });
  },

  updateTable : function(component) {
    //updates the table list with pagination
    var lstPagination = [], iOffset = 0, iOffsetClient = 0;
        var bIsNext = false, bIsPrev = false;
    var iPageSize = component.get("v.iPageSize");
    var iSelectedPage = component.get("v.iSelectedPage");
    var iOffsetClient = component.get("v.iOffsetClient");
    var iOffset = component.get("v.iOffset");
    var lstHisFeeds = component.get("v.lstHisFeeds");
    var iListSize = component.get("v.iListSize");
    var iPagesPerChunk = component.get("v.iPagesPerChunk");
    var iChunkSize = iPageSize * iPagesPerChunk;


    console.debug("updateTable");
    console.debug("lstHisFeeds",lstHisFeeds);

    if((iOffsetClient + iPageSize) < iListSize){
      lstPagination = lstHisFeeds.slice(iOffsetClient, iOffsetClient + iPageSize);
      console.debug("(iOffsetClient + iPageSize) < iListSize");
    } else if(iOffsetClient < iListSize){
      lstPagination = lstHisFeeds.slice(iOffsetClient, iListSize);
      console.debug("iOffsetClient < iListSize");
    }

     if(!$A.util.isEmpty(lstPagination)){
        for(var i = 0; i<lstPagination.length ;i++){
          var sDateInNewFormat = this.getDateTimeInFormat(lstPagination[i].sCreatedDate, component.get('v.mapLabels'));
          lstPagination[i].sCreatedDate = sDateInNewFormat;
        }
      }

    component.set("v.lstPagination", lstPagination);
    console.debug('lstPagination',lstPagination);
    this.updateButtons(component);
  },

  updateButtons : function(component) {
    //updates the pagination buttons
    var iChunkSize = component.get("v.iChunkSize");
    var iOffset = component.get("v.iOffset");
    var iListSize = component.get("v.iListSize");
   
      if(iOffset > 0){
        component.set("v.bDisableFirst", false);
        component.set("v.bDisablePrevSet", false);
     
      }else{
        component.set("v.bDisableFirst", true);
        component.set("v.bDisablePrevSet", true);
      }

      if(iListSize > iChunkSize){
        component.set("v.bDisableLast", false);
        component.set("v.bDisableNextSet", false);
    
      }else{
        component.set("v.bDisableLast", true);
        component.set("v.bDisableNextSet", true);
      }
      this.updateSerialButtons(component, iListSize);
        
   
  },

  updateSerialButtons : function(component, iListSize){
    //updates the pagination serial buttons
    var iSelectedPage = component.get("v.iSelectedPage");
    var iPageSize = component.get("v.iPageSize");
    var iPagesPerChunk = component.get("v.iPagesPerChunk");
    iListSize = (iListSize > (iPageSize * iPagesPerChunk)) ? iListSize - 1 : iListSize;
    var iQuotient = iListSize % iPageSize;
        var iPageLimit = (iQuotient > 0) ? ((iListSize - iQuotient) / iPageSize) + 1 : iListSize / iPageSize;
    var firstPage = iSelectedPage - ((iSelectedPage % iPagesPerChunk) == 0 ? (iPagesPerChunk - 1) : (iSelectedPage % iPagesPerChunk) - 1);
    var lstPageNumbers = [];
    for(var iPageNumber = 0; iPageNumber < iPageLimit; iPageNumber++){
      lstPageNumbers[iPageNumber] = iPageNumber + firstPage;
    }

    component.set("v.lstPageNumbers", lstPageNumbers);
    
  },
  getDateTimeInFormat : function(dtDateTime,mapLabels){
            var sFinalDateVal='';
            var lstDateSplit = dtDateTime.split(" ");
            if(!$A.util.isEmpty(lstDateSplit) && lstDateSplit.length === 3)
            {
              sFinalDateVal = mapLabels.CC_Label_on+' '+lstDateSplit[0]+' '+
                              mapLabels.CC_Label_at+' '+lstDateSplit[1]+' '+lstDateSplit[2]
            }
            else{
              sFinalDateVal = dtDateTime;
            }
        return sFinalDateVal;
  },
})