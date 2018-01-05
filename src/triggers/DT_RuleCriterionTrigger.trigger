/* Trigger Name   : DT_RuleCriterionTrigger
 * Description  :    
 * Created By   : Nidhin V K
 * Created On   : 07-26-2016

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date        Modification ID      Description 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K            07-26-2016        1000            Initial version
 * Debalina
 *
 */
trigger DT_RuleCriterionTrigger on DT_Rule_Criterion__c (before delete,before insert,before update) {
    if(trigger.isBefore) {
        if(trigger.isDelete){
            /*Call DT_RuleCriterionTriggerHandler.beforeDelete to check the following:
             *Prevent users from deleting rule criteria if rule or rule version is active
             */
            DT_RuleCriterionTriggerHandler.beforeDelete(trigger.oldMap);
        }
    }
}