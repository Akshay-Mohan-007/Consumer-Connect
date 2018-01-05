/* Class Name   : DT_RuleCriterionTriggerHandler
 * Description  :    
 * Created By   : Nidhin V K
 * Created On   : 07-26-2016

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date        Modification ID      Description 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K            07-26-2016        1000            Initial version
 * Debalina              09-28-2016        1001
 *
 */
public class DT_RuleCriterionTriggerHandler{
    
    /* beforeDelete
     * Block users from doing delete rule criteria operation id rule or rule version is active
     * @params : mapRuleCriteria
     * @return : 
     *
    */
    public static void beforeDelete(Map<Id, DT_Rule_Criterion__c> mapRuleCriteria){
        
        //Get the Rule Details
        for(DT_Rule_Criterion__c criterion : [SELECT 
                                                Id, 
                                                DT_Rule_Version__r.DT_Rule__r.DT_IsActive__c,
                                                DT_Rule_Version__r.DT_IsActive__c,
                                                DT_Rule_Version__r.DT_Deactivated_Date__c
                                              FROM
                                                DT_Rule_Criterion__c
                                              WHERE
                                                Id IN :mapRuleCriteria.keySet()]){
            
            //Check for active rule
            if(criterion.DT_Rule_Version__r.DT_Rule__r.DT_IsActive__c){
                mapRuleCriteria.get(criterion.Id).addError(System.Label.DT_LABEL_DEACTIVATE_RULE);
            
            //Check for active version
            } else if(criterion.DT_Rule_Version__r.DT_IsActive__c
                || criterion.DT_Rule_Version__r.DT_Deactivated_Date__c != NULL){
                mapRuleCriteria.get(criterion.Id).addError(System.Label.DT_LABEL_DEACTIVATE_RULE_VERSION);
            }
        }
    }
}