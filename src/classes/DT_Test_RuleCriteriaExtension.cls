/***************************************************************************************************************************************
 * NAME   : DT_Test_RuleCriteriaExtension
 * DESCRIPTION  : Test Class for DT_RuleCriteriaExtension.
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
private class DT_Test_RuleCriteriaExtension {
    
    @testSetup static void setupData() {
        DT_TestDataFactory.createRuleCriteria(NULL, NULL, TRUE);
    }
    
    @isTest static void testRuleCriteriaMethods() {
        Test.startTest();
        PageReference pageRef = Page.DT_CreateRuleCriteria;
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
        DT_Rule_Criterion__c objCriterion = [SELECT 
                                            Id, Name, RecordTypeId, DT_Rule_Version__c,
                                            DT_Serial_Number__c
                                        FROM 
                                            DT_Rule_Criterion__c 
                                        LIMIT 1];
        System.debug('objCriterion>>' + objCriterion);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController objStdCntrl = new ApexPages.standardController(objCriterion);
        
        DT_RuleCriteriaExtension objExtension = new DT_RuleCriteriaExtension(objStdCntrl);
        System.assert(objExtension.lstTaskFields.size() > 0);
        objExtension.populateSObjectFields('InvalidObject');
        
        objExtension.save();
        
        objExtension.selectedRTName = DT_Constants.DT_RECORD_TYPE_COMPARE;
        objCriterion.DT_Source_SObject_Field__c = 'Name';
        objExtension.save();
        
        objCriterion.DT_Source_SObject_Field__c = 'abc';
        objExtension.save();
        
        objExtension.selectedRTName = DT_Constants.DT_RECORD_TYPE_MAP_STATIC;
        objCriterion.DT_Target_Task_Field__c = DT_Constants.DT_FIELD_DUE_DATE;
        objExtension.enableDisableTaskField();
        System.assertEquals(objExtension.bShowTask, TRUE);
        objExtension.save();
        
        objExtension.selectedRTName = DT_Constants.DT_RECORD_TYPE_MAP_SOBJECT;
        objExtension.enableDisableTaskField();
        System.assertEquals(objExtension.bShowTask, TRUE);
        objCriterion.DT_Source_SObject_Field__c = 'Name';
        objExtension.save();
        
        objExtension.deleteCriteria();
        
        objRule.DT_IsActive__c = FALSE;
        objVersion.DT_IsActive__c = TRUE;
        update objRule;
        update objVersion;
        objExtension.deleteCriteria();
        
        Test.stopTest();
    }
}