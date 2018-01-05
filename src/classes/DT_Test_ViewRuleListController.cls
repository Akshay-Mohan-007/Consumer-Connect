/***************************************************************************************************************************************
 * NAME   : DT_Test_ViewRuleListController
 * DESCRIPTION  : Test Class for DT_ViewRuleListController.
 *    
 * @AUTHOR   : Nidhin V K
 * @DATE   : 11-17-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               11-17-2017          Initial version        
 *
 ****************************************************************************************************************************************/

@isTest
private class DT_Test_ViewRuleListController {
    
    @testSetup static void setupData() {
        DT_TestDataFactory.createRuleCriteria(NULL, NULL, TRUE);
    }
    
    @isTest static void testRuleCriteriaMethods() {
        Test.startTest();
        PageReference pageRef = Page.DT_ViewRuleList;
        DT_ViewRuleListController objExtension = new DT_ViewRuleListController();
        System.assert(objExtension.getRules().size() > 0);
        Test.stopTest();
    }
}