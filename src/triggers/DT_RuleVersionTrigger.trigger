/* Trigger Name : DT_RuleVersionTrigger
 * Description  : Trigger class for Rule Version object to check for validations
 * Created By   : Shibabrata Debnath
 * Created On   : 08-04-2016

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date        Modification ID      Description 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Shibabrata Debnath    08-04-2016            1           Initial version
 * Debalina
 *
 */
trigger DT_RuleVersionTrigger on DT_Rule_Version__c (after update, before delete,before update) {

    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            /*Call DT_RuleVersionTriggerHandler.checkValidations to check the foll:
             *Once a version is activated, update "Active Email Template" and 
             *"Active Queue" on Rule, and deactivate al other versions
             */
            DT_RuleVersionTriggerHandler.checkValidations(Trigger.new, Trigger.oldMap);
        }
    }  
    if(Trigger.isBefore){
        if(Trigger.isDelete){
            /*Call DT_RuleVersionTriggerHandler.preventDeleteIfActive to:
             *Prevent Rule Version to delete is Rule is active
             */
            DT_RuleVersionTriggerHandler.preventDeleteIfActive(Trigger.oldMap);
        }
    }
}