/* Class Name   : DT_Util
 * Description  : All Utility methods.    
 * Created By   : Nidhin V K
 * Created On   : 07-29-2016

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date        Modification ID      Description 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K            07-29-2016        1000            Initial version
 * Debalina Chatterjee   09-23-2016        1001            
 *
 */
public without sharing class DT_Util {

    /* getQueueId
     * Method to get queue id
     * @params : queue Developer Name
     * @return : queue id
     *
     */
    public static Id getQueueId(String queueDevName) {

        List < Group > objGroup = [SELECT
            Id,
            Name
            FROM
            Group
            WHERE
            DeveloperName =: queueDevName
        ];
        if (objGroup.size() > 0) {
            return objGroup[0].id;
        } else return NULL;
    }


    /* getActiveRules
     * Returns list of Rule criteria applicable for the given sObject type
     * @params : sObjectType, ruleType
     * @return : List<DT_Rule_Version__c>
     *
     */
    public static List < DT_Rule_Version__c > getActiveRules(String sObjectType, String ruleType) {

        List < DT_Rule_Version__c > lstRuleVersions = new List < DT_Rule_Version__c > ();

        //get all active rules on the specified object                    
        lstRuleVersions = [SELECT
            Id,
            Name,
            DT_Queue_Name__c,
            DT_Criteria_Logic__c,
            DT_Assignment_Type__c,
            DT_Assignee__c,
            DT_Assign_To_Owner_Of__c,
            DT_IsActive__c,
            DT_Rule__r.DT_Task_Name__c,
            DT_Rule__r.DT_Priority__c,
            DT_Rule__r.DT_Rule_Type__c,
            DT_Rule__r.DT_Target_SObject_API_Name__c,
            (SELECT Id,
                DT_Operator__c,
                DT_Serial_Number__c,
                DT_Source_SObject_Field__c,
                DT_Source_SObject_Field_Type__c,
                DT_Target_Task_Field__c,
                DT_Value_To_Compare__c,
                DT_Value_to_Map__c,
                RecordTypeId FROM DT_Rule_Criteria__r)
            FROM
            DT_Rule_Version__c
            WHERE
            DT_Rule__r.DT_Rule_Type__c =: ruleType
            AND
            DT_Rule__r.DT_Target_SObject_API_Name__c =: sObjectType
            AND
            DT_IsActive__c = TRUE
            AND
            DT_Rule__r.DT_IsActive__c = TRUE
        ];

        return lstRuleVersions;
    }


    /* evaluateRuleCriteria
     * Returns list of Rule criteria applicable for the given sObject type
     * @params : objRecord, activeRules
     * @return : List<DT_Rule_Version__c>
     *
     */
    public static List < DT_Rule_Version__c > evaluateRuleCriteria(sObject objRecord, List < DT_Rule_Version__c > lstActiveRules) {

        Map < Id, DT_Rule_Version__c > mapEligibleRules = new Map < Id, DT_Rule_Version__c > ();
        Map < String, Boolean > mapExprValue = new Map < String, Boolean > ();

        try {
            System.debug('evaluateRuleCriteria : ');
            //get record type compare
            Map<String, Schema.RecordTypeInfo> mapRTbyName = Schema.SObjectType.DT_Rule_Criterion__c.getRecordTypeInfosByName();
            //evaluate each rule criteria
            for (DT_Rule_Version__c activeRule: lstActiveRules) {

                mapExprValue = new Map < String, Boolean > ();
                //if 1st criteria is false then no need to check in case of and  
                for (DT_Rule_Criterion__c criterion: activeRule.DT_Rule_Criteria__r) {
                    if (!String.isBlank(criterion.DT_Source_SObject_Field__c) &&
                        !String.isBlank(criterion.DT_Operator__c) &&
                        !String.isBlank(criterion.DT_Value_To_Compare__c) &&
                        !String.isBlank(criterion.DT_Source_SObject_Field_Type__c) &&
                        criterion.DT_Serial_Number__c > 0 &&
                        mapRTbyName.get(DT_Constants.DT_RECORD_TYPE_COMPARE).getRecordTypeId() == criterion.RecordTypeId &&
                        objRecord.get(criterion.DT_Source_SObject_Field__c) != NULL) {

                        System.debug('Inside Loop : ' + criterion);
                        mapExprValue.put(String.valueOf(criterion.DT_Serial_Number__c),
                            compareValues(
                                String.valueOf(objRecord.get(criterion.DT_Source_SObject_Field__c)),
                                criterion.DT_Operator__c,
                                criterion.DT_Value_To_Compare__c,
                                criterion.DT_Source_SObject_Field_Type__c));

                    }
                }
                System.debug('mapExprValue : ' + mapExprValue);
                System.debug('DT_Criteria_Logic__c : ' + activeRule.DT_Criteria_Logic__c);
                Boolean bExpressionResult = evaluateExpression(activeRule.DT_Criteria_Logic__c, mapExprValue);
                if (mapExprValue != NULL && bExpressionResult) {
                    mapEligibleRules.put(activeRule.Id, activeRule);
                }
            }
            System.debug('mapEligibleRules : ' + mapEligibleRules);

            //return false if the rule evaluates to false or there is no evaluation criteria    
            if (mapEligibleRules.size() == 0) {
                //no valid rules
                System.debug('DT_Util : No Valid Eligible Rules');
                return null;
            }

            System.debug('<<Final:>>' + mapEligibleRules);
            return mapEligibleRules.values();

        } catch (Exception ex) {
            //throw error no such field exists
            System.debug('Exception on Class : DT_Util, Error : ' +
                ex.getMessage() +
                ' Line Number : ' +
                ex.getLineNumber() +
                ' Cause : ' +
                ex.getCause() +
                ' Type : ' +
                ex.getTypeName());

            DT_Error_Log.genericException(
                ex.getMessage(),
                DT_Constants.DT_ERROR_TYPE_BUSINESS_VALIDATION,
                ex,
                DT_Constants.DT_CLASS_UTIL,
                DT_Constants.DT_METHOD_EVALUATE_RULE_CRITERIA,
                objRecord.Id == NULL ? NULL : objRecord.Id,
                DT_Constants.DT_EMPTY);

            return null;
        }
    }


    /* getHighPriorityRule
     * Returns the Rule criterion with high priority
     * @params : eligibleRules
     * @return : DT_Rule_Version__c
     *
     */
    public static DT_Rule_Version__c getHighPriorityRule(List < DT_Rule_Version__c > lstEligibleRules) {

        if (lstEligibleRules.size() == 1) {
            return lstEligibleRules[0];
        }
        //loop through the priority levels to get the high priority one
        for (String priority: DT_Constants.DT_RULE_PRIORITY_LIST) {

            for (DT_Rule_Version__c ruleVersion: lstEligibleRules) {

                if (ruleVersion.DT_Rule__r != NULL && !String.isBlank(ruleVersion.DT_Rule__r.DT_Priority__c) &&
                    ruleVersion.DT_Rule__r.DT_Priority__c.equals(priority)) {

                    return ruleVersion;
                }
            }
        }
        //Return random rule if there is no or more than one rules with a priority
        return lstEligibleRules[0];
    }

    /* generateRecordFromMap
     * Create a record by checking the map keys (fieldNames) and based on the datatype of the field,
     * populate the value by typecasting the value in the map
     * @params : objRecord, mapRecord
     * @return : sObject
     *
     */
    public static sObject generateRecordFromMap(sObject objRecord, Map < String, String > mapRecord) {

        Map < String, Schema.DisplayType > mapFieldTypes = new Map < String, Schema.DisplayType > ();

        Schema.SObjectType objSobjectType = objRecord.getSObjectType();
        String strSobjAPIName = objSobjectType.getDescribe().getName();
        Map < String, Schema.SObjectField > mapObjectFields = Schema.getGlobalDescribe().get(strSobjAPIName).getDescribe().fields.getMap();

        //Filter the fields to return text fields
        for (Schema.SObjectField fld: mapObjectFields.values()) {
            schema.describeFieldResult dfield = fld.getDescribe();
            if (dfield.isCreateable()) {
                mapFieldTypes.put(dfield.getName(), dfield.getType());
            }
        }

        for (String fieldName: mapRecord.keySet()) {
            if (mapFieldTypes.keySet().contains(fieldName)) {
                Schema.DisplayType fieldType = mapFieldTypes.get(fieldName);
                if (fieldType == Schema.DisplayType.String ||
                    fieldType == Schema.DisplayType.TextArea ||
                    fieldType == Schema.DisplayType.Picklist ||
                    fieldType == Schema.DisplayType.Phone ||
                    fieldType == Schema.DisplayType.URL ||
                    fieldType == Schema.DisplayType.Email ||
                    fieldType == Schema.DisplayType.Reference ||
                    fieldType == Schema.DisplayType.EncryptedString ||
                    fieldType == Schema.DisplayType.Id) {

                    objRecord.put(fieldName, mapRecord.get(fieldName));

                } else if (fieldType == Schema.DisplayType.Integer) {

                    objRecord.put(fieldName, Integer.valueOf(mapRecord.get(fieldName)));

                } else if (fieldType == Schema.DisplayType.Double) {

                    objRecord.put(fieldName, Double.valueOf(mapRecord.get(fieldName)));

                } else if (fieldType == Schema.DisplayType.Boolean) {

                    objRecord.put(fieldName, Boolean.valueOf(mapRecord.get(fieldName)));

                } else if (fieldType == Schema.DisplayType.DateTime) {

                    objRecord.put(fieldName, DateTime.valueOf(mapRecord.get(fieldName)));

                } else if (fieldType == Schema.DisplayType.Date) {

                    objRecord.put(fieldName, Date.valueOf(mapRecord.get(fieldName)));

                }
            }
        }
        return objRecord;
    }


    /* evaluateExpression
     * This Method Process the given Expression and Return the Final Result(true/false)
     * @params : sExpresssion, mapExprValue
     * @return : Boolean
     *
     */
    public static Boolean evaluateExpression(String sExpresssion, Map < String, Boolean > mapExprValue) {
        String sFilter = sExpresssion; //This variable is used for getting the expression Value 
        Boolean bRuleFlag; //This variable is used for returning the Final Filter value 

        List < Integer > lstExprValue = new List < Integer > ();
        for (String exprKey: mapExprValue.keyset()) {
            lstExprValue.add(Integer.valueof(exprKey));
        }
        lstExprValue.sort();

        for (Integer i = lstExprValue.size() - 1; i >= 0; i--) {
            sFilter = sFilter.replace(String.valueOf(lstExprValue.get(i)), String.valueOf(mapExprValue.get(String.valueOf(lstExprValue.get(i)))));
        }

        if (sFilter.Contains('OR') && sFilter.Contains('AND')) {
            List < string > lstFilter = sFilter.split('\\('); //Splitting the Filter String and Creating the List
            //system.debug('FilterList'+FilterList.size());
            Integer iLastIndex, iFirstIndex;
            String sSubFilterValue, sSubFilterValue1;
            Boolean bSubFilterFlag;
            for (integer i = 0; i < lstFilter.size(); i++) {
                iLastIndex = sFilter.lastIndexOf('(');
                if (iLastIndex > -1) {
                    sSubFilterValue1 = sFilter.substring(iLastIndex, sFilter.length());
                    iFirstIndex = sSubFilterValue1.indexOf(')');
                    iFirstIndex = iFirstIndex + iLastIndex;
                    sSubFilterValue = sFilter.substring(iLastIndex, iFirstIndex + 1);
                    system.debug(sSubFilterValue);
                    bSubFilterFlag = returnFilterResult(sSubFilterValue); //Returns result extracted expression from sFilter  eg:(true And false)
                    sFilter = sFilter.replace(sSubFilterValue, string.valueOf(bSubFilterFlag));
                    system.debug('Filter' + sFilter);
                }
            }
            bRuleFlag = Boolean.valueof(sFilter);
        } else {
            bRuleFlag = returnFilterResult(sFilter);
        }

        return bRuleFlag;
    }

    /* returnFilterResult
     * This Method checks and process the Either "AND" OR  "OR" Filter String and Return the Final Value(true/false)
     * @params : sFilterValue
     * @return : Boolean
     *
     */
    public static Boolean returnFilterResult(String sFilterValue) {
        Boolean bRuleFlag;
        System.debug('SAu***: ' + sFilterValue);
        if (sFilterValue.Contains('AND') && !sFilterValue.Contains('OR')) {
            if (sFilterValue.Contains('false')) {
                bRuleFlag = false;
            } else {
                bRuleFlag = true;
            }
        } else if (sFilterValue.Contains('OR') && !sFilterValue.Contains('AND')) {
            if (sFilterValue.Contains('true')) {
                bRuleFlag = true;
            } else {
                bRuleFlag = false;
            }
        } else {
            sFilterValue = sFilterValue.replace('(', '');
            sFilterValue = sFilterValue.replace(')', '');
            bRuleFlag = Boolean.valueof(sFilterValue);
        }
        return bRuleFlag;
    }


    /* compareValues
     * This Method compare the expression and Return the Final Value(true/false)
     * @params : sFieldValue, sValue, fieldType, sOperator
     * @return : Boolean
     *
     */
    public static Boolean compareValues(String sFieldValue, String sOperator, String tValue, String fieldType) {
        System.debug('compareValues : ');
        System.debug('sOperator : ' + sOperator);
        System.debug('fieldType : ' + fieldType);
        if (sOperator.equals(DT_Constants.DT_STRING_EQUALS_TO)) {

            if ((fieldType == Schema.DisplayType.String.name() ||
                    fieldType == Schema.DisplayType.TextArea.name() ||
                    fieldType == Schema.DisplayType.Picklist.name() ||
                    fieldType == Schema.DisplayType.Phone.name() ||
                    fieldType == Schema.DisplayType.URL.name() ||
                    fieldType == Schema.DisplayType.Email.name() ||
                    fieldType == Schema.DisplayType.Reference.name() ||
                    fieldType == Schema.DisplayType.EncryptedString.name() ||
                    fieldType == Schema.DisplayType.Id.name()) &&
                String.valueOf(sFieldValue) == String.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Integer.name() &&
                Integer.valueOf(sFieldValue) == Integer.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Double.name() &&
                Double.valueOf(sFieldValue) == Double.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Boolean.name() &&
                Boolean.valueOf(sFieldValue) == Boolean.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.DateTime.name() &&
                DateTime.valueOf(sFieldValue) == DateTime.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Date.name() &&
                Date.valueOf(sFieldValue) == Date.valueOf(tValue)) {

                return true;

            } else {
                return false;
            }
        } else if (sOperator.equals(DT_Constants.DT_STRING_NOT_EQUALS_TO)) {

            if ((fieldType == Schema.DisplayType.String.name() ||
                    fieldType == Schema.DisplayType.TextArea.name() ||
                    fieldType == Schema.DisplayType.Picklist.name() ||
                    fieldType == Schema.DisplayType.Phone.name() ||
                    fieldType == Schema.DisplayType.URL.name() ||
                    fieldType == Schema.DisplayType.Email.name() ||
                    fieldType == Schema.DisplayType.Reference.name() ||
                    fieldType == Schema.DisplayType.EncryptedString.name() ||
                    fieldType == Schema.DisplayType.Id.name()) &&
                String.valueOf(sFieldValue) != String.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Integer.name() &&
                Integer.valueOf(sFieldValue) != Integer.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Double.name() &&
                Double.valueOf(sFieldValue) != Double.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Boolean.name() &&
                Boolean.valueOf(sFieldValue) != Boolean.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.DateTime.name() &&
                DateTime.valueOf(sFieldValue) != DateTime.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Date.name() &&
                Date.valueOf(sFieldValue) != Date.valueOf(tValue)) {

                return true;

            } else {
                return false;
            }
        } else if (sOperator.equals(DT_Constants.DT_STRING_GREATER_THAN)) {

            if ((fieldType == Schema.DisplayType.String.name() ||
                    fieldType == Schema.DisplayType.TextArea.name() ||
                    fieldType == Schema.DisplayType.Picklist.name() ||
                    fieldType == Schema.DisplayType.Phone.name() ||
                    fieldType == Schema.DisplayType.URL.name() ||
                    fieldType == Schema.DisplayType.Email.name() ||
                    fieldType == Schema.DisplayType.Reference.name() ||
                    fieldType == Schema.DisplayType.EncryptedString.name() ||
                    fieldType == Schema.DisplayType.Id.name()) &&
                String.valueOf(sFieldValue) > String.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Integer.name() &&
                Integer.valueOf(sFieldValue) > Integer.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Double.name() &&
                Double.valueOf(sFieldValue) > Double.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.DateTime.name() &&
                DateTime.valueOf(sFieldValue) > DateTime.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Date.name() &&
                Date.valueOf(sFieldValue) > Date.valueOf(tValue)) {

                return true;

            } else {
                return false;
            }
        } else if (sOperator.equals(DT_Constants.DT_STRING_GREATER_THAN_OR_EQUALS_TO)) {

            if ((fieldType == Schema.DisplayType.String.name() ||
                    fieldType == Schema.DisplayType.TextArea.name() ||
                    fieldType == Schema.DisplayType.Picklist.name() ||
                    fieldType == Schema.DisplayType.Phone.name() ||
                    fieldType == Schema.DisplayType.URL.name() ||
                    fieldType == Schema.DisplayType.Email.name() ||
                    fieldType == Schema.DisplayType.Reference.name() ||
                    fieldType == Schema.DisplayType.EncryptedString.name() ||
                    fieldType == Schema.DisplayType.Id.name()) &&
                String.valueOf(sFieldValue) == String.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Integer.name() &&
                Integer.valueOf(sFieldValue) >= Integer.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Double.name() &&
                Double.valueOf(sFieldValue) >= Double.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.DateTime.name() &&
                DateTime.valueOf(sFieldValue) >= DateTime.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Date.name() &&
                Date.valueOf(sFieldValue) >= Date.valueOf(tValue)) {

                return true;

            } else {
                return false;
            }
        } else if (sOperator.equals(DT_Constants.DT_STRING_LESS_THAN)) {

            if ((fieldType == Schema.DisplayType.String.name() ||
                    fieldType == Schema.DisplayType.TextArea.name() ||
                    fieldType == Schema.DisplayType.Picklist.name() ||
                    fieldType == Schema.DisplayType.Phone.name() ||
                    fieldType == Schema.DisplayType.URL.name() ||
                    fieldType == Schema.DisplayType.Email.name() ||
                    fieldType == Schema.DisplayType.Reference.name() ||
                    fieldType == Schema.DisplayType.EncryptedString.name() ||
                    fieldType == Schema.DisplayType.Id.name()) &&
                String.valueOf(sFieldValue) == String.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Integer.name() &&
                Integer.valueOf(sFieldValue) < Integer.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Double.name() &&
                Double.valueOf(sFieldValue) < Double.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.DateTime.name() &&
                DateTime.valueOf(sFieldValue) < DateTime.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Date.name() &&
                Date.valueOf(sFieldValue) < Date.valueOf(tValue)) {

                return true;

            } else {
                return false;
            }
        } else if (sOperator.equals(DT_Constants.DT_STRING_LESS_THAN_OR_EQUALS_TO)) {

            if ((fieldType == Schema.DisplayType.String.name() ||
                    fieldType == Schema.DisplayType.TextArea.name() ||
                    fieldType == Schema.DisplayType.Picklist.name() ||
                    fieldType == Schema.DisplayType.Phone.name() ||
                    fieldType == Schema.DisplayType.URL.name() ||
                    fieldType == Schema.DisplayType.Email.name() ||
                    fieldType == Schema.DisplayType.Reference.name() ||
                    fieldType == Schema.DisplayType.EncryptedString.name() ||
                    fieldType == Schema.DisplayType.Id.name()) &&
                String.valueOf(sFieldValue) <= String.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Integer.name() &&
                Integer.valueOf(sFieldValue) <= Integer.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Double.name() &&
                Double.valueOf(sFieldValue) <= Double.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.DateTime.name() &&
                DateTime.valueOf(sFieldValue) <= DateTime.valueOf(tValue)) {

                return true;

            } else if (fieldType == Schema.DisplayType.Date.name() &&
                Date.valueOf(sFieldValue) <= Date.valueOf(tValue)) {

                return true;

            } else {
                return false;
            }
        } else {
            return false;
        }
        return false;
    }

    /* checkCriteriaLogic 
     * Check criteria logic in rule version has valid syntax
     * @params : objRuleVersion - List of Rule Versions
     * @return : Boolean
     */
    public static Boolean checkCriteriaLogic(DT_Rule_Version__c objRuleVersion) {

        if (validateExpression(objRuleVersion.DT_Criteria_Logic__c)) {
            List < DT_Rule_Criterion__c > lstRelatedCriteria = [SELECT
                Id, DT_Serial_Number__c, DT_Rule_Version__c
                FROM
                DT_Rule_Criterion__c
                WHERE
                RecordType.DeveloperName = 'Compare_Field_Value'
                AND
                DT_Rule_Version__c =: objRuleVersion.Id
            ];

            if (lstRelatedCriteria.size() > 0) {

                System.debug('Criteria is there');

                Set < Integer > setSerialNo = new Set < Integer > ();
                for (DT_Rule_Criterion__c criteria: lstRelatedCriteria) {
                    System.debug(criteria.DT_Serial_Number__c);
                    setSerialNo.add(Integer.valueOf(criteria.DT_Serial_Number__c));
                }

                Integer iMaxSerialNo;
                for (Integer max: setSerialNo) {
                    if(iMaxSerialNo == null || iMaxSerialNo == 0)
                        iMaxSerialNo = max;
                    else if(iMaxSerialNo<max)
                        iMaxSerialNo = max;
                }

                System.debug('<<iMaxSerialNo>>' + iMaxSerialNo);

                //Extract serial Numbers from criteria logic
                List < String > lstSeialsEntered = extractSerialNumbers(objRuleVersion.DT_Criteria_Logic__c);

                for (String serial: lstSeialsEntered) {
                    if (Integer.valueOf(serial) > iMaxSerialNo || Integer.valueOf(serial) == 0) {
                        return false;
                    }
                }
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }


    /* extractSerialNumbers 
     * Parse given Expression to extract serialNumbers
     * @params : sCriteriaLogic
     * @return : List of serial numbers
     */
    public static List < String > extractSerialNumbers(String sCriteriaLogic) {

        System.debug('<<extractSerialNumbers>>' + sCriteriaLogic);
        List < String > lstExtractedSerials = new List < String > ();
        sCriteriaLogic = sCriteriaLogic.replaceAll('\\(', '');
        sCriteriaLogic = sCriteriaLogic.replaceAll('\\)', '');
        sCriteriaLogic = sCriteriaLogic.replaceAll('AND', ',');
        sCriteriaLogic = sCriteriaLogic.replaceAll('OR', ',');
        sCriteriaLogic = sCriteriaLogic.replaceAll(' ', '');

        System.debug('<<Final sCriteriaLogic>>' + sCriteriaLogic);
        lstExtractedSerials = sCriteriaLogic.split(',');
        System.debug(lstExtractedSerials);

        return lstExtractedSerials;
    }


    /* validateExpression 
     * Validate given Expression using defined RegEx and return true if matching correctly otherwise false
     * @params : sInputExp
     * @return : Boolean
     */
    public static Boolean validateExpression(String sInputExp) {
        Boolean bIsValid = false;

        //START: Check expression starts and ends with '(' and ')' respectively
        String sInputExpTemp = sInputExp.replaceAll('AND', '');
        sInputExpTemp = sInputExpTemp.replaceAll('OR', '');
        sInputExpTemp = sInputExpTemp.replaceAll('[0-9]', '');
        sInputExpTemp = sInputExpTemp.replaceAll(' ', '');
        if (!((sInputExpTemp.startswith('((') && sInputExpTemp.endswith('))')) || (sInputExpTemp == '()'))) {
            System.debug('Doesnt start and end with');
            return false;
        }
        //END: Check expression starts and ends with '(' and ')' respectively

        //START:Check if bracket count is not equal
        Integer iCountStartBracket = sInputExp.length() - sInputExp.replaceAll('\\(', '').length();
        Integer iCountEndBracket = sInputExp.length() - sInputExp.replaceAll('\\)', '').length();
        if (iCountStartBracket != iCountEndBracket) {
            System.debug('Bracket Count unequal');
            return false;
        }
        //END:Check if bracket count is not equal

        try {
            Pattern myPattern1 = Pattern.compile('((.*(AND)\\s+[0-9]+\\s+(OR).*)|(.*(OR)\\s+[0-9]+\\s+(AND).*))');
            Matcher myMatcher1 = myPattern1.matcher(sInputExp);

            Pattern myPattern2 = Pattern.compile('([(]*[0-9]+[)]*(\\s+(AND|OR)\\s+[(]*[0-9]+[)]*)*$)');
            Matcher myMatcher2 = myPattern2.matcher(sInputExp);

            Pattern myPattern3 = Pattern.compile('\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\([^()]*\\))*\\))*\\))*\\))*\\))*\\))*\\))*\\))*\\))*\\)'); //For 10 level
            //Pattern myPattern3 = Pattern.compile('\\(([^()]*|\\(([^()]*|\\(([^()]*|\\(([^()]*|\\([^()]*\\))*\\))*\\))*\\))*\\)'); //For 4 level
            //Pattern myPattern3 = Pattern.compile('\\(([^()]*|\\(([^()]*|\\([^()]*\\))*\\))*\\)'); //For 3 level
            Matcher myMatcher3 = myPattern3.matcher(sInputExp);

            /*Pattern myPattern4 = Pattern.compile('^[A-Za-z0-9 _]*[A-Za-z0-9][A-Za-z0-9 _]*$');
            Matcher myMatcher4 = myPattern4.matcher(sInputExp);*/

            /*For Spacial Character*/

            if (myMatcher1.Matches() || !myMatcher2.Matches() || !myMatcher3.Matches()) {
                bIsValid = false;
            } else {
                bIsValid = true;
            }
            System.debug('Expression Status:' + bIsValid);
        } catch (System.LimitException e1) {
            bIsValid = false;
            system.debug('Exception during LeadDistributionExpressionHelper::validateExpression()---->' + e1.getMessage());
        } catch (Exception e) {
            bIsValid = false;
            system.debug('Exception during LeadDistributionExpressionHelper::validateExpression()---->' + e.getMessage());
        }

        return bIsValid;
    }
    
    /* closePreviousAndCreateNewTask
     * close the previous Task and creates the new task
     * @params : objTask, bStorePrevOwnerId
     * @return : List<DT_Task__c> assigned Tasks
     */
    public static void closePreviousAndCreateNewTask(DT_Task__c objTask, String sTaskIdToClose) {
    	List<DT_Task__c> lstTaskToUpdate = new List<DT_Task__c>();
    	if(String.isNotBlank(sTaskIdToClose)){
			DT_Task__c objTaskToClose = new DT_Task__c(
											Id = sTaskIdToClose,
											DT_Status__c = DT_Constants.DT_TASK_STATUS_COMPLETE,
											DT_Close_Date__c = DateTime.now()
											);
			lstTaskToUpdate.add(objTaskToClose);
    	}
		if(objTask != NULL)
    		lstTaskToUpdate.add(objTask);
    	upsert lstTaskToUpdate;
    	System.debug('Tasks updated>>' + lstTaskToUpdate);
    }
}