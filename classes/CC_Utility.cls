/***************************************************************************************************************************************
 * NAME   : CC_Utility
 * DESCRIPTION  : All Utility methods.
 *    
 * @AUTHOR   : Nidhin V K
 * @DATE   : 10-27-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               10-27-2017          Initial version        
 * Debalina                 10-27-2017          Added Methods
 * Akshay                   13-Nov-2017         Added method getExternalUsersForSharing
 * Akshay                   17-Nov-2017         Added method to delete objects for without sharing 
 * Akshay                   20-Nov-2017         Added method get Picklist value from List of String
 * Debalina                 22-Nov-2017         setTabName
 * Akshay                   27-Nov-2017         Added method for checking latest date time
 * Nidhin V K               06-Dec-2017         Added method to close prev in progress task 
 * Nidhin V K               07-Dec-2017         postFeedItem  
 * Nidhin V K               12-Dec-2017         removed a method close prev task  
 * Sourav Ghosh             18-Dec-2017         Adding getContainerSite method
 ****************************************************************************************************************************************/
//Akshay[17-Nov-2017] made without sharing to delete objects for portal users
public without sharing class CC_Utility {

    public class NotPicklistFieldException extends Exception {}

    
    /* getFieldMap 
    * Returns a map of fields of an object
    * @params : sObjectAPIName, a string representing the API name of an object
    * @return : a map of object fields
    */
    
    public static map<String, Schema.SObjectField> getFieldMap(String sObjectAPIName){
                
        //From the Object Api name retrieving the SObject
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectAPIName);
        Sobject objectName = targetType.newSObject();
        //grab the sobject that was passed
        Schema.sObjectType objectType = objectName.getSObjectType(); 
        //describe the sobject
        Schema.DescribeSObjectResult sobjectDescribe = objectType.getDescribe(); 
        //get a map of fields for the passed sobject
        map<String, Schema.SObjectField> mapField = sobjectDescribe.fields.getMap(); 
      
        return mapField;
    }

    /* getPicklistValuesFromFieldMap 
    * Gets the picklist values of a picklist field
    * @params : mapField, a map of object fields
    * @params : sFieldName, name of the picklist field
    * @return : a list of the picklist values
    */
    
    public static list<String> getPicklistValuesFromFieldMap(map<String, Schema.SObjectField> mapField, String sFieldName){
        list<String> lstPickvals = new list<String>();
        Schema.DescribeFieldResult field = mapField.get(sFieldName).getDescribe();
 
        try{

            if(field.getType() == Schema.DisplayType.Picklist){
                list<Schema.PicklistEntry> lstPickListValues = mapField.get(sFieldName).getDescribe().getPickListValues(); 
      
                //for all values in the picklist list
                for (Schema.PicklistEntry a : lstPickListValues) {
                    //add the value  to our final list 
                    lstPickvals.add(a.getValue());
                }
            }else
                throw new NotPicklistFieldException(sFieldName+' Field is not of Picklist Type');
        }catch(NotPicklistFieldException ex) {

            System.debug('Exception on Class : CC_Utility - getPicklistValuesFromFieldMap, Error : ' +
            ex.getMessage() +
            ' Line Number : ' +
            ex.getLineNumber() +
            ' Cause : ' +
            ex.getCause() +
            ' Type : ' +
            ex.getTypeName());

        }catch(Exception ex) {
            System.debug('Exception on Class : CC_Utility - getPicklistValuesFromFieldMap, Error : ' +
            ex.getMessage() +
            ' Line Number : ' +
            ex.getLineNumber() +
            ' Cause : ' +
            ex.getCause() +
            ' Type : ' +
            ex.getTypeName());
        }


        //grab the list of picklist values for the passed field on the sobject
        return lstPickvals;
    }

     public static Id getRecordTypeId(String sObjName, String sRecordTypeName){
        Id recTypeId;
        if(sObjName != null && sRecordTypeName != null){
            recTypeId= Schema.getGlobalDescribe().get(sObjName).getDescribe().getRecordTypeInfosByName().get(sRecordTypeName).getRecordTypeId();
        }  
        return recTypeId;  
    }

    public static String getCurrentUserLicense(){
        User userObj = [SELECT Profile.UserLicense.Name,Id FROM User WHERE Id =: UserInfo.getUserId()];
        return userObj.Profile.UserLicense.Name;
    }

    /* getPicklistValuesWrapper 
    * Gets the picklist values of a picklist field
    * @params : sObjectAPIName, Object API Name
    * @params : sFieldName, name of the picklist field
    * @params : sSelectLabel, select label of the picklist field
    * @return : a list of the picklist values
    */
    public static List<CC_PickListValue_Wrapper> getPicklistValuesWrapper(String sObjectAPIName, String sFieldName,String sSelectLabel){ 
        Map<String, Schema.SObjectField> mapField = getFieldMap(sObjectAPIName);
        
        return getPicklistValuesWrapper(mapField,sFieldName,sSelectLabel);
    }

    /* getPicklistValuesWrapper 
    * Gets the picklist values of a picklist field
    * @params : mapField, a map of object fields
    * @params : sFieldName, name of the picklist field
    * @params : sSelectLabel, select label of the picklist field
    * @return : a list of the picklist values
    */
    public static List<CC_PickListValue_Wrapper> getPicklistValuesWrapper(Map<String, Schema.SObjectField> mapField, String sFieldName,
                                                                            String sSelectLabel){ 
        Schema.DescribeFieldResult field = mapField.get(sFieldName).getDescribe();
        List<CC_PickListValue_Wrapper> lstPickvals = new List<CC_PickListValue_Wrapper>();
        try{

            if(field.getType() == Schema.DisplayType.Picklist){
                list<Schema.PicklistEntry> lstPickListValues = mapField.get(sFieldName).getDescribe().getPickListValues(); 
                lstPickvals.add(new CC_PickListValue_Wrapper(null, sSelectLabel));
                //for all values in the picklist list
                for (Schema.PicklistEntry a : lstPickListValues) 
                    //add the value  to our final list 
                    lstPickvals.add(new CC_PickListValue_Wrapper(a.getValue(), a.getLabel()));
                
            }else
                throw new NotPicklistFieldException(sFieldName+' Field is not of Picklist Type');
        }catch(Exception ex) {

            System.debug('Exception on Class : CC_Utility - getPicklistValuesWrapper, Error : ' +
            ex.getMessage() +
            ' Line Number : ' +
            ex.getLineNumber() +
            ' Cause : ' +
            ex.getCause() +
            ' Type : ' +
            ex.getTypeName());
            throw ex;
        }
        System.debug('lstPickvals: ' + lstPickvals);
        return lstPickvals;
    }
    /* getPicklistValuesWrapper 
    * Gets the picklist values from a string list
    * @params : sSelectLabel, select label of the drop down select
    * @params : lstValues, List of strings
    * 
    * @return : a list of the picklist values
    */
    public static List<CC_PickListValue_Wrapper> getPicklistValuesWrapper(String sSelectLabel,List<String> lstValues){ 
        List<CC_PickListValue_Wrapper> lstPickvals = new List<CC_PickListValue_Wrapper>();
        lstPickvals.add(new CC_PickListValue_Wrapper(null, sSelectLabel));
        //for all values in the picklist list
        for (String sValue : lstValues) 
            //add the value  to our final list 
            lstPickvals.add(new CC_PickListValue_Wrapper(sValue));
            
        System.debug('lstPickvals: ' + lstPickvals);
        return lstPickvals;
    }
    /*********************************************** Start of Code for Dependent Picklist ************************************************/
    /* getDependentOptions 
    * Gets the dependent picklist values of a controlling picklist field
    * @params : sObjName,name of the Object
    * @params : sControllingField, name of the controlling picklist field
    * @params : sDependentField, name of the dependent picklist field
    * @return : a list of the picklist values
    */
    public static List<Integer> B64ToBytes (String sIn) {
        Map<Integer,Integer> base64 = new Map<Integer,Integer>{65=>0,66=>1,67=>2,68=>3,69=>4,70=>5,71=>6,72=>7,73=>8,74=>9,75=>10,76=>11,77=>12,78=>13,79=>14,80=>15,81=>16,82=>17,83=>18,84=>19,85=>20,86=>21,87=>22,88=>23,89=>24,90=>25
                                                               ,97=>26,98=>27,99=>28,100=>29,101=>30,102=>31,103=>32,104=>33,105=>34,106=>35,107=>36,108=>37,109=>38,110=>39,111=>40,112=>41,113=>42,114=>43,115=>44,116=>45,117=>46,118=>47,119=>48,120=>49,121=>50,122=>51
                                                               ,48=>52,49=>53,50=>54,51=>55,52=>56,53=>57,54=>58,55=>59,56=>60,57=>61,43=>62,47=>63};
    
        List<Integer> lstOut = new List<Integer>();
        if ( sIn == null || sIn == '' ) return lstOut;
        
        sIn += '='.repeat( 4 - Math.mod( sIn.length(), 4) );
    
        for ( Integer idx=0; idx < sIn.length(); idx += 4 ) {
            if ( base64.get(sIn.charAt(idx+1)) != null ) lstOut.add( (base64.get(sIn.charAt(idx)) << 2) | (base64.get(sIn.charAt(idx+1)) >>> 4) );
            if ( base64.get(sIn.charAt(idx+2)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+1)) & 15)<<4) | (base64.get(sIn.charAt(idx+2)) >>> 2) );
            if ( base64.get(sIn.charAt(idx+3)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+2)) & 3)<<6) | base64.get(sIn.charAt(idx+3)) );
        }
    
        //System.Debug('B64ToBytes: [' + sIn + '] = ' + lstOut);
        return lstOut;
    }// B64ToBytes

    public static List<Integer> BlobToBytes(Blob input) {
        return B64ToBytes(EncodingUtil.base64Encode(input));
    }// BlobToBytes

    // Converts a base64 string into a list of integers indicating at which
    // position the bits are on
    public static List<Integer> cnvBits(String b64Str) {
        List<Integer>lstOut=new List<Integer>();if(b64Str==null||b64Str=='')return lstOut;

        List<Integer>lstBytes=B64ToBytes(b64Str);

        Integer i,b,v;for(i=0;i<lstBytes.size();i++){v=lstBytes[i];
        // System.debug ( 'i['+i+'] v['+v+']' );
        for(b=1;b<=8;b++){
        // System.debug ( 'i['+i+'] b['+b+'] v['+v+'] = ['+(v & 128)+']' );
        if((v&128)==128)lstOut.add((i*8)+b);v<<=1;}}

        // System.Debug('cnvBits: [' + b64Str + '] = ' + lstOut);
        return lstOut;
    }// cnvBits

    public class TPicklistEntry {
    public string active
        {get;set;}
    public string defaultValue
        {get;set;}
    public string label
        {get;set;}
    public string value
        {get;set;}
    public string validFor
        {get;set;}

        public TPicklistEntry() {
        }
    }// TPicklistEntry

    public static Map<String,List<CC_PickListValue_Wrapper>> getDependentPicklistValues(String pObjName, String pControllingFieldName, String pDependentFieldName,String sSelectLabel) {
        Map<String,List<CC_PickListValue_Wrapper>> mapResults = new Map<String,List<CC_PickListValue_Wrapper>>();
        CC_PickListValue_Wrapper plw;
        List<CC_PickListValue_Wrapper> lstPicklistWrapper;
        
    
        //verify/get object schema
        Schema.SObjectType pType = Schema.getGlobalDescribe().get(pObjName);
        if ( pType == null ) return mapResults;
        Map<String, Schema.SObjectField> objFieldMap = pType.getDescribe().fields.getMap();
    
        //verify field names
        if (!objFieldMap.containsKey(pControllingFieldName) || !objFieldMap.containsKey(pDependentFieldName)) return mapResults;     
    
        //get the control & dependent values   
        List<Schema.PicklistEntry> ctrl_ple = objFieldMap.get(pControllingFieldName).getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> dep_ple = objFieldMap.get(pDependentFieldName).getDescribe().getPicklistValues();
    
        //clear heap
        objFieldMap = null;
    
        //initialize results mapping
        for(Integer pControllingIndex=0; pControllingIndex<ctrl_ple.size(); pControllingIndex++){         
            lstPicklistWrapper = new List<CC_PickListValue_Wrapper>();
            lstPicklistWrapper.add(new CC_PickListValue_Wrapper(null,sSelectLabel));
            mapResults.put( ctrl_ple[pControllingIndex].getLabel(), lstPicklistWrapper);
        }
        //cater for null and empty
        //mapResults.put('', new List<CC_PickListValue_Wrapper>());
        //mapResults.put(null, new List<CC_PickListValue_Wrapper>());
    
        //serialize dep entries        
        List<TPicklistEntry> objDS_Entries = new List<TPicklistEntry>();
        objDS_Entries = (List<TPicklistEntry>)JSON.deserialize(JSON.serialize(dep_ple), List<TPicklistEntry>.class);
    
        List<Integer> validIndexes;
        
        for (TPicklistEntry objDepPLE : objDS_Entries){
    
            validIndexes = cnvBits(objDepPLE.validFor);
            //System.Debug('cnvBits: [' + objDepPLE.label + '] = ' + validIndexes);
    
            for (Integer validIndex : validIndexes){
                
                plw=new CC_PickListValue_Wrapper(objDepPLE.label);
                mapResults.get(ctrl_ple[validIndex-1].getLabel()).add(plw);
                
            }
        }
    
        //clear heap
        objDS_Entries = null;
        System.debug('mapResults1--->' +mapResults.get('New Hampshire'));
        System.debug('mapResults2--->' +mapResults.get('Pennsylvania'));
        return mapResults;
    }
    /*********************************************** End of Code for Dependent Picklist ************************************************/
    
    /* METHOD NAME   : getAllFieldsQuery 
     * DESCRIPTION  : return the query to return all fields in the specified object
     *
     * RETURN TYPE   : String query
     * PARAMETER   : object Name        
     */
    @AuraEnabled
    public static String getAllFieldsQuery(String sObjectAPIName){
        List<String> lstObjectFields = new List<String>();
        lstObjectFields.addAll(Schema.getGlobalDescribe().get(sObjectAPIName).getDescribe().fields.getMap().keySet());
        String sAllFieldsQuery = 'SELECT ' + lstObjectFields.get(0);
                for (Integer i = 1; i < lstObjectFields.size(); i++) {
                    sAllFieldsQuery += ', ' + lstObjectFields.get(i);
                }
                sAllFieldsQuery += ' FROM ' + sObjectAPIName + ' ';
            
            System.debug('sAllFieldsQuery : ' + sAllFieldsQuery);
        return sAllFieldsQuery;
    }
    
    /* METHOD NAME   : getQueueInfo 
     * DESCRIPTION  : get Queue Info using developer name
     *
     * RETURN TYPE   : Group
     * PARAMETER   : sQueueDevName        
     */
    public static Group getQueueInfo(String sQueueDevName){
        return [SELECT
                    Id, Name, DeveloperName
                FROM
                    Group
                WHERE
                    DeveloperName = :sQueueDevName];
    }

    /* METHOD NAME   : getExternalUsersForSharing 
     * DESCRIPTION  : Load all the suers who are eligible for apex sharing
     *
     * RETURN TYPE   : Set<ID>
     * 
     */
    public static Set<ID> getExternalUsersForSharing(){
        List<String> lstCCPlusProfilesToShare = new List<String>();
        lstCCPlusProfilesToShare.add(CC_Constants.CC_CASE_MANAGER_PROFILE);
        lstCCPlusProfilesToShare.add(CC_Constants.CC_CASE_SUPERVISOR_PROFILE);
        Map<ID,User> mapUsers = new Map<ID,User>([SELECT ID,Name FROM User WHERE Profile.NAME IN :lstCCPlusProfilesToShare]);
        System.debug('mapUsers: ' + mapUsers);
        return mapUsers.keySet();
    }
    
    /* METHOD NAME   : deleteRecords 
     * DESCRIPTION  : Delete records without sharing. TO BE USED ONLY AS LAST RESORT WHEN NO OTHER OPTION EXISTS
     * 
     * RETURN TYPE   : void
     * PARAMETER   : List<sObject> 
     */
    public static void deleteRecords(List<sObject> setObjects){
        System.debug('Deleting: ' + setObjects);
        delete setObjects;
    }
    /* METHOD NAME   : updateRecords 
     * DESCRIPTION  : update records without sharing. TO BE USED ONLY AS LAST RESORT WHEN NO OTHER OPTION EXISTS
     * 
     * RETURN TYPE   : void
     * PARAMETER   : List<sObject> 
     */
    public static void updateRecords(List<sObject> setObjects){
        System.debug('updating: ' + setObjects);
        update setObjects;
    }
    /* METHOD NAME   : insertRecords 
     * DESCRIPTION  : insert records without sharing. TO BE USED ONLY AS LAST RESORT WHEN NO OTHER OPTION EXISTS
     * 
     * RETURN TYPE   : void
     * PARAMETER   : List<sObject> 
     */
    public static void insertRecords(List<sObject> setObjects){
        System.debug('insert: ' + setObjects);
        insert setObjects;
    }

    public static String setTabName(String sTabName,String sVisitedPages){
        String sValue = '';
       
        System.debug('sVisitedPages: ' + sVisitedPages);

        if(String.isNotBlank(sVisitedPages)) {
            Set<String> setValues = new Set<String>();
            setValues.addAll(sVisitedPages.split(';'));
            System.debug('setValues: ' + setValues);
            if(setValues.contains(sTabName)) {
                sValue = sVisitedPages;
            }else {
                sValue = sVisitedPages +';'+sTabName;
            }
        }
        else
            sValue = sTabName;

        System.debug('sValue-->'+sValue);
        return sValue;
    }

    /* isLatest 
    * checks if new date is more recent than old date
    * @params : dtOld, Old date time
    * @params : dtNew, new date time
    * 
    * @return : boolean true if old date less than new date,
    */
    public static Boolean isLatest(DateTime dtOld, DateTime dtNew){
        if(dtOld==null)
            return true;
        System.debug('dtNew: ' + dtNew.getTime());
        System.debug('dtOld: ' + dtOld.getTime());
        if(dtNew.getTime() > dtOld.getTime())
            return true;
        return false;
    }

    /* formatDateTime 
    * Formats Date Time for display
    * @params : dtDate, Date Time value
    * 
    * @return : Formatted string
    */
    public static String formatDateTime(DateTime dtDate){
        if(dtDate == null)
            return CC_Constants.CC_NO_DATA;
        else
            return dtDate.format(CC_Constants.CC_OUTPUT_DATE_FORMAT);
        
    }
    
    /* closePrevTask 
    * Close prev Task in in progress status
    * @params : sMasterRecordId
    * 
    * @return :
    */
    public static void closePrevTask(String sMasterRecordId){
        List<DT_Task__c> lstTaskToUpdate = new List<DT_Task__c>();
      
      List<DT_Task__c> lstPrevTasks = [SELECT Id, CreatedById FROM DT_Task__c WHERE DT_Master_Record_Id__c = :sMasterRecordId AND DT_Status__c = :DT_Constants.DT_TASK_STATUS_IN_PROGRESS LIMIT 1];
    if(lstPrevTasks.size() > 0){
      lstPrevTasks[0].DT_Status__c = DT_Constants.DT_TASK_STATUS_COMPLETE;
      lstTaskToUpdate.add(lstPrevTasks[0]);
      upsert lstTaskToUpdate;
    }
      System.debug('Tasks updated>>' + lstTaskToUpdate); 
    }
    
    /* METHOD NAME   : postChatterFeed
     * DESCRIPTION  : post Chatter Feed on submit
     *
     * RETURN TYPE   : 
     * PARAMETER   :         
     */
    public static void postNotificationFeed(String sParentUserId, String sNetworkId, String sFeed){
        FeedItem post = new FeedItem();
        post.ParentId = sParentUserId;//'00518000001gBAp';//00518000001gGMg
        post.Body = sFeed;
        post.visibility = 'AllUsers';
        post.NetworkScope = sNetworkId;//'0DB1800000000O8';//0DB1800000000ON
        insert post;
        System.debug('post>>' + post);
    }

    /* METHOD NAME   : getContainerSite
     * DESCRIPTION  : To get the home page URL based on the module
     *
     * RETURN TYPE   : String
     * PARAMETER   : CC_Module__mdt object
     */
    public static String getContainerSite(CC_Module__mdt objModule){
        String sSiteName = Site.getName(), sHomePageURL, sCurrentTheme = UserInfo.getUiTheme(); 
        if((String.isBlank(sSiteName) && sCurrentTheme == CC_Constants.CC_DESKTOP_THEME_TYPE)
            || (String.isBlank(sSiteName) && Test.isRunningTest()))
            sHomePageURL = objModule.Home_Page_Redirection_Internal_User__c;
        else if(String.isBlank(sSiteName) && sCurrentTheme == CC_Constants.CC_MOBILE_THEME_TYPE)
            sHomePageURL = objModule.Home_Page_Redirection_App_User__c;  
        else if(sSiteName.equals(System.Label.CC_SITE_NAME_SERVICE_PROVIDER))
            sHomePageURL = objModule.Home_Page_Redirection_Svc_Provider_User__c;
        else if(sSiteName.equals(System.Label.CC_SITE_NAME_SELF_SERVICE))
            sHomePageURL = objModule.Home_Page_Redirection_Self_Service_User__c;

        return sHomePageURL;
    }
}