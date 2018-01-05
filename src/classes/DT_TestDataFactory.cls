/***************************************************************************************************************************************
 * NAME   : DT_TestDataFactory
 * DESCRIPTION  : Contains all common test data records.
 *    
 * @AUTHOR   : Nidhin V K
 * @DATE   : 11-06-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               11-06-2017          Initial version        
 *
 ****************************************************************************************************************************************/
@isTest
public with sharing class DT_TestDataFactory {
    
    
    public static DT_Rule__c createRule(Boolean isInsert){
        DT_Rule__c objRule = new DT_Rule__c(
                                Name = 'Test Rule', 
                                DT_Task_Name__c = 'Test Task', 
                                DT_Target_SObject_API_Name__c = 'Account',
                                DT_Module__c = 'Account',
                                DT_Rule_Type__c = DT_Constants.DT_RULE_TYPE_TASK,
                                DT_Priority__c = DT_Constants.DT_VALUE_NORMAL,
                                DT_IsActive__c = false);
                                
        if(isInsert)
            insert objRule;
        return objRule;
    }
    
    public static DT_Rule_Version__c createRuleVersion(Id ruleId, Boolean isInsert){
        if(String.isBlank(ruleId)){
            DT_Rule__c objRule = createRule(TRUE);
            ruleId = objRule.Id;
        }
        DT_Rule_Version__c objVersion = new DT_Rule_Version__c(  
                                DT_Rule__c = ruleId,
                                DT_Version_Number__c = 1,
                                DT_Assignment_Type__c = System.Label.DT_RULE_TYPE_QUEUE,
                                DT_Queue_Name__c = 'TestQueue',
                                DT_IsActive__c = false);
        
        if(isInsert)
            insert objVersion;
        return objVersion;
    }
    
    public static DT_Rule_Criterion__c createRuleCriteria(Id ruleId, Id versionId, Boolean isInsert){
        if(String.isBlank(versionId)){
            DT_Rule_Version__c objVersion = createRuleVersion(ruleId, TRUE);
            versionId = objVersion.Id;
        }
        DT_Rule_Criterion__c objCriterion = new DT_Rule_Criterion__c(  
                                DT_Rule_Version__c = versionId,
                                DT_Operator__c = DT_Constants.DT_STRING_EQUALS_TO);
        
        if(isInsert)
            insert objCriterion;
        return objCriterion;
    }
    
    public static DT_Task_Settings__c createTaskSettings(Boolean isInsert){
        DT_Task_Settings__c objSettings = new DT_Task_Settings__c(
                                            DT_Task_Master_Object__c = 'Account'
                                            );
        if(isInsert)
            insert objSettings;
        return objSettings;
    }
    
    public static RecordType createRecordType(Id recordId, String sObjectType){
        RecordType objRecordType = new RecordType(
                                        Id = recordId,
                                        Name = 'Sample RT',
                                        DeveloperName = 'SampleRT',
                                        IsActive = TRUE,
                                        SobjectType = sObjectType
                                            );
        return objRecordType;
    }
    
    public static void createQueue(){
        Group testGroup = new Group(Name='TestQueue', DeveloperName = 'TestQueue', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'DT_Task__c');
            insert testQueue;
        }
    }
}