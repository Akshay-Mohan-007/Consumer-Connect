/* Class Name   : DT_ViewRuleListController
 * Description  :    
 * Created By   : Nidhin V K
 * Created On   : 08-04-2016

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date        Modification ID      Description 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K            08-04-2016        1000            Initial version
 * Debalina              10-05-2016        1001            Pagination
 *
 */
public with sharing class DT_ViewRuleListController {

    private Integer limitSize;

    public DT_ViewRuleListController() {
        limitSize = 1000;
    }
    
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) {
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT 
                        Id, 
                        Name, 
                        DT_Target_SObject_API_Name__c, 
                        DT_Rule_Type__c, 
                        DT_Priority__c, 
                        DT_IsActive__c,
                        DT_Active_Queue__c
                    FROM 
                        DT_Rule__c 
                    LIMIT :limitSize ]));

                setcon.setpagesize(20);
            }
            return setCon;
        }
        private set;
    }

    // Initialize setCon and return a list of records
    public List<DT_Rule__c> getRules() {

        setcon.setpagesize(20);
        return (List<DT_Rule__c>) setCon.getRecords();
    }
}