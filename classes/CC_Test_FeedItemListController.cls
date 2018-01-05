@isTest
private class CC_Test_FeedItemListController {

	
	
	static testMethod void testFeedItemMethod() {
		String sCaseManagerProfId = [Select id,name from Profile where name='System Administrator'].Id;

		User SysAdm = new User(profileId = sCaseManagerProfId, username = 'tt@ff.com', email = 'pp@cc.com',
												emailencodingkey = 'UTF-8', localesidkey = 'en_US',
												languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
												alias='cspu', lastname='lastname');
		insert SysAdm;
		User CaseManager;
		System.runAs(SysAdm){		
			CaseManager = CC_TestDataFactory.getPortalUser(CC_TestDataFactory.PortalType.PowerCustomerSuccess,null,true);
		}
		System.debug('****CaseManager '+CaseManager);
		CC_TestDataFactory.createCustomSettingRecord();
		/*CC_Master_Settings__c objSettings = CC_Master_Settings__c.getInstance();
        objSettings.Feed_Records_Per_Page__c = 2;
        objSettings.Feed_Pages_Per_Screen__c = 1;
        insert objSettings;*/
		
		FeedItem feed = new FeedItem (ParentId = SysAdm.id,
									  Body = 'Hello');
		insert feed;

		FeedItem feed2 = new FeedItem (ParentId = SysAdm.id,
									  Body = 'Test Feed Data');
		insert feed2;

		 ContentVersion testContentInsert =new ContentVersion(); 
		 	testContentInsert.pathOnClient='DTE Codes.pdf'; 
			 testContentInsert.Title ='Google.com'; 
			 testContentInsert.versionData = Blob.valueOf('Unit Test Attachment Body');
			 //testContentInsert.RecordTypeId = ContentRT.Id; 
			 insert testContentInsert; 

		 ContentVersion testContentInsert2 =new ContentVersion(); 
		 	testContentInsert2.pathOnClient='DTE Codes.pdf'; 
			 testContentInsert2.Title ='Google.com'; 
			 testContentInsert2.versionData = Blob.valueOf('Unit Test Attachment Body'); 
			 insert testContentInsert2; 	 

		 FeedAttachment feedAttachment = new FeedAttachment();
	     	feedAttachment.FeedEntityId = feed.Id;
	        feedAttachment.RecordId = testContentInsert.id;
	        feedAttachment.Title = 'title';
	        feedAttachment.Type = 'CONTENT'; 
	        insert feedAttachment;

	     FeedAttachment feedAttachment2 = new FeedAttachment();
	     	feedAttachment2.FeedEntityId = feed2.Id;
	        feedAttachment2.RecordId = testContentInsert2.id;
	        feedAttachment2.Title = 'title';
	        feedAttachment2.Type = 'CONTENT'; 
	        insert feedAttachment2;

	        
		        String sLoadData = CC_FeedItemListController.loadData(feed.id);
		        String sPaginationData = CC_FeedItemListController.getFeedAsString(feed.id,1,false);
		        String sPaginationLastData = CC_FeedItemListController.getFeedAsString(feed.id,2,true);
	    }
	}