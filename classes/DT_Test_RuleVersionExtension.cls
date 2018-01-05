/***************************************************************************************************************************************
 * NAME   : DT_Test_RuleVersionExtension
 * DESCRIPTION  : Test Class for DT_RuleVersionExtension.
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
private class DT_Test_RuleVersionExtension {
    
    @testSetup static void setupData() {
        DT_TestDataFactory.createRuleVersion(NULL, TRUE);
    }
    
    @isTest static void testRuleVersionMethods() {
        Test.startTest();
        PageReference pageRef = Page.DT_CreateRuleVersion;
        DT_Rule__c objRule = [SELECT 
                                Id, Name, DT_Task_Name__c, DT_Target_SObject_API_Name__c,
                                DT_Rule_Type__c, DT_Priority__c, DT_IsActive__c
                            FROM 
                                DT_Rule__c 
                            LIMIT 1];
        System.debug('objRule>>' + objRule);
        objRule.DT_IsActive__c = TRUE;
        update objRule;
        DT_Rule_Version__c objVersion = [SELECT 
                                            Id, Name, DT_Rule__c, DT_Assignment_Type__c,
                                            DT_Queue_Name__c, DT_IsActive__c, DT_Deactivated_Date__c
                                        FROM 
                                            DT_Rule_Version__c 
                                        LIMIT 1];
        System.debug('objVersion>>' + objVersion);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController objStdCntrl = new ApexPages.standardController(objVersion);
        
        DT_RuleVersionExtension objExtension = new DT_RuleVersionExtension(objStdCntrl);
        System.assert(objExtension.lstQueues.size() > 0);
        
        objExtension.onChangeAssignmentType();
        System.assertEquals(objExtension.bShowAssigneeType, false);
        
        objExtension.toggleActivate();
        
        DT_TestDataFactory.createRuleCriteria(objRule.Id, objVersion.Id, TRUE);
        objExtension.toggleActivate();
        
        objVersion.DT_IsActive__c = false;
        objVersion.DT_Criteria_Logic__c = '(1 AND 2)';
        objRule.DT_IsActive__c = false;
        update objRule;
        update objVersion;
        objExtension.bError = false;
        objExtension.toggleActivate();
        
        objVersion.DT_Assignment_Type__c = System.Label.DT_RULE_VER_TYPE_MANUAL;
        new DT_RuleVersionExtension(objStdCntrl);
        objExtension.onChangeAssignmentType();
        objVersion.DT_Assignee__c = DT_Constants.DT_ASSIGNEE_TYPE_TASK;
        objExtension.onChangeAssigneeType();
        System.assertEquals(objExtension.bShowAssigneeType, true);
        objExtension.populateAssignees(DT_Constants.DT_FIELD_TASK_NAME);
        
        DT_RuleVersionTriggerHandler.checkValidations(new List<DT_Rule_Version__c>{objVersion}, NULL);
        
        objExtension.cloneVersion();
        //System.assertEquals([SELECT Id FROM DT_Rule_Version__c].size(), 2);
        
        objExtension.deleteVersion();
        //System.assertEquals([SELECT Id FROM DT_Rule_Version__c].size(), 1);
        objVersion.Id= NULL;
        objExtension.toggleActivate();
        objExtension.cloneVersion();
        objExtension.deleteVersion();
        Test.stopTest();
    }
}