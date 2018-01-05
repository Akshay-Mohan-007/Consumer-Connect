/***************************************************************************************************************************************
 * NAME   : CC_AccountTriggerHelper
 * DESCRIPTION  : Helper class for Account Trigger
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
 public without sharing class CC_AccountTriggerHelper {

 	
 	public static void afterInsert(Map<ID,Account> mapAccounts){
 		
 		List<AccountShare> lstShare = new List<AccountShare>();
 		Set<ID> setUsers = CC_Utility.getExternalUsersForSharing(); 
 		AccountShare shareAccount;
 		Boolean bApexSharingUser,bRecordTypeSatisfied;
 		String sIndivRecordTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_ACCOUNT_OBJ,CC_Constants.CC_ACCOUNT_INDIVIDUAL_RECORD_TYPE);
 		for(Account objAccount: mapAccounts.values()){
 			bApexSharingUser = setUsers.contains(objAccount.CreatedById);
 			bRecordTypeSatisfied = objAccount.RecordTypeId == sIndivRecordTypeId;
 			System.debug('Profile satisfied for apex sharing: '+bApexSharingUser);
 			System.debug('Record Type satisfied for apex sharing: '+bRecordTypeSatisfied);
 			if(!bApexSharingUser || !bRecordTypeSatisfied)
 				continue;
 			shareAccount= new AccountShare() ;
	 		shareAccount.userorgroupid = objAccount.CreatedById;
			shareAccount.accountid = objAccount.ID;
			shareAccount.accountaccesslevel = CC_Constants.CC_SHAE_ACCESS_EDIT;
			shareAccount.OpportunityAccessLevel = CC_Constants.CC_SHAE_ACCESS_NONE;
			shareAccount.CaseAccessLevel = CC_Constants.CC_SHAE_ACCESS_EDIT;
			System.debug('shareAccount: ' + shareAccount);
			lstShare.add(shareAccount);

 		}
 		
 		if(!lstShare.isEmpty())
 			insert lstShare;
 	}

}