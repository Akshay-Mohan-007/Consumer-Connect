/***************************************************************************************************************************************
 * NAME   : CC_TasksComponentController
 * DESCRIPTION  : Controller Class for CC_TasksComponent which will list all the Tasks in the Dashboard for the user.
 *    				Before using this make sure that labels 'CC_SITE_NAME_SELF_SERVICE' 'CC_SITE_NAME_SERVICE_PROVIDER' and
 *					custom settings field 'CC_Task_Dashboard_Page_Size__c', 'CC_Task_Dashboard_Pages_Per_Screen__c' 
 *					in 'CC_Master_Settings__c' are populated correctly
 * @AUTHOR   : Nidhin V K
 * @DATE   : 11-09-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               11-09-2017          Initial version        
 *
 ****************************************************************************************************************************************/

public with sharing class CC_TasksComponentController {
    
	public class MyTask {
		public String sRecordId;
		public String sName;
		public String sStatus;
		public String sComment;
		public String sShortComment;
		public String sIndividualId;
		public String sIndividualName;
		public String sDueDate;
		public Integer iDaysTaskOpen;
		public Boolean bIsDueDatePassed;
		public String sReceivedDate;
		public String sCreatedDate;
		public String sAppCase;
	}

	public class ComponentWrapper {
		public Integer iListSize;
		public Integer iPageSize;
		public Integer iPagesPerChunk;
		public List<MyTask> lstMyTasks;
		public List<CC_PickListValue_Wrapper> lstOwnerPicklist;
		public Map<String, String> mapLabels;
		public String sSiteName;
		public ComponentWrapper() {
			lstMyTasks = new List<MyTask>();
			lstOwnerPicklist = new List<CC_PickListValue_Wrapper>();
			lstOwnerPicklist.add(new CC_PickListValue_Wrapper(UserInfo.getUserId(), System.Label.CC_MY_TASKS));
			mapLabels = new Map<String, String>();
			CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
			iPageSize = Integer.valueOf(objSettings.Task_Dashboard_Page_Size__c);
			iPagesPerChunk = Integer.valueOf(objSettings.Task_Dashboard_Pages_Per_Screen__c);
		}
	}
	
	/* METHOD NAME   : loadData
	 * DESCRIPTION  : load the records on page load
	 *
	 * RETURN TYPE   : list of items include tasks list, labels, 
	 * PARAMETER   : sOwner        
	 */
	@AuraEnabled
	public static String loadData(String sQueueName, String sSortField, String sSortOrder){
		try{
			ComponentWrapper wrapper = new ComponentWrapper();
			wrapper.lstMyTasks = getMyTaskList(UserInfo.getUserId(), 0, sSortField, sSortOrder, CC_Constants.CC_EMPTY);
			wrapper.iListSize = wrapper.lstMyTasks.size();
			Group ObjGroup = CC_Utility.getQueueInfo(sQueueName);
			wrapper.lstOwnerPicklist.add(new CC_PickListValue_Wrapper(ObjGroup.Id, ObjGroup.Name));
			wrapper.mapLabels = loadLabelAndError();
			wrapper.sSiteName = Site.getName();
			return '{"DashboardInfo":' + JSON.serialize(wrapper) + '}';
		}catch(Exception ex){
			//throw error no such field exists
            System.debug('Exception on Class : CC_TasksComponentController - loadData, Error : ' +
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
	
	/* METHOD NAME   : getMyTaskListAsString
	 * DESCRIPTION  : Returns all the tasks in his queue in string format
	 *
	 * RETURN TYPE   : queue name
	 * PARAMETER   : TaskList        
	 */
	@AuraEnabled
	public static String getMyTaskListAsString(String sOwnerId, Integer iOffset, String sSortField, String sSortOrder, String sSearchText, Boolean gotoLastPage){
		try{
			if(gotoLastPage){
				String sQuery = getQuery(sOwnerId, iOffset, sSortField, sSortOrder, sSearchText, gotoLastPage, 0);
				Integer iSize = Database.countQuery(sQuery);
				CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
				Integer iChunkSize = Integer.valueOf(objSettings.Task_Dashboard_Page_Size__c * objSettings.Task_Dashboard_Pages_Per_Screen__c);
				if(iSize > iChunkSize){
					iOffset = iSize - math.mod(iSize, iChunkSize);
					if(iOffset == iSize)
						iOffset = iSize - iChunkSize;
				}
			}
			List<MyTask> lstTasks = getMyTaskList(sOwnerId, iOffset, sSortField, sSortOrder, sSearchText);
			if(lstTasks.size() > 0)
				return '{"lstTasks":' + JSON.serialize(lstTasks) + ',"iListSize":' + lstTasks.size() + ',"iOffset":' + iOffset + '}';
			else
				return '{"lstTasks":[],"iListSize":0,"iOffset":' + iOffset + '}';
		}catch(Exception ex){
			//throw error no such field exists
            System.debug('Exception on Class : CC_TasksComponentController - getMyTaskListAsString, Error : ' +
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
	
	/* METHOD NAME   : getMyTaskList
	 * DESCRIPTION  : Returns all the tasks in his queue and owned by him
	 *
	 * RETURN TYPE   : queue name
	 * PARAMETER   : TaskList        
	 */
	@AuraEnabled
	public static List<MyTask> getMyTaskList(String sOwnerId, Integer iOffset, String sSortField, String sSortOrder, String sSearchText){
		try{
			List<MyTask> lstTasks = new List<MyTask>();
			CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
			Integer iLimit = Integer.valueOf((objSettings.Task_Dashboard_Page_Size__c * objSettings.Task_Dashboard_Pages_Per_Screen__c) + 1);
			String sQuery = getQuery(sOwnerId, iOffset, sSortField, sSortOrder, sSearchText, false, iLimit);
			for(DT_Task__c objTask : Database.query(sQuery)){
				MyTask myTask = new MyTask();
				myTask.sRecordId = objTask.Id;
				myTask.sName = objTask.Name;
				myTask.sStatus = objTask.DT_Status__c;
				myTask.sComment = objTask.DT_Comments__c;
				myTask.sShortComment = String.isNotBlank(myTask.sComment) ? (myTask.sComment.length() > 25 ? myTask.sComment.substring(0,24) : myTask.sComment) : '';
				if(String.isNotBlank(objTask.Contact__c)){
					myTask.sIndividualId = objTask.Contact__c;
					myTask.sIndividualName = objTask.Contact__r.LastName + ', ' + objTask.Contact__r.FirstName;
				}
				myTask.sDueDate = objTask.DT_Due_Date__c == NULL? '' : objTask.DT_Due_Date__c.format();
				if(objTask.DT_Days_Task_Open__c != NULL)
					myTask.iDaysTaskOpen = Integer.valueOf(objTask.DT_Days_Task_Open__c);
				if(String.isNotBlank(objTask.Application__c)){
					myTask.sAppCase = objTask.Application__r.Name;
				}
				if(String.isNotBlank(objTask.Case__c)){
					myTask.sAppCase = String.isBlank(myTask.sAppCase) ? objTask.Case__r.CaseNumber : myTask.sAppCase + '/' + objTask.Case__r.CaseNumber;
				}
				myTask.bIsDueDatePassed = objTask.DT_Is_Due_Date_Passed__c;
				myTask.sReceivedDate = objTask.DT_Open_Date__c == NULL ? '' : objTask.DT_Open_Date__c.format(CC_Constants.CC_OUTPUT_DATE_FORMAT);
				lstTasks.add(myTask);
			}
			System.debug('lstTasks>>' + lstTasks);
			return lstTasks;
		}catch(Exception ex){
			//throw error no such field exists
            System.debug('Exception on Class : CC_TasksComponentController - getMyTaskList, Error : ' +
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
	@AuraEnabled
	public static String getQuery(String sOwnerId, Integer iOffset, String sSortField, String sSortOrder, String sSearchText, Boolean gotoLastPage, Integer iLimit){
		String sFieldSet = '';
		if(gotoLastPage)
			sFieldSet = ' count() ';
		else
			sFieldSet = ' DT_Comments__c, Contact__c, DT_Due_Date__c, ' +
							'Contact__r.FirstName, Contact__r.LastName, ' + 
							'DT_Days_Task_Open__c, DT_Is_Due_Date_Passed__c, ' +
							'DT_Open_Date__c, DT_Status__c, ' +
							'Application__c, Application__r.Name, Name, Id, CreatedDate, ' +
							'Case__c, Case__r.CaseNumber ';
		
		String sQuery = 'SELECT ' + sFieldSet +
							'FROM DT_Task__c ' +
							'WHERE ' +
							'OwnerId = :sOwnerId ' +
							'AND ' +
							'DT_Status__c IN (\'' + DT_Constants.DT_TASK_STATUS_NEW + '\', \'' + DT_Constants.DT_TASK_STATUS_IN_PROGRESS + '\') ';
			
		if(String.isNotBlank(sSearchText))
			sQuery += ' AND (' +
						'(Application__r.Name LIKE \'%' + sSearchText +'%\') OR ' +
						'(Contact__r.Name LIKE \'%' + sSearchText +'%\')' +
						') ';
		if(String.isNotBlank(sSortField) && String.isNotBlank(sSortOrder) && !gotoLastPage)
			sQuery += ' ORDER BY ' + sSortField + ' ' + sSortOrder;
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
	 * RETURN TYPE   : list of items include tasks list, labels, 
	 * PARAMETER   : sOwner        
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
		mapLabelAndError.put('MY_USER_ID', UserInfo.getUserId());

		return mapLabelAndError;
	}
}