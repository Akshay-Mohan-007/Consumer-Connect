/***************************************************************************************************************************************
 * NAME   : CC_WaitlistedApplicationListController
 * DESCRIPTION  : Controller for CC_WaitlistedApplicationList, Lists all the Waitlisted Applications assigned to the user.
 *    				Before using this make sure that the custom settings field 'WL_App_List_Page_Size__c', 
 *					'WL_App_List_Pages_Per_Screen__c' in 'CC_Master_Settings__c' are populated correctly
 *    
 * @AUTHOR   : Nidhin V K
 * @DATE   : 15-Dec-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               15-Dec-2017          Initial version        
 *
 ****************************************************************************************************************************************/

public with sharing class CC_WaitlistedApplicationListController {
    
	public class MyApp {
		public String sRecordId;
		public String sAppId;
		public String sAppNumber;
		public String sIndividualId;
		public String sIndividualName;
		public String sWLProgramId;
		public String sWLProgramName;
		public String sCreatedDate;
		public String sAction;
	}

	public class ComponentWrapper {
		public Integer iListSize;
		public Integer iPageSize;
		public Integer iPagesPerChunk;
		public List<MyApp> lstMyApps;
		public Map<String, String> mapLabels;
		public List<String> lstColumnHeaders;
		public String sSiteName;
		public ComponentWrapper() {
			lstMyApps = new List<MyApp>();
			lstColumnHeaders = getColumnHeaders();
			mapLabels = new Map<String, String>();
			CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
			iPageSize = Integer.valueOf(objSettings.App_Dashboard_Page_Size__c);
			iPagesPerChunk = Integer.valueOf(objSettings.WL_App_List_Pages_Per_Screen__c);
		}
	}
	
	/* METHOD NAME   : loadData
	 * DESCRIPTION  : load the records on page load
	 *
	 * RETURN TYPE   : list of items include tasks list, labels, 
	 * PARAMETER   : sOwner        
	 */
	@AuraEnabled
	public static String loadData(String sSortField, String sSortOrder){
		try{
			ComponentWrapper wrapper = new ComponentWrapper();
			wrapper.lstMyApps = getMyAppList(0, sSortField, sSortOrder, CC_Constants.CC_EMPTY);
			wrapper.iListSize = wrapper.lstMyApps.size();
			wrapper.mapLabels = loadLabelAndError();
			wrapper.sSiteName = Site.getName();
			return JSON.serialize(new CC_ResponseWrapper(true, JSON.serialize(wrapper)));
		}catch(Exception ex){
			//throw error no such field exists
            System.debug('Exception on Class : CC_ApplicationComponentController - loadData, Error : ' +
                ex.getMessage() +
                ' Line Number : ' +
                ex.getLineNumber() +
                ' Cause : ' +
                ex.getCause() +
                ' Type : ' +
                ex.getTypeName());
	        return JSON.serialize(new CC_ResponseWrapper(false, NULL, new List<String>{System.Label.DT_LABEL_CONTACT_ADMIN}));
	    }
	}
	
	/* METHOD NAME   : getMyAppListAsString
	 * DESCRIPTION  : Returns all the tasks in his queue in string format
	 *
	 * RETURN TYPE   : queue name
	 * PARAMETER   : TaskList        
	 */
	@AuraEnabled
	public static String getMyAppListAsString(Integer iOffset, String sSortField, String sSortOrder, String sSearchText, Boolean gotoLastPage){
		try{
			if(gotoLastPage){
				String sQuery = getQuery(iOffset, sSortField, sSortOrder, sSearchText, gotoLastPage, 0);
				Integer iSize = Database.countQuery(sQuery);
				CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
				Integer iChunkSize = Integer.valueOf(objSettings.WL_App_List_Page_Size__c * objSettings.WL_App_List_Pages_Per_Screen__c);
				if(iSize > iChunkSize){
					iOffset = iSize - math.mod(iSize, iChunkSize);
					if(iOffset == iSize)
						iOffset = iSize - iChunkSize;
				}
			}
			List<MyApp> lstApps = getMyAppList(iOffset, sSortField, sSortOrder, sSearchText);
			if(lstApps.size() > 0)
				return JSON.serialize(new CC_ResponseWrapper(true, '{"lstApps":' + JSON.serialize(lstApps) + ',"iListSize":' + lstApps.size() + ',"iOffset":' + iOffset + '}'));
			else
				return JSON.serialize(new CC_ResponseWrapper(true, '{"lstApps":[],"iListSize":0,"iOffset":' + iOffset + '}'));
		}catch(Exception ex){
			//throw error no such field exists
            System.debug('Exception on Class : CC_ApplicationComponentController - getMyAppListAsString, Error : ' +
                ex.getMessage() +
                ' Line Number : ' +
                ex.getLineNumber() +
                ' Cause : ' +
                ex.getCause() +
                ' Type : ' +
                ex.getTypeName());
	        return JSON.serialize(new CC_ResponseWrapper(false, NULL, new List<String>{System.Label.DT_LABEL_CONTACT_ADMIN}));
	    }
	}
	
	/* METHOD NAME   : getMyAppList
	 * DESCRIPTION  : Returns all the tasks in his queue and owned by him
	 *
	 * RETURN TYPE   : queue name
	 * PARAMETER   : TaskList        
	 */
	@AuraEnabled
	public static List<MyApp> getMyAppList(Integer iOffset, String sSortField, String sSortOrder, String sSearchText){
		List<MyApp> lstApps = new List<MyApp>();
		CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
		Integer iLimit = Integer.valueOf((objSettings.WL_App_List_Page_Size__c * objSettings.WL_App_List_Pages_Per_Screen__c) + 1);
		String sQuery = getQuery(iOffset, sSortField, sSortOrder, sSearchText, false, iLimit);
		for(CC_Application_Detail__c objAppDetail : Database.query(sQuery)){
			MyApp myApp = new MyApp();
            myApp.sRecordId = objAppDetail.Id;
            myApp.sAppId = objAppDetail.Related_Application__c;
			myApp.sAppNumber = objAppDetail.Related_Application__r.Name;
			myApp.sWLProgramId = objAppDetail.Waiting_List_Program__c;
			myApp.sWLProgramName = objAppDetail.Waiting_List_Program__r.Name;
			if(String.isNotBlank(objAppDetail.Related_Application__r.CC_Individual__c)){
				myApp.sIndividualId = objAppDetail.Related_Application__r.CC_Individual__c;
				myApp.sIndividualName = objAppDetail.Related_Application__r.CC_Individual__r.LastName + ', ' + objAppDetail.Related_Application__r.CC_Individual__r.FirstName;
			}
			//myApp.sInitiatedDate = objTask.DT_Received_Date__c == NULL? '' : objTask.DT_Received_Date__c.format();
			myApp.sCreatedDate = objAppDetail.CreatedDate.format(CC_Constants.CC_OUTPUT_DATE_FORMAT);
			myApp.sAction = System.Label.CC_CONTINUE;
			lstApps.add(myApp);
		}
		System.debug('lstApps>>' + lstApps);
		return lstApps;
	}
	
	/* METHOD NAME   : getQuery
	 * DESCRIPTION  : return the query
	 *
	 * RETURN TYPE   : query
	 * PARAMETER   : boolean        
	 */
	@AuraEnabled
	public static String getQuery(Integer iOffset, String sSortField, String sSortOrder, String sSearchText, Boolean gotoLastPage, Integer iLimit){
		String sFieldSet = '', sOwnerId = '\'' + UserInfo.getUserId() + '\'';
		if(gotoLastPage)
			sFieldSet = ' count() ';
		else
			sFieldSet = 'Id, Related_Application__c, ' +
						'Related_Application__r.Name, ' +
						'Waiting_List_Program__c, ' +
						'Waiting_List_Program__r.Name, ' +
						'Related_Application__r.CC_Individual__c, ' +
						'Related_Application__r.CC_Individual__r.FirstName, ' + 
						'Related_Application__r.CC_Individual__r.LastName, ' +
        				'CreatedDate ';
		//system.debug(sFieldSet);
		String sQuery = 'SELECT ' + sFieldSet +
							'FROM CC_Application_Detail__c ' +
							'WHERE ' +  
							'Status__c = \'' + System.Label.CC_PGM_STATUS_WAITLISTED + '\' ' + 
							'AND RecordTypeId = \'' + CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, CC_Constants.CC_RECORD_TYPE_WAIVER_PROGRAMS) + '\' ';
			
		if(String.isNotBlank(sSearchText))
			sQuery += ' AND (' +
						'(Waiting_List_Program__r.Name LIKE \'%' + sSearchText +'%\') OR ' +
						'(Related_Application__r.Name LIKE \'%' + sSearchText +'%\') OR ' +
						'(Related_Application__r.CC_Individual__r.Name LIKE \'%' + sSearchText +'%\')' +
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
		mapLabelAndError.put('CC_CONTINUE', System.Label.CC_CONTINUE);
		mapLabelAndError.put('CC_SEARCH', System.Label.CC_SEARCH);
		mapLabelAndError.put('CC_NO_APPLICATION', System.Label.CC_NO_APPLICATION);
		mapLabelAndError.put('CC_SITE_NAME_SELF_SERVICE', System.Label.CC_SITE_NAME_SELF_SERVICE);
		mapLabelAndError.put('CC_SITE_NAME_SERVICE_PROVIDER', System.Label.CC_SITE_NAME_SERVICE_PROVIDER);
		mapLabelAndError.put('DT_LABEL_CONTACT_ADMIN', System.Label.DT_LABEL_CONTACT_ADMIN);
        mapLabelAndError.put('CC_ApplicationIntake',System.Label.CC_ApplicationIntake);
		mapLabelAndError.put('MY_USER_ID', UserInfo.getUserId());

		return mapLabelAndError;
	}
	
	/* METHOD NAME   : getColumnHeaders
	 * DESCRIPTION  : load the column headers for the table
	 *
	 * RETURN TYPE   : 
	 * PARAMETER   :         
	 */
	@TestVisible
	private static List<String> getColumnHeaders() {
		List<String> lstColumnHeaders = new List<String>();
		lstColumnHeaders.add(System.Label.CC_APP_NUMBER);
		lstColumnHeaders.add(System.Label.CC_INDIVIDUAL_NAME);
		lstColumnHeaders.add(System.Label.CC_Label_Program_Name);
		lstColumnHeaders.add(System.Label.CC_ACTION);
		return lstColumnHeaders;
	}
}