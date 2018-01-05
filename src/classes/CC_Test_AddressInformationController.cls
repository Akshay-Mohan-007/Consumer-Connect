/***************************************************************************************************************************************
 * NAME   : CC_Test_AddressInformationController
 * DESCRIPTION  : Test Class for CC_AddressInformationController.
 *    
 * @AUTHOR   : Nidhin V K
 * @DATE   : 11-27-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               11-27-2017          Initial version        
 *
 ****************************************************************************************************************************************/

@isTest
private class CC_Test_AddressInformationController {
    @isTest static void testMethods() {
    	Test.startTest();
    	Map < String, List < String >> mapOptions = CC_AddressInformationController.getDependentOptions('Contact', 'CC_Mailing_Address_State__c', 'CC_Mailing_Address_County__c');
    	System.assert(mapOptions.size() > 0);
        Test.stopTest();
    }
}