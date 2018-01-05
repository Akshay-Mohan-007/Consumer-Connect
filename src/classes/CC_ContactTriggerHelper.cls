/***************************************************************************************************************************************
 * NAME   : CC_ContactTriggerHelper
 * DESCRIPTION  : Helper class for Contact Trigger
 *    
 * @AUTHOR   : Akshay Mohan
 * @DATE   : 13-Nov-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER				DATE				DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Akshay Mohan				13-Nov-2017			Initial version        
 ****************************************************************************************************************************************/
public without sharing class CC_ContactTriggerHelper {

	public static void afterInsert(Map<ID,Contact> mapContacts){
		List<ContactShare> lstShare = new List<ContactShare>();
 		Set<ID> setUsers = CC_Utility.getExternalUsersForSharing(); 
 		ContactShare shareContact;
 		Boolean bApexSharingUser,bRecordTypeSatisfied;
 		String sExtRecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_CONTACT_OBJ,CC_Constants.CC_CONTACT_EXTERNAL_RECORD_TYPE);
 		for(Contact objContact: mapContacts.values()){
 			bApexSharingUser = setUsers.contains(objContact.CreatedById);
 			bRecordTypeSatisfied = objContact.RecordTypeId != sExtRecordTypeId;
 			System.debug('Profile satisfied for apex sharing: '+bApexSharingUser);
 			System.debug('Record Type satisfied for apex sharing: '+bRecordTypeSatisfied);
 			if(!bApexSharingUser || !bRecordTypeSatisfied)
 				continue;
 			shareContact= new ContactShare() ;
	 		shareContact.userorgroupid = objContact.CreatedById;
			shareContact.ContactId = objContact.ID;
			shareContact.ContactAccessLevel = CC_Constants.CC_SHAE_ACCESS_EDIT;
			System.debug('shareContact: ' + shareContact);
			lstShare.add(shareContact);
 		}
 		System.debug('lstShare: ' + lstShare);
 		if(!lstShare.isEmpty())
 			insert lstShare;
	}
}