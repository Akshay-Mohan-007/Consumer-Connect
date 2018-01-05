/***************************************************************************************************************************************
 * NAME   : CC_ApplicationsComponentController
 * DESCRIPTION  : Lists all the Applications assigned to the user.
 *    				Before using this make sure that labels 'CC_SITE_NAME_SELF_SERVICE' 'CC_SITE_NAME_SERVICE_PROVIDER' and
 *					custom settings field 'App_Dashboard_Page_Size__c', 'App_Dashboard_Pages_Per_Screen__c' 
 *					in 'CC_Master_Settings__c' are populated correctly
 *    
 * @AUTHOR   : Nidhin V K
 * @DATE   : 11-20-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               11-20-2017          Initial version        
 *
 ****************************************************************************************************************************************/

public with sharing class CC_ApplicationsComponentController {
    
	public class MyApp {
		public String sRecordId;
		public String sAppNumber;
		public String sStatus;
		public String sIndividualId;
		public String sIndividualName;
		public String sInitiatedDate;
		public String sCreatedDate;
	}

	public class ComponentWrapper {
		public Integer iListSize;
		public Integer iPageSize;
		public Integer iPagesPerChunk;
		public List<MyApp> lstMyApps;
		public Map<String, String> mapLabels;
		public String sSiteName;
		public ComponentWrapper() {
			lstMyApps = new List<MyApp>();
			mapLabels = new Map<String, String>();
			CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
			iPageSize = Integer.valueOf(objSettings.App_Dashboard_Page_Size__c);
			iPagesPerChunk = Integer.valueOf(objSettings.App_Dashboard_Pages_Per_Screen__c);
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
			return '{"DashboardInfo":' + JSON.serialize(wrapper) + '}';
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
	        return NULL;
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
				Integer iChunkSize = Integer.valueOf(objSettings.App_Dashboard_Page_Size__c * objSettings.App_Dashboard_Pages_Per_Screen__c);
				if(iSize > iChunkSize){
					iOffset = iSize - math.mod(iSize, iChunkSize);
					if(iOffset == iSize)
						iOffset = iSize - iChunkSize;
				}
			}
			List<MyApp> lstApps = getMyAppList(iOffset, sSortField, sSortOrder, sSearchText);
			if(lstApps.size() > 0)
				return '{"lstApps":' + JSON.serialize(lstApps) + ',"iListSize":' + lstApps.size() + ',"iOffset":' + iOffset + '}';
			else
				return '{"lstApps":[],"iListSize":0,"iOffset":' + iOffset + '}';
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
	        return NULL;
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
		try{
			List<MyApp> lstApps = new List<MyApp>();
			CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
			Integer iLimit = Integer.valueOf((objSettings.App_Dashboard_Page_Size__c * objSettings.App_Dashboard_Pages_Per_Screen__c) + 1);
			String sQuery = getQuery(iOffset, sSortField, sSortOrder, sSearchText, false, iLimit);
			for(CC_Application__c objApp : Database.query(sQuery)){
				MyApp myApp = new MyApp();
				
                myApp.sRecordId = objApp.Id;
				myApp.sAppNumber = objApp.Name;
				myApp.sStatus = objApp.CC_App_Status__c;
				if(String.isNotBlank(objApp.CC_Individual__c)){
					myApp.sIndividualId = objApp.CC_Individual__c;
					myApp.sIndividualName = objApp.CC_Individual__r.LastName + ', ' + objApp.CC_Individual__r.FirstName;
				}
				//myApp.sInitiatedDate = objTask.DT_Received_Date__c == NULL? '' : objTask.DT_Received_Date__c.format();
				myApp.sInitiatedDate = objApp.CreatedDate.format(CC_Constants.CC_OUTPUT_DATE_FORMAT);
				lstApps.add(myApp);
			}
			System.debug('lstApps>>' + lstApps);
			return lstApps;
		}catch(Exception ex){
			//throw error no such field exists
            System.debug('Exception on Class : CC_ApplicationsComponentController - getMyAppList, Error : ' +
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
	public static String getQuery(Integer iOffset, String sSortField, String sSortOrder, String sSearchText, Boolean gotoLastPage, Integer iLimit){
		String sFieldSet = '', sOwnerId = '\'' + UserInfo.getUserId() + '\'';
		if(gotoLastPage)
			sFieldSet = ' count() ';
		else
			sFieldSet = 	'CC_Individual__c, ' +
							'CC_Individual__r.FirstName, CC_Individual__r.LastName, ' + 
							'CC_App_Status__c, ' +
            				'Name, ' +
            				'CreatedDate ';
		//system.debug(sFieldSet);
		String sQuery = 'SELECT ' + sFieldSet +
							'FROM CC_Application__c ' +
							'WHERE ' + 
							'CreatedById = ' + sOwnerId + ' AND ' + 
							'CC_App_Status__c = \'' + System.Label.CC_AppStatus_InProgress + '\' ';
			
		if(String.isNotBlank(sSearchText))
			sQuery += ' AND (' +
						'(Name LIKE \'%' + sSearchText +'%\') OR ' +
						'(CC_Individual__r.Name LIKE \'%' + sSearchText +'%\')' +
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
		mapLabelAndError.put('CC_APP_NUMBER', System.Label.CC_APP_NUMBER);
		mapLabelAndError.put('CC_INDIVIDUAL_NAME', System.Label.CC_INDIVIDUAL_NAME);
		mapLabelAndError.put('CC_LBL_WAIVER_PROGRAM', System.Label.CC_LBL_WAIVER_PROGRAM);
		mapLabelAndError.put('CC_Label_Status', System.Label.CC_Label_Status);
		mapLabelAndError.put('CC_ACTION', System.Label.CC_ACTION);
		mapLabelAndError.put('CC_NO_APPLICATION', System.Label.CC_NO_APPLICATION);
		mapLabelAndError.put('CC_SITE_NAME_SELF_SERVICE', System.Label.CC_SITE_NAME_SELF_SERVICE);
		mapLabelAndError.put('CC_SITE_NAME_SERVICE_PROVIDER', System.Label.CC_SITE_NAME_SERVICE_PROVIDER);
		mapLabelAndError.put('DT_LABEL_CONTACT_ADMIN', System.Label.DT_LABEL_CONTACT_ADMIN);
        mapLabelAndError.put('CC_DATE_INITIATED',System.Label.CC_DATE_INITIATED);
        mapLabelAndError.put('CC_ApplicationIntake',System.Label.CC_ApplicationIntake);
		mapLabelAndError.put('MY_USER_ID', UserInfo.getUserId());

		return mapLabelAndError;
	}
}