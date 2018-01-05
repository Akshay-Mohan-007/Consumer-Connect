/* Class Name   : DT_TaskAssignment
 * Description  : Task framework response type
 *  
 *  
 * Created By   : Nidhin V K
 * Created On   : 11-17-2017
 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date        Modification ID      Description 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K            11-17-2017        1000            Initial version
 *
 */
public with sharing class DT_TaskResponseWrapper {
    public Boolean success;
    public DT_Task__c response;
    public String message;
}