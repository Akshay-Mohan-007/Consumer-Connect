/***************************************************************************************************************************************
 * NAME   : CC_FeedItemListController
 * DESCRIPTION  : Controller Class for CC_FeedItemList which will list all the feed items for the user.
 * @AUTHOR   : Nidhin V K
 * @DATE   : 12-08-2017
 * 
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               12-08-2017          Initial version   
 * Sourav Ghosh				12-12-2017			Code restructuring and Pagination and additional functionality implementation     
 *
 ****************************************************************************************************************************************/

public without sharing class CC_FeedItemListController {

	public class MyFeed {
		public String sRecordId;
		public String sFeed;
		public String sCreatedDate;
		public String sCreatedBy;
		public List<FeedAttachmentWrapper> lstAttchments = new List<FeedAttachmentWrapper>();
		}

	public class FeedAttachmentWrapper {
		public String sTitle;
		public String sAttachmentId;
	   }	
	
	/* METHOD NAME   : loadData
	 * DESCRIPTION  : load the records on page load
	 * 
	 * RETURN TYPE   : JSON String of the Wrapper containing Feed Item values and Custom Label Map
	 * PARAMETER   : Selected Feed Item id        
	 */
	@AuraEnabled
	public static String loadData(String feedItemId){

		List<MyFeed> lstSelectedFeed = getFeedInfo(feedItemId, true, 0);
		List<MyFeed> lstHistoricFeeds = getFeedInfo(feedItemId, false, 0);
		Map<String, String> mapLabels = loadLabelAndError();

		CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
        Integer iListSize = lstHistoricFeeds.size();
        Integer iPageSize = Integer.valueOf(objSettings.Feed_Records_Per_Page__c);
        Integer iPagesPerChunk = Integer.valueOf(objSettings.Feed_Pages_Per_Screen__c);


		return '{"SelectedFeed":' + JSON.serialize(lstSelectedFeed[0]) 
				+',"HistoricFeeds":'+JSON.serialize(lstHistoricFeeds)
				+',"MapLabel":'+JSON.serialize(mapLabels)
				+',"iListSize":'+JSON.serialize(iListSize)
		        +',"iPageSize":'+JSON.serialize(iPageSize)
		        +',"iPagesPerChunk":'+JSON.serialize(iPagesPerChunk)
				+'}';

	}

	private static List<MyFeed> getFeedInfo(String feedItemId, Boolean bIsSelected, Integer iOffset) {
        CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
        Integer iLimit = Integer.valueOf((objSettings.Feed_Records_Per_Page__c * objSettings.Feed_Pages_Per_Screen__c) + 1);
        String sQuery;
        if(bIsSelected){
        	sQuery = 'Select Id, CreatedDate, CreatedBy.Name, Body'+
        		' FROM FeedItem WHERE Id = \''+feedItemId+'\'';
        }
        else
        	sQuery = getQuery(feedItemId, iOffset, false, iLimit);
        List<MyFeed> lstMainData = getMainData(feedItemId, sQuery, bIsSelected);                     
        return lstMainData;
    }

    /* METHOD NAME   : getFeedAsString
	 * DESCRIPTION  : to suppy data in pagination table
	 * 
	 * RETURN TYPE   : JSON String 
	 * PARAMETER   : Selected Feed Item id, offset and lastpage identifier        
	 */

    @AuraEnabled
    public static String getFeedAsString(String feedItemId, Integer iOffset, Boolean gotoLastPage){
        String sQuery='';
        try{
            if(gotoLastPage){
                sQuery = getQuery(feedItemId, iOffset, gotoLastPage, 0);
                Integer iSize = Database.countQuery(sQuery);
                CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
                Integer iChunkSize = Integer.valueOf(objSettings.Feed_Records_Per_Page__c * objSettings.Feed_Pages_Per_Screen__c);
                if(iSize > iChunkSize){
                    iOffset = iSize - math.mod(iSize, iChunkSize);
                    if(iOffset == iSize)
                        iOffset = iSize - iChunkSize;
                }
            }

            List<MyFeed> lstSubmitted = getFeedInfo(feedItemId,false,iOffset);
            if(lstSubmitted.size() > 0)
                return '{"lstSubmitted":' + JSON.serialize(lstSubmitted) + ',"iListSize":' + lstSubmitted.size() + ',"iOffset":' + iOffset + '}';
            else
                return '{"lstSubmitted":[],"iListSize":0,"iOffset":' + iOffset + '}';
        }catch(Exception ex){
            //throw error no such field exists
            System.debug('Exception on Class : CC_FeedItemListController - getFeedAsString, Error : ' +
                ex.getMessage() +
                ' Line Number : ' +
                ex.getLineNumber() +
                ' Cause : ' +
                ex.getCause() +
                ' Type : ' +
                ex.getTypeName());
            return NULL;
        }
    }

    /* METHOD NAME   : getMainData
	 * DESCRIPTION  : Method to fetch and restructure all required data
	 * 
	 * RETURN TYPE   : List of wrapper
	 * PARAMETER   : Selected Feed Item id, Query to fetch feed item and boolean to identify the record        
	 */

    private static List<MyFeed> getMainData(String feedItemId, String sQuery, Boolean bIsSelected){
    try{
	    	Map<Id,MyFeed> mapMyFeed = new Map<Id,MyFeed>();
			MyFeed objSelectedFeed = new MyFeed(); // to store selected feed details
			List<MyFeed> lstHistoricFeeds = new List<MyFeed>(); // to store historic feeds
			List<MyFeed> lstToReturn = new List<MyFeed>();
	        
	        for(FeedItem objFeedItem : Database.query(sQuery)){
					MyFeed objFeed = new MyFeed();
					objFeed.sRecordId = objFeedItem.Id;
					objFeed.sFeed = objFeedItem.Body;
					objFeed.sCreatedDate = objFeedItem.CreatedDate.format(CC_Constants.CC_OUTPUT_DATE_FORMAT_FOR_FEED);
					objFeed.sCreatedBy = objFeedItem.CreatedBy.Name;

					if(feedItemId.equals(objFeedItem.Id) && bIsSelected)
						objSelectedFeed = objFeed;
					else if(!bIsSelected)	
						lstHistoricFeeds.add(objFeed);

					mapMyFeed.put(objFeedItem.id,objFeed);
				}

				List<FeedAttachment> lstFeedAttachment = [SELECT Id,RecordId,FeedEntityId 
											FROM FeedAttachment WHERE FeedEntityId in :(mapMyFeed.keySet())];
				if(!lstFeedAttachment.isEmpty()){
					Set<Id> setCvIds = new Set<Id>();
					Map<Id,Id> mapCvFiIds = new Map<Id,Id>();

					for(FeedAttachment objAttachment : lstFeedAttachment){
						setCvIds.add(objAttachment.RecordId);
						mapCvFiIds.put(objAttachment.RecordId,objAttachment.FeedEntityId);
					}
					
					Map<String ,String> mapContentVersionsDetails = new Map<String ,String>();
					
					for(ContentVersion objCV : [Select Id,Title from ContentVersion 
											where Id in:(mapCvFiIds.keySet())]){

						mapContentVersionsDetails.put(objCV.id,objCV.title);

						FeedAttachmentWrapper objWrp = new FeedAttachmentWrapper();
						objWrp.sTitle = objCV.Title;
						objWrp.sAttachmentId = objCV.Id;

						if(mapMyFeed.containsKey(mapCvFiIds.get(objCV.Id))){
							MyFeed objFinalFeed = mapMyFeed.get(mapCvFiIds.get(objCV.Id));
							List<FeedAttachmentWrapper> lstTemp = new List<FeedAttachmentWrapper>();
							lstTemp.add(objWrp);
							if(objFinalFeed.lstAttchments.size() > 0)
								lstTemp.addAll(objFinalFeed.lstAttchments);
							objFinalFeed.lstAttchments = lstTemp;
							mapMyFeed.put(mapCvFiIds.get(objCV.Id),objFinalFeed);
						}

					}

					if(mapMyFeed.containsKey(feedItemId)){
						objSelectedFeed = mapMyFeed.get(feedItemId); 
						lstToReturn = new List<MyFeed>{objSelectedFeed};
					}

					if(lstHistoricFeeds.size() > 0){
						for(MyFeed objMyFeed : lstHistoricFeeds){
							if(mapMyFeed.containsKey(objMyFeed.sRecordId))
								objMyFeed = mapMyFeed.get(objMyFeed.sRecordId); 	
						}
						lstToReturn.addAll(lstHistoricFeeds);
					}
				}
				else{
					if(bIsSelected)
						lstToReturn = new List<MyFeed>{objSelectedFeed};
					else{
						lstToReturn.addAll(lstHistoricFeeds);
					}
				}

				return lstToReturn;
		}
		catch(Exception ex){
		//throw error no such field exists
        System.debug('Exception on Class : CC_FeedItemListController - getMainData, Error : ' +
            ex.getMessage() +
            ' Line Number : ' +
            ex.getLineNumber() +
            ' Cause : ' +
            ex.getCause() +
            ' Type : ' +
            ex.getTypeName());
        throw ex;
    	}
	}

	/* METHOD NAME   : getQuery
	 * DESCRIPTION  : Method to build query dynamically
	 * 
	 * RETURN TYPE   : Query in string format
	 * PARAMETER   : Selected Feed Item id, offset, last page identifier and limit        
	 */

	public static String getQuery(String feedItemId, Integer iOffset, Boolean gotoLastPage, Integer iLimit){
        String sFieldSet = '';

        if(gotoLastPage)
            sFieldSet = ' count()';
        else
            sFieldSet = 'Id, CreatedDate, CreatedBy.Name, Body';
        
        String sQuery = 'SELECT ' + sFieldSet +
                            ' FROM FeedItem'+
                            ' WHERE ParentId = \''+UserInfo.getUserId()+'\'';
      
        	sQuery += 'AND Id != \''+feedItemId+'\'';

        	if(!gotoLastPage)
            	sQuery += ' ORDER BY CreatedDate DESC';
           
	        if(iLimit != NULL && !gotoLastPage)
	            sQuery += ' LIMIT ' + iLimit;
	        
	        if(iOffset != NULL && !gotoLastPage)
	        	sQuery += ' OFFSET ' + iOffset;                                   

        System.debug('sQuery>>' + sQuery);
        
        return sQuery;
    }
    
	/* METHOD NAME   : loadLabelAndError
	 * DESCRIPTION  : load the labels and errors for the page
	 *
	 * RETURN TYPE   : Map containing label name as Key and Label as value
	 * PARAMETER   :         
	 */
	@TestVisible
	private static Map<String, String> loadLabelAndError() {
		Map<String, String> mapLabelAndError = new Map<String, String>();
		mapLabelAndError.put('CC_START', System.Label.CC_START);
		mapLabelAndError.put('CC_CONTINUE', System.Label.CC_CONTINUE);
		mapLabelAndError.put('CC_SELECT_QUEUE', System.Label.CC_SELECT_QUEUE);
		mapLabelAndError.put('CC_SEARCH', System.Label.CC_SEARCH);
		mapLabelAndError.put('CC_TASK_NAME', System.Label.CC_TASK_NAME);
		mapLabelAndError.put('CC_APP_CASE', System.Label.CC_APP_CASE);
		mapLabelAndError.put('CC_INDIVIDUAL_NAME', System.Label.CC_INDIVIDUAL_NAME);
		mapLabelAndError.put('CC_LBL_WAIVER_PROGRAM', System.Label.CC_LBL_WAIVER_PROGRAM);
		mapLabelAndError.put('CC_Label_Status', System.Label.CC_Label_Status);
		mapLabelAndError.put('CC_ACTION', System.Label.CC_ACTION);
		mapLabelAndError.put('CC_RECEIVED_DATE', System.Label.CC_RECEIVED_DATE);
		mapLabelAndError.put('CC_DUE_DATE', System.Label.CC_DUE_DATE);
		mapLabelAndError.put('CC_NO_TASKS', System.Label.CC_NO_TASKS);
		mapLabelAndError.put('CC_SITE_NAME_SELF_SERVICE', System.Label.CC_SITE_NAME_SELF_SERVICE);
		mapLabelAndError.put('CC_SITE_NAME_SERVICE_PROVIDER', System.Label.CC_SITE_NAME_SERVICE_PROVIDER);
		mapLabelAndError.put('DT_TASK_STATUS_NEW', DT_Constants.DT_TASK_STATUS_NEW);
		mapLabelAndError.put('CC_LBL_Comment',System.label.CC_LBL_Comment);
		mapLabelAndError.put('DT_LABEL_CONTACT_ADMIN', System.Label.DT_LABEL_CONTACT_ADMIN);
		mapLabelAndError.put('CC_Label_Close', System.Label.CC_Label_Close);
		mapLabelAndError.put('MY_USER_ID', UserInfo.getUserId());
		mapLabelAndError.put('CC_Label_Feed',System.Label.CC_Label_Feed);
		mapLabelAndError.put('CC_Label_View_Attachment',System.Label.CC_Label_View_Attachment);
		mapLabelAndError.put('CC_Label_View_Attacments',System.Label.CC_Label_View_Attacments);
		mapLabelAndError.put('CC_Label_No_Feed_To_Display',System.Label.CC_Label_No_Feed_To_Display);
		mapLabelAndError.put('CC_Label_Feed_History',System.Label.CC_Label_Feed_History);
		mapLabelAndError.put('CC_Label_Attachments',System.Label.CC_Label_Attachments);
		mapLabelAndError.put('CC_Label_Posted_On',System.Label.CC_Label_Posted_On);
		mapLabelAndError.put('CC_Label_Selected_Notification',System.Label.CC_Label_Selected_Notification);
		mapLabelAndError.put('CC_Label_at',System.Label.CC_Label_at);
		mapLabelAndError.put('CC_Label_on',System.Label.CC_Label_on);


		return mapLabelAndError;
	}
}