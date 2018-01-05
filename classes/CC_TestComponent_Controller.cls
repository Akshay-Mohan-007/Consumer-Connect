/***************************************************************************************************************************************
 * NAME   : CC_TestComponent_Controller
 * DESCRIPTION  : for CC_TestComponent_Controller 
 *    
 * @AUTHOR   : Akshay Mohan
 * @DATE   : 11-04-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Debalina				  11-04-2017			Initial version        
 *
 ****************************************************************************************************************************************/

public with sharing class CC_TestComponent_Controller {
	
	/* loadData 
    * Gets the data required to load the test component
    *
    * @return : a JSON of the page data
    */
	@AuraEnabled
	public static String loadData() {
		
		Map<String,String> mapLabels = new Map<String,String>();
		mapLabels.put('CC_Phone_Type',System.Label.CC_Phone_Type);
		mapLabels.put('CC_Phone_Number',System.Label.CC_Phone_Number);
		mapLabels.put('CC_Phone_Confirmation',System.Label.CC_Phone_Confirmation);
		mapLabels.put('CC_Error_Phone_Type_Missing',System.Label.CC_Error_Phone_Type_Missing);
		mapLabels.put('CC_Error_Phone_No_Missing',System.Label.CC_Error_Phone_No_Missing);
		mapLabels.put('CC_Error_Phone_Confirm_Missing',System.Label.CC_Error_Phone_Confirm_Missing);
		mapLabels.put('CC_Error_Phone_Not_Matching',System.Label.CC_Error_Phone_Not_Matching);
		mapLabels.put('CC_Error_Phone_Format',System.Label.CC_Error_Phone_Format);

		System.debug('mapLabels: ' + mapLabels);

		Map<String, Schema.SObjectField> mapContactFields = CC_Utility.getFieldMap(CC_Constants.CC_CONTACT_OBJ);

		return '{"lstMainPhoneTypes" : '+JSON.serialize(CC_Utility.getPicklistValuesWrapper(mapContactFields, CC_Constants.CC_CONTACT_MAIN_PHN_TYPE, 
																							System.Label.CC_Select_Main_Phone_Type))
				+', "lstOtherPhoneTypes" : '+JSON.serialize(CC_Utility.getPicklistValuesWrapper(mapContactFields, CC_Constants.CC_CONTACT_OTHER_PHN_TYPE, 
																							System.Label.CC_Select_Other_Phone_Type))
				+', "mapLabels" : '+JSON.serialize(mapLabels)+'}';
	}

}