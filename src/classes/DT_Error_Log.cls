/* Class Name   : DT_Error_Log
 * Description  : This is a generic class created to handle exception in case of Integration and application scenarios
                  This provides different methods to handle the error logging. Create error record/log attachments against it     
 * Created By   : Murali Raghavan 
 * Created On   : 08-05-2015

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date                   Modification ID      Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Murali Raghavan        08-05-2015                    1000           Initial version
 */


public with sharing class DT_Error_Log {


    /************************************************************************************************************************
     *Method Name : BusinessException
     *Description : This method is used to capture business exceptions or DML exceptions. It accepts the error and the
     *             error description as input
     *Parameter   : Input are multiple fields related to the error object creation
     *Return type : error object id to further add attachments under it
     *************************************************************************************************************************/
    public static String BusinessException(String sErrorName, String sErrorType,  String sErrorMessage, String sErrorDesc,
            String sClassName, String sClassMethod,
            String sObjectId, String sURL) {
        // Creating an error log record
        DT_Error_Log__c ErrorObj = new DT_Error_Log__c();
        ErrorObj.DT_Class_Name__c = sClassName;
        ErrorObj.DT_Class_Method__c = sClassMethod;

        ErrorObj.DT_Error_Type__c = sErrorType;

        // If error message length is more than 254, trim it
        if (sErrorMessage.length() > 254)
            ErrorObj.DT_Error_Message__c = sErrorMessage.substring(0, 254);
        else
            ErrorObj.DT_Error_Message__c = sErrorMessage;

        // If error description length is more than 32767, trim it    
        if(sErrorDesc.length() > 32767)
            ErrorObj.DT_Message__c = sErrorDesc.substring(0,32767);
        else ErrorObj.DT_Message__c = sErrorDesc;

        // If error type length is more than 39, trim it 
        if (sErrorType.length() > 39)
            ErrorObj.DT_Exception_Type__c = sErrorType.substring(0, 39);
        else
            ErrorObj.DT_Exception_Type__c = sErrorType;

        // If object id length is more than 99, trim it 
        if (sObjectId != null && sObjectId.length() > 99)
            ErrorObj.DT_Object_Id__c  = sObjectId.substring(0, 99);
        else
            ErrorObj.DT_Object_Id__c  = sObjectId;

        ErrorObj.DT_Source_URL__c = sURL;

        // If error name length is more than 79, trim it 
        if (sErrorName.length() > 79)
            ErrorObj.Name = sErrorName.substring(0, 79);
        else
            ErrorObj.Name = sErrorName;

        // Inserting the error log record    
        insert ErrorObj;
        System.debug('ErrorObj==' + ErrorObj);

        // Returning the id of newly inserted record
        return ErrorObj.Id;
    }


    /************************************************************************************************************************
     * Method Name : genericException
     * Description : This method is used to capture generic exceptions. It accepts the exception object as input
     * Parameter   : Input are multiple fields related to the error object creation with exception
     * Return type : error object id to further add attachments under it
     *************************************************************************************************************************/
    public static String genericException(String sErrorName, String sErrorType,  Exception e,
            String sClassName, String sClassMethod,
            String sObjectId, String sURL) {

        // Creating an error log record                                     
        DT_Error_Log__c objErrorLog = new DT_Error_Log__c();
        objErrorLog.DT_Class_Name__c = sClassName;
        objErrorLog.DT_Class_Method__c = sClassMethod;

        objErrorLog.DT_Error_Type__c = sErrorType;

        // If the exception value is null
        if (e == null) {
            objErrorLog.DT_Error_Message__c  = 'No Exception';
            objErrorLog.DT_Message__c = 'No Exception';
            objErrorLog.DT_Exception_Type__c = 'No Exception';
        } else {
            String sErrMsg = e.getTypeName() + '++Message: ' + e.getMessage();

            // If error message length is more than 254, trim it
            if (sErrMsg.length() > 254)
                objErrorLog.DT_Error_Message__c = sErrMsg.substring(0, 254);
            else
                objErrorLog.DT_Error_Message__c = sErrMsg;

            objErrorLog.DT_Message__c = e.getStackTraceString();

            // If error type length is more than 39, trim it 
            if (e.getTypeName().length() > 39)
                objErrorLog.DT_Exception_Type__c = e.getTypeName().substring(0, 39);
            else
                objErrorLog.DT_Exception_Type__c = e.getTypeName();
        }

        // If object id length is more than 99, trim it 
        if (sObjectId != null && sObjectId.length() > 99)
            objErrorLog.DT_Object_Id__c  = sObjectId.substring(0, 99);
        else
            objErrorLog.DT_Object_Id__c  = sObjectId;

        objErrorLog.DT_Source_URL__c = sURL;

        // If error name length is more than 79, trim it 
        if (sErrorName.length() > 79)
            objErrorLog.Name = sErrorName.substring(0, 79);
        else
            objErrorLog.Name = sErrorName;

        // Inserting the error log record    
        insert objErrorLog;
        System.debug('ErrorObj==' + objErrorLog);

        // Returning the error log record's id
        return objErrorLog.Id;
    }


    /************************************************************************************************************************
     * Method Name : LogDMLerrors
     * Description : This method is used to capture DML exceptions in case of upsert or save. It accepts the Database result
     *               object as input. It adds the list of exceptions into a string and creates an attachment under the error Object,
     * Parameter   : Error record Id, Database Result
     * Return type : no return data
     *************************************************************************************************************************/
    public static void LogDMLerrors(String sErrorId, List<Database.SaveResult> lstSaveResult, List<Database.UpsertResult> lstUpsertResult) {
        string sErrorMsg = '';
        if (lstSaveResult != null) {
            for (Integer iCounter = 0; iCounter < lstSaveResult.size(); iCounter++) {
                Database.SaveResult objSaveResult = lstSaveResult[iCounter];

                system.debug('result===============' + objSaveResult);
                system.debug('result===============' + objSaveResult.getErrors());
                system.debug('result===============' + objSaveResult.isSuccess());

                // If the result of database operation is not successful
                if (!objSaveResult.isSuccess() ) {
                    for (Database.Error objErr : objSaveResult.getErrors()) {
                        sErrorMsg += sErrorMsg;
                        System.debug('The following error has occurred.');
                        System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        System.debug('Fields that affected this error: ' + objErr.getFields());
                        sErrorMsg = iCounter + ' ' + objErr.getMessage();
                        sErrorMsg = sErrorMsg + '++++++\n Error Fields that caused exception:\n' + objErr.getFields() + '\n+++++++++';
                    }
                }
            }
        }

        if (lstUpsertResult != null) {

            for (Integer iCounter = 0; iCounter < lstUpsertResult.size(); iCounter++) {

                Database.UpsertResult objUpsertResult = lstUpsertResult[iCounter];

                system.debug('result===============' + objUpsertResult);
                system.debug('result===============' + objUpsertResult.getErrors());
                system.debug('result===============' + objUpsertResult.isSuccess());

                if (!objUpsertResult.isSuccess() ) {
                    for (Database.Error objErr : objUpsertResult.getErrors()) {
                        sErrorMsg += sErrorMsg;
                        System.debug('The following error has occurred.');
                        System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                        System.debug('Fields that affected this error: ' + objErr.getFields());
                        sErrorMsg = iCounter + ' ' + objErr.getMessage();
                        sErrorMsg = sErrorMsg + '++++++\n Error Fields that caused exception:\n' + objErr.getFields() + '\n+++++++++';
                    }
                }
            }

            DT_Error_Log__c objErrorLog = new DT_Error_Log__c(id = sErrorId, DT_Message__c = sErrorMsg);
            // Updating the record
            update objErrorLog;

            // Inserting the attachment
            InsertAttachment( sErrorId,  'LogDMLerrors', sErrorMsg);
        }
    }


    /************************************************************************************************************************
     * Method Name : InsertAttachment
     * Description : This method is used to creates an attachment under the error Object,
     * Parameter   : Error record Id, filename and the error text
     * Return type : no return data
     *************************************************************************************************************************/
    public static void InsertAttachment(String sErrorId, String sFileName, String sErrorText) {
        Attachment objAttachment = new Attachment();
        objAttachment.Body = Blob.valueOf(sErrorText);
        objAttachment.Name = sFileName + '.txt';
        objAttachment.parentId = sErrorId;

        // Creating the attachment containing the error details
        insert objAttachment;
    }
}