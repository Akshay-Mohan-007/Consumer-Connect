/***************************************************************************************************************************************
 * NAME   : CC_CommentsController
 * DESCRIPTION  : for CC_Comment component 
 *    
 * @AUTHOR   : Debalina
 * @DATE   : 10-27-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Debalina				  10-27-2017			Initial version 
 * Debalina               01-04-2018            Added logic for saving/loading comment for any lookup parent   
****************************************************************************************************************************************/ 

public without sharing class CC_CommentsController {

	public class CommentsInfo {
        public String sComponentName;
        public String sCreatedDate;
        public String sCommentsCreatedBy;
        public String sComments;
        public String sDisplayMode;
        public String shrtComments;

        public CommentsInfo(CC_Comment__c objComment){
        	sComponentName = objComment.Page_Name__c;
	        sCreatedDate = String.valueOf(objComment.CreatedDate.format('MM/dd/yyyy hh:mm a'));
	        sCommentsCreatedBy = objComment.CreatedBy.Name;
	        sComments = objComment.Body__c;
            shrtComments = String.isNotBlank(objComment.Body__c)? 
                          (objComment.Body__c.length() > 80 ? objComment.Body__c.substring(0,79) : objComment.Body__c) : '';
	        sDisplayMode = objComment.Display_Mode__c;

        }
    }

    /************************************************************************************************************************
     Method Name : loadCommentsInfo
     Description : Loads all historical or In-Edit Comments associated to a particular component
     Parameter   : Input is Application Id, Component Name
     Return type : Returns JSON of list of CommentsInfo
     *************************************************************************************************************************/
    @AuraEnabled
    public static String loadCommentsInfo(String sMasterRecordId, String sCompName, String sLookupField, String sModuleName) { 

    	List<CommentsInfo> lstSubmitted = new List<CommentsInfo>();
    	List<CommentsInfo> lstDraft = new List<CommentsInfo>();

        String sDraftMode = CC_Constants.CC_MODE_DRAFT;
        String sQuery = 'SELECT Id,Body__c,Display_Mode__c,Page_Name__c,Related_Application__c,CreatedDate,CreatedBy.Name FROM CC_Comment__c';
    	sQuery += ' WHERE Page_Name__c =: sCompName AND Display_Mode__c =: sDraftMode';
        sQuery += ' AND '+sLookupField+' =:sMasterRecordId';

        List<CC_Comment__c> lstDraftComments = Database.query(sQuery);
        System.debug('lstDraftComments size:' +lstDraftComments.size());

        for(CC_Comment__c objComment : lstDraftComments) {
    		lstDraft.add(new CommentsInfo(objComment));	
    	}
        lstSubmitted = getCommentInfo(sMasterRecordId,sCompName,sLookupField,0);
        System.debug('lstSubmitted:' +lstSubmitted);

    	Map<String,String> mapLabelAndError = loadLabelAndError();


        List<CC_Module__mdt> lstModule = [SELECT 
                                            DeveloperName,
                                            Component_with_Comment__c
                                            FROM 
                                            CC_Module__mdt 
                                            WHERE 
                                            DeveloperName = :sModuleName LIMIT 1];

        List<String> lstCommentTabs = new List<String>();
        if(lstModule.size() == 1) {
            lstCommentTabs = lstModule[0].Component_with_Comment__c.split(';');
        }

        CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
        Integer iListSize = lstSubmitted.size();
        Integer iPageSize = Integer.valueOf(objSettings.Comment_Records_Per_Page__c);
        Integer iPagesPerChunk = Integer.valueOf(objSettings.Comment_Pages_Per_Screen__c);

        return '{"lstDraft":'+JSON.serialize(lstDraft)
		+',"lstSubmitted":'+JSON.serialize(lstSubmitted)
        +',"lstCommentTabs":'+JSON.serialize(lstCommentTabs)
		+',"MapLabelError":'+JSON.serialize(mapLabelAndError)
        +',"iListSize":'+JSON.serialize(iListSize)
        +',"iPageSize":'+JSON.serialize(iPageSize)
        +',"iPagesPerChunk":'+JSON.serialize(iPagesPerChunk)
        + '}';

    }


   public static List<CommentsInfo> getCommentInfo(String sMasterRecordId, String sCompName, String sLookupField, Integer iOffset) {
        CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
        Integer iLimit = Integer.valueOf((objSettings.Comment_Records_Per_Page__c * objSettings.Comment_Pages_Per_Screen__c) + 1);
        String sQuery = getQuery(sMasterRecordId,sCompName,sLookupField, iOffset, false, iLimit);

        List<CommentsInfo> lstSubmitted = new List<CommentsInfo>();
        for(CC_Comment__c objComment : Database.query(sQuery)){
            lstSubmitted.add(new CommentsInfo(objComment));
        }
        
        return lstSubmitted;
    }


    @AuraEnabled
    public static String getCommentAsString(String sMasterRecordId, String sCompName, String sLookupField, Integer iOffset, Boolean gotoLastPage){
        String sQuery;
        try{
            if(gotoLastPage){
                sQuery = getQuery(sMasterRecordId,sCompName,sLookupField,iOffset, gotoLastPage, 0);
                Integer iSize = Database.countQuery(sQuery);
                CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
                Integer iChunkSize = Integer.valueOf(objSettings.Comment_Records_Per_Page__c * objSettings.Comment_Pages_Per_Screen__c);
                if(iSize > iChunkSize){
                    iOffset = iSize - math.mod(iSize, iChunkSize);
                    if(iOffset == iSize)
                        iOffset = iSize - iChunkSize;
                }
            }
            
            List<CommentsInfo> lstSubmitted = getCommentInfo(sMasterRecordId,sCompName,sLookupField,iOffset);
            if(lstSubmitted.size() > 0)
                return '{"lstSubmitted":' + JSON.serialize(lstSubmitted) + ',"iListSize":' + lstSubmitted.size() + ',"iOffset":' + iOffset + '}';
            else
                return '{"lstSubmitted":[],"iListSize":0,"iOffset":' + iOffset + '}';
        }catch(Exception ex){
            //throw error no such field exists
            System.debug('Exception on Class : CC_CommentsController - getCommentAsString, Error : ' +
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


      /* METHOD NAME   : getQuery
     * DESCRIPTION  : return the query
     *
     * RETURN TYPE   : query
     * PARAMETER   : boolean        
     */
    public static String getQuery(String sMasterRecordId, String sCompName, String sLookupField, Integer iOffset, Boolean gotoLastPage, Integer iLimit){
        String sFieldSet = '';
        String sSubmitted = CC_Constants.CC_MODE_SUBMITTED;
        if(gotoLastPage)
            sFieldSet = ' count()';
        else
            sFieldSet = 'Id,Body__c,Display_Mode__c,Page_Name__c,Related_Application__c,CreatedDate,CreatedBy.Name';
        
        String sQuery = 'SELECT ' + sFieldSet +
                            ' FROM CC_Comment__c' +
                            ' WHERE Page_Name__c =: sCompName AND Display_Mode__c = \''+sSubmitted+'\'';
        sQuery += ' AND '+sLookupField+' =:sMasterRecordId';
        
        if(!gotoLastPage)
            sQuery += ' ORDER BY CreatedDate DESC';
        if(iLimit != NULL && !gotoLastPage)
            sQuery += ' LIMIT ' + iLimit;
        if(iOffset != NULL && !gotoLastPage)
            sQuery += ' OFFSET ' + iOffset; 
        System.debug('sQuery>>' + sQuery);
        
        return sQuery;
    }

    @TestVisible
	private static Map<String,String> loadLabelAndError() {

		Map<String,String> mapLabelAndError = new Map<String, String>();
		mapLabelAndError.put('CC_LBL_Comment',System.label.CC_LBL_Comment);
		mapLabelAndError.put('CC_LBL_CommentBy',System.label.CC_LBL_CommentBy);
		mapLabelAndError.put('CC_LBL_Comment_History',System.label.CC_LBL_Comment_History);
		mapLabelAndError.put('CC_LBL_CommentDate',System.label.CC_LBL_CommentDate);
		mapLabelAndError.put('CC_LBL_NO_RECORD_EXIST',System.label.CC_LBL_NO_RECORD_EXIST);
		
		return mapLabelAndError;
	}

	@AuraEnabled
    public static String saveCommentsInfo(String sMasterRecordId, String sCompName, String sLookupField, String sCommentBody, Boolean bIsSubmit) { 
    	String retString ='';
    	CC_Comment__c objToInsert = new CC_Comment__c();
    	objToInsert.Body__c = sCommentBody;
    	objToInsert.Page_Name__c = sCompName;

    	try{

            String sDraftMode = CC_Constants.CC_MODE_DRAFT;
            String sQuery = 'SELECT Id,Body__c,Display_Mode__c,Page_Name__c,Related_Application__c,CreatedDate,CreatedBy.Name FROM CC_Comment__c';
            sQuery += ' WHERE Page_Name__c =: sCompName AND Display_Mode__c =: sDraftMode';
            sQuery += ' AND '+sLookupField+' =:sMasterRecordId';

            List<CC_Comment__c> lstExistingComment = Database.query(sQuery);
            System.debug('lstExistingComment size:' +lstExistingComment.size());

    		if(lstExistingComment.size() == 1) {
    			objToInsert.Id = lstExistingComment[0].Id;
    		}
            else{
                objToInsert.put(sLookupField,sMasterRecordId);
            }

            System.debug('bIsSubmit:' +bIsSubmit);
    		if(bIsSubmit){
    			objToInsert.Display_Mode__c = CC_Constants.CC_MODE_SUBMITTED;

                sQuery = 'SELECT Id,Body__c,Display_Mode__c,Page_Name__c,Related_Application__c,CreatedDate,CreatedBy.Name FROM CC_Comment__c';
                sQuery += ' WHERE Display_Mode__c =: sDraftMode';
                sQuery += ' AND '+sLookupField+' =:sMasterRecordId';

                List<CC_Comment__c> lstAllAppComments = Database.query(sQuery);
                System.debug('lstAllAppComments size:' +lstAllAppComments.size());

    			List<CC_Comment__c> lstCommentToUpdate = new List<CC_Comment__c>();
    			for(CC_Comment__c objComment: lstAllAppComments) {
    				objComment.Display_Mode__c = CC_Constants.CC_MODE_SUBMITTED;
    				lstCommentToUpdate.add(objComment);	
    			}

                //If Last Page comment
                if(lstCommentToUpdate.size() > 0)
                    update lstCommentToUpdate;

    		}else{
    			objToInsert.Display_Mode__c = CC_Constants.CC_MODE_DRAFT;
    		}

            if(String.isNotBlank(objToInsert.Body__c))
    		  upsert objToInsert;
    		retString = 'Success';
        }
    	catch(Exception ex){
            retString = 'Fail';
            System.debug('Exception on Class : CC_CommentsController - saveCommentsInfo, Error : ' +
            ex.getMessage() +
            ' Line Number : ' +
            ex.getLineNumber() +
            ' Cause : ' +
            ex.getCause() +
            ' Type : ' +
            ex.getTypeName());
        }
        return retString;
    }
}