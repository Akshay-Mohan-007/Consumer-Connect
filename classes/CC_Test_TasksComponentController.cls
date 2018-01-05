/***************************************************************************************************************************************
 * NAME   : CC_Test_TasksComponentController
 * DESCRIPTION  : Test Class for CC_TasksComponentController.
 *    
 * @AUTHOR   : Nidhin V K
 * @DATE   : 11-16-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               11-16-2017          Initial version        
 *
 ****************************************************************************************************************************************/

@isTest
private class CC_Test_TasksComponentController {
    @testSetup static void setupData() {
        List<Contact> lstContact = new List<Contact>();
        Integer iRecordSize = 200;
        for(Integer i = 0; i < iRecordSize; i++){
            Contact objContact = new Contact(LastName = 'Contact' + i);
            lstContact.add(objContact);
        }
        insert lstContact;
        List<Case> lstCase = new List<Case>();
        for(Integer i = 0; i < iRecordSize; i++){
                Case objCase = new Case(
                                Status = System.label.CC_Case_Status_Active
                                );
                lstCase.add(objCase);
        }
        insert lstCase;
        List<CC_Application__c> lstApp = new List<CC_Application__c>();
        for(Integer i = 0; i < iRecordSize; i++){
                CC_Application__c objApp = new CC_Application__c(
                                                CC_Individual__c = lstContact[i].Id,
                                                CC_Case__c = lstCase[i].Id
                                                                );
                lstApp.add(objApp);
        }
        insert lstApp;
        List<DT_Task__c> lstTask = new List<DT_Task__c>();
        Group objQueue = CC_TestDataFactory.createQueue();
        for(Integer i = 0; i < iRecordSize; i++){
                DT_Task__c objTask = new DT_Task__c(
                                        Name = 'Task' + i,
                                        DT_Status__c = DT_Constants.DT_TASK_STATUS_NEW,
                                        DT_Comments__c = 'Comment' + i,
                                        Contact__c = lstContact[i].Id,
                                        Case__c = lstCase[i].Id,
                                        OwnerId = objQueue.Id
                                                    );
                lstTask.add(objTask);
        }
        insert lstTask;
        CC_Master_Settings__c objSettings = new CC_Master_Settings__c(
                                                        Task_Dashboard_Page_Size__c = 10,
                                                        Task_Dashboard_Pages_Per_Screen__c = 10
                                                                    );
        insert objSettings;
    }
    
    @isTest static void testMethods() {
        String sQueueName = 'TestQueue';
        Test.startTest();
        Group ObjGroup = CC_Utility.getQueueInfo(sQueueName);
        System.debug('ObjGroup>>' + ObjGroup);
        System.assertEquals(ObjGroup.DeveloperName, sQueueName); 
        String sResult = CC_TasksComponentController.loadData(sQueueName, 'CreatedDate', 'DESC');
        System.debug('sResult|loadData>>' + sResult);
        System.assert(sResult.contains('CC_TASK_NAME'));
        sResult = CC_TasksComponentController.getMyTaskListAsString(ObjGroup.Id, 2, 'CreatedDate', 'DESC', '1', TRUE);
        System.debug('sResult|TaskListString>>' + sResult);
        System.assert(sResult.contains('Contact1'));
        Test.stopTest();
    }
}