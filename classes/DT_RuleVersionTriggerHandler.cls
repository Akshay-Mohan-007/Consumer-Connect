/* Class Name   : DT_RuleVersionTriggerHandler
 * Description  : Apex handler class for DT_RuleVersionTrigger trigger    
 * Created By   : Shibabrata Debnath
 * Created On   : 08-04-2016

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date        Modification ID      Description 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Shibabrata Debnath    08-04-2016            1           Initial version
 * Debalina Chatterjee   09-30-2016            2           Expression validation
 *
 */
public class DT_RuleVersionTriggerHandler{
    

    /* checkValidations 
     * Once a version is activated, update "Active Email Template" and "Active Queue" on Rule, and deactivate al other versions
     * @params : lstRuleVer - List of new Rule Versions, mapIdRulVer - Map of old Rule Versions
     * @return : null
     */
    public static void checkValidations(List<DT_Rule_Version__c> lstRuleVer, Map<Id, DT_Rule_Version__c> mapIdRulVer){ 
        
        try{
            DT_Rule_Version__c objOldVer; 
            List<DT_Rule_Version__c> lstUpdateVer = new List<DT_Rule_Version__c>();
            List<DT_Rule_Version__c> lstEligibleVer = new List<DT_Rule_Version__c>(); 
            List<DT_Rule__c> lstRule = new List<DT_Rule__c>();
            Set<Id> setRuleId = new Set<Id>(); 

            for(DT_Rule_Version__c objNewVer : lstRuleVer){
                    objOldVer = mapIdRulVer.get(objNewVer.Id);
                if(objNewVer.DT_IsActive__c == true && objOldVer.DT_IsActive__c == false){ //check if Rule Version is active
                    setRuleId.add(objNewVer.DT_Rule__c);
                    lstEligibleVer.add(objNewVer);                
                }
            }

            lstUpdateVer = [SELECT Id, 
                                   DT_IsActive__c,
                                   DT_Activated_Date__c 
                            FROM 
                                   DT_Rule_Version__c 
                            WHERE 
                                   DT_IsActive__c=true and 
                                   DT_Rule__c IN:setRuleId and 
                                   Id NOT IN :lstEligibleVer];
            
            //Once a version is activated, deactivate all other versions
            if(lstUpdateVer != null && lstUpdateVer.size() > 0){
                for (DT_Rule_Version__c objUver : lstUpdateVer){ 
                    objUver.DT_IsActive__c = false; 
                    if(objUver.DT_Activated_Date__c != NULL){
                        objUver.DT_Deactivated_Date__c = DateTime.now();
                    }
                }
                update lstUpdateVer;
            }
            
            //Get Rule fields to update
            lstRule = [SELECT Id,  
                              DT_Active_Queue__c 
                       FROM 
                              DT_Rule__c 
                       WHERE 
                              Id IN :setRuleId];
            
            //Update Rule's Active Email Template and Active Queue field with Version's fields
            if(lstEligibleVer != null && lstEligibleVer.size() > 0 && lstRule != null && lstRule.size() > 0){             
                for(DT_Rule_Version__c objVer : lstEligibleVer){
                    for(DT_Rule__c objRule : lstRule){       
                        if(objVer.DT_Rule__c == objRule.Id){
                            objRule.DT_Active_Queue__c = objVer.DT_Queue_Name__c;                   
                        }
                    }
                }
                update lstRule;
            }
        }catch(Exception ex){
            //throw error
            String sId = DT_Error_Log.genericException(ex.getMessage(),
                                                       System.Label.DT_ERROR_TYPE_APEX_TRIGGER,
                                                       ex, 
                                                       System.Label.DT_CLASS_RULE_VERSION_TRIGGER_HANDLER, 
                                                       System.Label.DT_METHOD_CHECK_VALIDATIONS, '', '');
            
            return;
        }
    }

    
    /* preventDeleteIfActive 
     * Prevent Rule Version to delete is Rule is active
     * @params : mapIdRulVer - Map of old Rule Versions
     * @return : null
     */
    public static void preventDeleteIfActive(Map<Id, DT_Rule_Version__c> mapIdRulVer){
        
        List<DT_Rule_Version__c> lstRuleVer = new List<DT_Rule_Version__c>();
        lstRuleVer = [SELECT 
                            Id, 
                            DT_IsActive__c,
                            DT_Deactivated_Date__c,
                            DT_Rule__r.DT_IsActive__c 
                     FROM 
                            DT_Rule_Version__c 
                     WHERE 
                            Id IN :mapIdRulVer.keyset()];

        //Throw errors if Rule or Rule Version is Active
        if(lstRuleVer != null && lstRuleVer.size() > 0){
            for(DT_Rule_Version__c objRuleVer : lstRuleVer){
                if(objRuleVer.DT_Rule__r.DT_IsActive__c){ 
                    mapIdRulVer.get(objRuleVer.Id).addError(System.Label.DT_LABEL_DEACTIVATE_RULE);
                }
                else if(objRuleVer.DT_IsActive__c){
                    mapIdRulVer.get(objRuleVer.Id).addError(System.Label.DT_LABEL_DEACTIVATE_RULE_VERSION);
                }
                if(objRuleVer.DT_Deactivated_Date__c != NULL){
                    mapIdRulVer.get(objRuleVer.Id).addError('You cannot delete any older active Rule Versions.');
                }
            }
        }
    }

    /* checkCriteriaLogic 
     * Check criteria logic in rule version has valid syntax
     * @params : lstRuleVer - List of Rule Versions
     * @return : 
     *
    
    public static void checkCriteriaLogic(List<DT_Rule_Version__c> lstRuleVer) {
        
        for(DT_Rule_Version__c rec: lstRuleVer){

            System.debug('<<Criteria id>>'+rec.Id+'<<Value>>'+rec.DT_Criteria_Logic__c);

            if(''.equals(rec.DT_Criteria_Logic__c) || rec.DT_Criteria_Logic__c != null)
            {
               
                if(validateExpression(rec.DT_Criteria_Logic__c))
                {
                    List<DT_Rule_Criterion__c> lstRelatedCriteria = [SELECT Id,DT_Serial_Number__c,DT_Rule_Version__c FROM DT_Rule_Criterion__c 
                                    WHERE RecordType.DeveloperName = 'Compare_Field_Value' AND DT_Rule_Version__c in :lstRuleVer];
                    
                    System.debug('<lstRelatedCriteria>'+lstRelatedCriteria);

                   if(lstRelatedCriteria.size() > 0)
                        {
                            System.debug('Criteria is there');

                            Set<Integer> setSerialNo= new Set<Integer>();
                            for(DT_Rule_Criterion__c criteria: lstRelatedCriteria)
                            {
                                System.debug(criteria.DT_Serial_Number__c);
                                setSerialNo.add(Integer.valueOf(criteria.DT_Serial_Number__c));
                            }

                            Integer maxSerialNo;
                            for(Integer max: setSerialNo){
                                maxSerialNo = max;
                            }
                           
                            System.debug('<<maxSerialNo>>'+maxSerialNo);    

                            //Extract serial Numbers from criteria logic
                            List<String> lstSeialsEntered = extractSerialNumbers(rec.DT_Criteria_Logic__c);

                            for(String serials: lstSeialsEntered)
                            {
                                if(Integer.valueOf(serials) > maxSerialNo || Integer.valueOf(serials) == 0)
                                {
                                    rec.DT_Criteria_Logic__c.addError('Enter valid Serial Number');
                                    System.debug('<<Please Enter valid Serial Number>>');
                                }

                            }
                        }
                    else{
                        rec.DT_Criteria_Logic__c.addError('Please Create Criteria before entering logic');
                        System.debug('<<Please Create Criteria before entering logic>>');
                    } 
                }
                else{
                    rec.DT_Criteria_Logic__c.addError('Criteria Logic is wrong');
                    System.debug('<<Is not matching>>');
                }
                
            }else{
                System.debug('<<Criteria logic blank>>');
            }
            
        }
    }

    /*
    * Parse given Expression to extract serialNumbers
    *
    public static List<String> extractSerialNumbers(String sCriteriaLogic)
    {

        System.debug('<<extractSerialNumbers>>' +sCriteriaLogic);
        List<String> lstExtractedSerials = new List<String>();
        sCriteriaLogic = sCriteriaLogic.replaceAll('\\(', '');
        sCriteriaLogic = sCriteriaLogic.replaceAll('\\)', '');
        sCriteriaLogic = sCriteriaLogic.replaceAll('AND', ',');
        sCriteriaLogic = sCriteriaLogic.replaceAll('OR', ',');
        sCriteriaLogic = sCriteriaLogic.replaceAll(' ', '');

        System.debug('<<Final sCriteriaLogic>>' +sCriteriaLogic);
        lstExtractedSerials = sCriteriaLogic.split(',');
        System.debug(lstExtractedSerials);

        return lstExtractedSerials;
    }


    *
    * Validate given Expression using defined RegEx and return true if matching correctly otherwise false
    *
    public static Boolean validateExpression(String inputExp){
        Boolean isValid=false;  
        
        //START: Check expression starts and ends with '(' and ')' respectively
        String inputExpTemp = inputExp.replaceAll('AND', '');
        inputExpTemp = inputExpTemp.replaceAll('OR', ''); 
        inputExpTemp = inputExpTemp.replaceAll('[0-9]', '');
        inputExpTemp = inputExpTemp.replaceAll(' ', ''); 
        if( !((inputExpTemp.startswith('((') && inputExpTemp.endswith('))') )  || (inputExpTemp=='()')) ) {
           System.debug('Doesnt start and end with'); 
           return false;
        } 
        //END: Check expression starts and ends with '(' and ')' respectively
        
        //START:Check if bracket count is not equal
        Integer countStartBracket = inputExp.length() - inputExp.replaceAll('\\(','').length();
        Integer countEndBracket = inputExp.length() - inputExp.replaceAll('\\)','').length(); 
        if(countStartBracket!=countEndBracket) {
            System.debug('Bracket Count unequal');
            return false;
        } 
        //END:Check if bracket count is not equal
            
        try{  
            Pattern myPattern1 = Pattern.compile('((.*(AND)\\s+[0-9]+\\s+(OR).*)|(.*(OR)\\s+[0-9]+\\s+(AND).*))');
            Matcher myMatcher1 = myPattern1.matcher(inputExp); 
           
            Pattern myPattern2 = Pattern.compile('([(]*[0-9]+[)]*(\\s+(AND|OR)\\s+[(]*[0-9]+[)]*)*$)');
            Matcher myMatcher2 = myPattern2.matcher(inputExp); 
            
            Pattern myPattern3 = Pattern.compile('\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\([^()]*\\))*\\))*\\))*\\))*\\))*\\))*\\))*\\))*\\))*\\)'); //For 10 level
            //Pattern myPattern3 = Pattern.compile('\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\([^()]*\\))*\\))*\\))*\\))*\\)'); //For 4 level
            //Pattern myPattern3 = Pattern.compile('\\(([^()]*|\\(([^()]*|\\([^()]*\\))*\\))*\\)'); //For 3 level
            Matcher myMatcher3 = myPattern3.matcher(inputExp); 

            //Pattern myPattern4 = Pattern.compile('^[A-Za-z0-9 _]*[A-Za-z0-9][A-Za-z0-9 _]*$');
            //Matcher myMatcher4 = myPattern4.matcher(inputExp);

            //For Spacial Character// 
             
            if(myMatcher1.Matches() || !myMatcher2.Matches() || !myMatcher3.Matches()){
                isValid= false;
            } else{
                isValid= true;
            } 
            System.debug('Expression Status:'+isValid); 
         }catch(System.LimitException e1){
             isValid=false; 
             system.debug('Exception during LeadDistributionExpressionHelper::validateExpression()---->'+e1.getMessage());
         }catch(Exception e){
             isValid=false; 
             system.debug('Exception during LeadDistributionExpressionHelper::validateExpression()---->'+e.getMessage());
         } 
         
        return isValid;
    }*/

}