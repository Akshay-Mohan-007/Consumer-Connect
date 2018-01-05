({
	
  loadData : function(component, event) {


      console.debug('Before Comment Load:');
      console.debug('Comment masterId:',component.get("v.sMasterRecordId"));
      console.debug('Comment selectedTab:',component.get("v.selectedTab"));
      console.debug('bCanEnterComment:', component.get("v.bCanEnterComment"));
      console.debug('bCanViewCommentHistory:', component.get("v.bCanViewCommentHistory"));
      console.debug('sModuleName:', component.get("v.sModuleName"));
      
      /*added by Sayari [07-Dec-2017]*/
      var section = component.find("commentAccordian");
      $A.util.removeClass(section, "slds-is-open");
      component.set('v.bIcon',true);
      /*added by Sayari [07-Dec-2017]*/

      this.callServer(component, "c.loadCommentsInfo", function(result) {   

            console.debug('Comment masterId:',component.get("v.sMasterRecordId"));
            console.debug('Comment selectedTab:',component.get("v.selectedTab"));
            console.debug('bCanEnterComment:', component.get("v.bCanEnterComment"));
            console.debug('bCanViewCommentHistory:', component.get("v.bCanViewCommentHistory"));
            console.debug('sModuleName:', component.get("v.sModuleName"));

            console.debug('JSON:', JSON.parse(result));
            var result = JSON.parse(result);
            //console.debug('maplabels:',component.set("v.mapLabels",result.MapLabelError));
            component.set("v.mapLabels",result.MapLabelError);

            if(result.lstDraft.length === 1)
              component.set("v.sCommentBody",result.lstDraft[0].sComments);
            else
              component.set("v.sCommentBody",'');

            component.set("v.lstHisComments",result.lstSubmitted);

            var sCurrentTab = component.get("v.selectedTab");
            var bIsVisibleForTab = result.lstCommentTabs.some(function(allowedTab){
              return allowedTab === sCurrentTab;
            });

            console.debug('bIsVisibleForTab:',bIsVisibleForTab);
            component.set("v.bIsVisibleForTab",bIsVisibleForTab);

            var bShowComment =  component.get("v.bShowForPage") || (bIsVisibleForTab && (component.get("v.bCanEnterComment") || component.get("v.bCanViewCommentHistory")) );  
            component.set("v.bShowComment", bShowComment);

            /*Pagination Specific data*/
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

            if(bShowComment)
              this.updateTable(component);

            /*Pagination Specific data*/

            component.set("v.bshowHistoryTable", false);
            component.set("v.bLoaded", true);

        },{"sMasterRecordId" : component.get("v.sMasterRecordId"),
           "sCompName"       : component.get("v.selectedTab"),
           "sLookupField"    : component.get("v.sLookupField"),
           "sModuleName"    : component.get("v.sModuleName") });   
         
  },

  first : function(component, event, helper) {
    //loads the first page
    //server side pagination
    //console.log("first");
    this.getDataList(component, false);
  },
  gotoSelectedPage : function(component, iSelectedPage){
    //navigate to the selected page
    //it is just client side pagination
    //console.log("gotoSelectedPage");
    component.set("v.iSelectedPage", iSelectedPage);
    component.set("v.iOffsetClient", ((iSelectedPage - 1) % component.get("v.iPagesPerChunk")) * component.get("v.iPageSize"));
    this.updateTable(component);
  },
  setVariablesAndCall : function(component, iOffset){
    //set the variables and call data list
    //console.log("setVariablesAndCall/iOffset");
    component.set("v.iOffset", iOffset);
    component.set("v.iOffsetClient", 0);
    component.set("v.iSelectedPage", (iOffset / component.get("v.iPageSize")) + 1);
    this.getDataList(component, false);
  },
  getDataList : function(component, gotoLastPage) {
    //pass the variables and call task list
    //console.log("getDataList");
    this.getCommentList(component,component.get("v.iOffset"),gotoLastPage);

  },
  getCommentList : function(component, iOffset, gotoLastPage) {
    //returns the filtered data
    //console.log("getTaskList");
                        
        this.callServer(component, "c.getCommentAsString", function(response) {
          //console.log("response>>" + response);
         /* if(this.showUnhandledException(component, response))
            return;*/
            var result = JSON.parse(response);
            console.debug('result:' +result);

            component.set("v.iListSize", result.iListSize);
            component.set("v.lstHisComments", result.lstSubmitted);
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
        },{"sMasterRecordId" : component.get("v.sMasterRecordId"),
           "sCompName"       : component.get("v.selectedTab"),
           "sLookupField"    : component.get("v.sLookupField"),
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
    var lstHisComments = component.get("v.lstHisComments");
    var iListSize = component.get("v.iListSize");
    var iPagesPerChunk = component.get("v.iPagesPerChunk");
    var iChunkSize = iPageSize * iPagesPerChunk;

    console.debug("updateTable");
    console.debug("lstHisComments",lstHisComments);
    /*console.debug('printValues to be called');
    this.printValues(component,event);*/

    if((iOffsetClient + iPageSize) < iListSize){
      lstPagination = lstHisComments.slice(iOffsetClient, iOffsetClient + iPageSize);
      console.debug("(iOffsetClient + iPageSize) < iListSize");
    } else if(iOffsetClient < iListSize){
      lstPagination = lstHisComments.slice(iOffsetClient, iListSize);
      console.debug("iOffsetClient < iListSize");
    }

    component.set("v.lstPagination", lstPagination);
    console.debug('lstPagination',lstPagination);
    this.updateButtons(component);
  },

  updateButtons : function(component) {
    //updates the pagination buttons
    //console.log("updateButtons");
    var iChunkSize = component.get("v.iChunkSize");
    var iOffset = component.get("v.iOffset");
    var iListSize = component.get("v.iListSize");
   /* console.debug('component.find("first")',component.find("first"));
    console.debug('component.find("prevSet")',component.find("prevSet"));
    console.debug('component.find("last")',component.find("last"));
    console.debug('component.find("nextSet")',component.find("nextSet"));*/

    if(component.get("v.bShowComment")) {
      if(iOffset > 0){
        component.set("v.bDisableFirst", false);
        component.set("v.bDisablePrevSet", false);
       /* if(!$A.util.isUndefined(component.find("first")))
          component.find("first").set("v.disabled", false);

        if(!$A.util.isUndefined(component.find("prevSet")))
          component.find("prevSet").set("v.disabled", false);*/
      }else{
        component.set("v.bDisableFirst", true);
        component.set("v.bDisablePrevSet", true);
        /*if(!$A.util.isUndefined(component.find("first")))
          component.find("first").set("v.disabled", true);

        if(!$A.util.isUndefined(component.find("prevSet")))
          component.find("prevSet").set("v.disabled", true);*/
      }

      if(iListSize > iChunkSize){
        component.set("v.bDisableLast", false);
        component.set("v.bDisableNextSet", false);
        /*if(!$A.util.isUndefined(component.find("last")))
          component.find("last").set("v.disabled", false);

        if(!$A.util.isUndefined(component.find("nextSet")))
          component.find("nextSet").set("v.disabled", false);*/
      }else{
        component.set("v.bDisableLast", true);
        component.set("v.bDisableNextSet", true);
        /* if(!$A.util.isUndefined(component.find("last")))
            component.find("last").set("v.disabled", true);
          
         if(!$A.util.isUndefined(component.find("nextSet")))
            component.find("nextSet").set("v.disabled", true);*/
      }
      this.updateSerialButtons(component, iListSize);
    }
   
  },

  updateSerialButtons : function(component, iListSize){
    //updates the pagination serial buttons
    //console.log("updateSerialButtons");
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
    console.debug('lstPageNumbers',lstPageNumbers);
    console.debug('printValues to be called');
    //Start:Akshay[TKT-000823]: removing event parameter since it is not defined in this method and it is not required
    this.printValues(component);
    //End:Akshay[TKT-000823]: removing event parameter since it is not defined in this method and it is not required
  },

  //Start:Akshay[TKT-000823]: removing event parameter since it is not defined in this method and it is not required
  printValues : function(component){
  //End:Akshay[TKT-000823]: removing event parameter since it is not defined in this method and it is not required
    //console.debug('printValues called');
    console.log("iPageSize>>" + component.get("v.iPageSize"));
    console.log("iPagesPerChunk>>" + component.get("v.iPagesPerChunk"));
    console.log("iChunkSize>>" + component.get("v.iChunkSize"));
    console.log("iSelectedPage>>" + component.get("v.iSelectedPage"));
    console.log("iListSize>>" + component.get("v.iListSize"));
    console.log("iOffset>>" + component.get("v.iOffset"));
    console.log("iOffsetClient>>" + component.get("v.iOffsetClient"));
    console.log("lstPageNumbers>>" + component.get("v.lstPageNumbers"));
  },

  saveData : function(component, event, bIsSubmit) {
      console.debug('Inside savedata:', bIsSubmit);
      console.debug('bIsVisibleForTab:', component.get("v.bIsVisibleForTab"));
      console.debug('bShowForPage:', component.get("v.bShowForPage"));
      console.debug('bCanEnterComment:', component.get("v.bCanEnterComment"));
      console.debug('sCommentBody:', component.get("v.sCommentBody"));
      var bCanSaveDraft = (component.get("v.bShowForPage") || component.get("v.bIsVisibleForTab"))
                          && component.get("v.bCanEnterComment") 
                          && component.get("v.sCommentBody") != null 
                          && !$A.util.isEmpty(component.get("v.sCommentBody").trim());
      var bCallSave = (bIsSubmit) ? true : bCanSaveDraft;
      if(bCallSave) {
          this.callServer(component, "c.saveCommentsInfo", function(result) {                
                //console.debug('Inside comment savedata:', bIsSubmit);
                console.debug('result:', result);
                if(result === 'Success'){
                  console.debug('Saved:', result);
                  //component.set("v.bshowHistoryTable",false);
                  //this.loadData(component, event);
                }else{
                  console.debug('Failed to Save:', result);
                }
     

            },{"sMasterRecordId" : component.get("v.sMasterRecordId"),
               "sCompName"       : component.get("v.selectedTab"),
               "sLookupField"    : component.get("v.sLookupField"),
               "sCommentBody"    : component.get("v.sCommentBody"),
               "bIsSubmit"       : bIsSubmit });
      }else {
         console.debug('<<Save can not be called for Comment>>>');
      }
  },
    
  showMore: function(component, event){
         
        console.log(component.get("v.lstHisComments"));
        var index = event.target.dataset.index;
        console.log("index:",index);
        var selectedObj = component.get("v.lstHisComments")[index];
        var id1 = index+'_less';
        var elem = document.getElementById(id1);
        elem.classList.remove("show");
        elem.classList.add("hide");
        
        var id2 = index+'_more';
        var elem = document.getElementById(id2);
        elem.classList.remove("hide");
        elem.classList.add("show");
        
    },
    showLess: function(component, event){
         
        
        var index = event.target.dataset.index;
        console.log("index:",index);
        var selectedObj = component.get("v.lstHisComments")[index];
        
        var id1 = index+'_less';
        var elem = document.getElementById(id1);
        elem.classList.remove("hide");
        elem.classList.add("show");
        
        var id2 = index+'_more';
        var elem = document.getElementById(id2);
        elem.classList.remove("show");
        elem.classList.add("hide");
       
        
    },
  
  showTable : function(component, event) { 
    //For pagination 
    
    var isShown = component.get("v.bshowHistoryTable");
    if(isShown){
        component.set("v.bshowHistoryTable",false);  
    }
    else{
        component.set("v.bshowHistoryTable",true); 
        //this.updateButtons(component);   
    }
    
         
  },
  toggleClass : function(component, event) {
        
        
        var section = component.find("commentAccordian");
        $A.util.toggleClass(section, "slds-is-open");
        var ifIcon = component.get('v.bIcon');
        if(ifIcon){
            component.set('v.bIcon',false);
        }
        else{
            component.set('v.bIcon',true);
        }
       
    },

  

   // console.debug('hislst:' ,component.get("v.lstHisComments"));
    /*var modalBody;
    $A.createComponent("c:CC_CommentsTable", {
        "lstComments" : component.get("v.lstHisComments"),
        "mapLabels" : component.get("v.mapLabels")
       },
       function(content, status) {
           if (status === "SUCCESS") {
               modalBody = content;
               component.find('overlayLib').showCustomModal({
                   
                   body: modalBody, 
                   header: component.get("v.mapLabels").CC_LBL_Comment_History,
                   referenceSelector: ".openComment",
                   showCloseButton: true,
                   cssClass: "slds-modal,slds-modal_large",
                   closeCallback: function() {
                   }
                   
               }).then(function (overlay) {
                   
               });
            }
       })*/
        
    
})