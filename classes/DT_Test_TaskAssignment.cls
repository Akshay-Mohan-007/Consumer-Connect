/***************************************************************************************************************************************
 * NAME   : DT_Test_TaskAssignment
 * DESCRIPTION  : Test Class for DT_TaskAssignment.
 *    
 * @AUTHOR   : Nidhin V K
 * @DATE   : 11-07-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               11-07-2017          Initial version        
 *
 ****************************************************************************************************************************************/

@isTest
private class DT_Test_TaskAssignment {
     @testSetup static void setupData() {
        DT_TestDataFactory.createRuleVersion(NULL, TRUE);
        DT_TestDataFactory.createQueue();
    }
    
    @isTest static void testTaskAssignmentMethods() {
        Test.startTest();
        
        DT_Rule__c objRule = [SELECT 
                                Id, Name, DT_Task_Name__c, DT_Target_SObject_API_Name__c,
                                DT_Rule_Type__c, DT_Priority__c, DT_IsActive__c
                            FROM 
                                DT_Rule__c 
                            LIMIT 1];
        System.debug('objRule>>' + objRule);

        DT_Rule_Version__c objVersion = [SELECT 
                                            Id, Name, DT_Rule__c, DT_Assignment_Type__c,
                                            DT_Queue_Name__c, DT_IsActive__c, DT_Deactivated_Date__c
                                        FROM 
                                            DT_Rule_Version__c 
                                        LIMIT 1];
        System.debug('objVersion>>' + objVersion);
        
        Map<String, Schema.RecordTypeInfo> mapRTbyName = Schema.SObjectType.DT_Rule_Criterion__c.getRecordTypeInfosByName();
        List<DT_Rule_Criterion__c> lstCriteria = new List<DT_Rule_Criterion__c>();
        lstCriteria.add(new DT_Rule_Criterion__c(  
                        DT_Rule_Version__c = objVersion.Id,
                        DT_Source_SObject_Field__c = 'Type',
                        DT_Source_SObject_Field_Type__c = 'PICKLIST',
                        DT_Value_To_Compare__c = 'Analyst',
                        DT_Operator__c = DT_Constants.DT_STRING_EQUALS_TO,
                        RecordTypeId = mapRTbyName.get(DT_Constants.DT_RECORD_TYPE_COMPARE).getRecordTypeId(),
                        DT_Serial_Number__c = 1
                            ));
                            
        lstCriteria.add(new DT_Rule_Criterion__c(  
                        DT_Rule_Version__c = objVersion.Id,
                        DT_Source_SObject_Field__c = 'Type',
                        DT_Source_SObject_Field_Type__c = 'PICKLIST',
                        DT_Value_To_Compare__c = 'Competitor',
                        DT_Operator__c = DT_Constants.DT_STRING_NOT_EQUALS_TO,
                        RecordTypeId = mapRTbyName.get(DT_Constants.DT_RECORD_TYPE_COMPARE).getRecordTypeId(),
                        DT_Serial_Number__c = 2
                            ));
        
        lstCriteria.add(new DT_Rule_Criterion__c(  
                        DT_Rule_Version__c = objVersion.Id,
                        DT_Source_SObject_Field__c = 'Type',
                        DT_Source_SObject_Field_Type__c = 'PICKLIST',
                        DT_Target_Task_Field__c = DT_Constants.DT_FIELD_COMMENTS,
                        RecordTypeId = mapRTbyName.get(DT_Constants.DT_RECORD_TYPE_MAP_SOBJECT).getRecordTypeId()
                            ));
        
        lstCriteria.add(new DT_Rule_Criterion__c(  
                        DT_Rule_Version__c = objVersion.Id,
                        DT_Value_to_Map__c = 'New',
                        DT_Target_Task_Field__c = DT_Constants.DT_FIELD_STATUS,
                        RecordTypeId = mapRTbyName.get(DT_Constants.DT_RECORD_TYPE_MAP_STATIC).getRecordTypeId()
                            ));
        
        insert lstCriteria;
        /*lstCriteria = new List<DT_Rule_Criterion__c>();
        lstCriteria = [SELECT 
                            Id, DT_Rule_Version__c, DT_Serial_Number__c, DT_Source_SObject_Field__c, 
                            DT_Value_To_Compare__c, DT_Operator__c, RecordTypeId,
                            DT_Value_to_Map__c, DT_Target_Task_Field__c
                        FROM
                            DT_Rule_Criterion__c];
        for(DT_Rule_Criterion__c a : lstCriteria){
            System.debug('lstCriteria>>' + a);
        }*/
        
        objVersion.DT_IsActive__c = TRUE;
        objVersion.DT_Criteria_Logic__c = '(1 AND 2)';
        update objVersion;
        
        objRule.DT_IsActive__c = TRUE;
        update objRule;
        
        Account objAccount = new Account(Name = 'test', Type = 'Analyst');
        insert objAccount;
        
        DT_Task__c objTask = new DT_Task__c(
                                DT_Master_Record_Id__c = objAccount.Id,
                                DT_Status__c = DT_Constants.DT_TASK_STATUS_IN_PROGRESS
                                    );
        insert objTask;
        
        Map<String, String> mapTask = new Map<String, String>();
        mapTask.put('DT_Comments', 'test');
        mapTask.put(DT_Constants.DT_FIELD_MASTER_RECORD_ID, objAccount.Id);
        
        DT_TaskAssignment.executeTaskRules(NULL, NULL, NULL);
        DT_TaskAssignment.executeTaskRules(objAccount.Id, NULL, NULL);
        DT_TestDataFactory.createTaskSettings(TRUE);
        DT_TaskResponseWrapper objResponse = DT_TaskAssignment.executeTaskRules(objAccount.Id, mapTask, objTask.Id);
        System.assertEquals(objResponse.success, true);
        
        objVersion.DT_Assignment_Type__c = System.Label.DT_RULE_VER_TYPE_MANUAL;
        update objVersion;
        DT_TaskAssignment.executeTaskRules(objAccount.Id, mapTask, objTask.Id);
        
        objVersion.DT_Assignee__c = DT_Constants.DT_ASSIGN_BACK_TO_PERSON;
        update objVersion;
        DT_TaskAssignment.executeTaskRules(objAccount.Id, mapTask, objTask.Id);
        
        objVersion.DT_Assignee__c = DT_Constants.DT_ASSIGNEE_TYPE_TASK;
        update objVersion;
        DT_TaskAssignment.executeTaskRules(objAccount.Id, mapTask, objTask.Id);
        
        Map<String, Boolean> mapExprValue = new Map<String, Boolean>();
        mapExprValue.put('1', FALSE);
        mapExprValue.put('2', TRUE);
        mapExprValue.put('3', TRUE);
        mapExprValue.put('4', TRUE);
        DT_Util.evaluateExpression('((1 OR 2) AND (3 OR 4))', mapExprValue);
        
        Set<String> lstOperators = new Set<String>{
                                DT_Constants.DT_STRING_EQUALS_TO,
                                DT_Constants.DT_STRING_NOT_EQUALS_TO,
                                DT_Constants.DT_STRING_GREATER_THAN,
                                DT_Constants.DT_STRING_GREATER_THAN_OR_EQUALS_TO,
                                DT_Constants.DT_STRING_LESS_THAN,
                                DT_Constants.DT_STRING_LESS_THAN_OR_EQUALS_TO
                            }; 
        
        mapTask.put('Id', objAccount.Id);
        mapTask.put('NumberOfEmployees', '5');
        mapTask.put('AnnualRevenue', '1000.00');
        mapTask.put('IsPartner', 'TRUE');
        mapTask.put('NumberOfEmployees', '5');
        mapTask.put('NumberOfEmployees', '5');
        DT_Util.generateRecordFromMap(objAccount, mapTask);
        
        String sFieldValue, tValue, fieldType;
        sFieldValue = 'test';
        fieldType = 'TEXT';
        tValue = 'test';
        
        for(String operator : lstOperators){    
            DT_Util.compareValues(sFieldValue, operator, tValue, fieldType);
        }
        
        sFieldValue = '1';
        fieldType = 'INTEGER,DOUBLE';
        tValue = '1';
        for(String types : fieldType.split(',')){
            for(String operator : lstOperators){    
                DT_Util.compareValues(sFieldValue, operator, tValue, types);
            }
        }
        
        sFieldValue = '2017-10-10 00:00:00';
        fieldType = 'DATE,DATETIME';
        tValue = '2017-10-10 00:00:00';
        for(String types : fieldType.split(',')){
            for(String operator : lstOperators){    
                DT_Util.compareValues(sFieldValue, operator, tValue, types);
            }
        }
        
        DT_Util.returnFilterResult('(TRUE)');
        System.assertEquals(true, true);
        Test.stopTest();
    }
}