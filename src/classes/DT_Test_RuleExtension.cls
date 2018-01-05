/***************************************************************************************************************************************
 * NAME   : DT_Test_RuleExtension
 * DESCRIPTION  : Test Class for DT_RuleExtension.
 *    
 * @AUTHOR   : Nidhin V K
 * @DATE   : 10-31-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               10-31-2017          Initial version        
 *
 ****************************************************************************************************************************************/

@isTest
private class DT_Test_RuleExtension {
    
    @testSetup static void setupData() {
        DT_TestDataFactory.createRule(TRUE);
    }
    
    @isTest static void testRuleMethods() {
        
        Test.startTest();
        PageReference pageRef = Page.DT_CreateRules;
        DT_Rule__c objRule = [SELECT 
                                Id, Name, DT_Task_Name__c, DT_Target_SObject_API_Name__c,
                                DT_Rule_Type__c, DT_Priority__c, DT_IsActive__c
                            FROM 
                                DT_Rule__c 
                            LIMIT 1];
        System.debug('objRule>>' + objRule);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController objStdCntrl = new ApexPages.standardController(objRule);
        
        DT_RuleExtension objExtension = new DT_RuleExtension(objStdCntrl);
        System.assert(objExtension.lstTargetObjects.size() > 0);
        
        PageReference pageRef1 = objExtension.cancel();
        System.assertEquals('/' + objRule.Id, pageRef1.getUrl());
        
        objExtension.toggleActivate();
        //System.assertEquals(objRule.DT_IsActive__c, true);
        objRule.DT_IsActive__c = true;
        objExtension.toggleActivate();
        
        PageReference pageRef2 = objExtension.deleteRule();
        System.assertEquals('/apex/DT_ViewRuleList', pageRef2.getUrl());
        objRule.Id = NULL;
        objExtension.toggleActivate();
        objExtension.deleteRule();  
        Test.stopTest();
    }
}