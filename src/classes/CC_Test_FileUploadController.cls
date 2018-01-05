/***************************************************************************************************************************************
* NAME   : CC_Test_FileUploadController
* DESCRIPTION  : File Upload Controller Test class
*    
* @AUTHOR   : Akshay Mohan
* @DATE   : 11-06-2017
*
* MODIFICATION LOG:  
* --------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER				DATE				DESCRIPTION 
* --------------------------------------------------------------------------------------------------------------------------------------
* Akshay Mohan				11-06-2017			Initial version    
* Debalina                  12-14-2017          added uploadMultipleDocUrgency for coverage of CC_UrgencyDocUpload_Validator         
****************************************************************************************************************************************/
@isTest
public class CC_Test_FileUploadController {
    public static String sAppId;
    @testSetup//set up contact and application
    public static void setUpData() {
        sAppId = CC_TestDataFactory.createNewIndividualApp('Test Guy','Male','123456789',Date.newInstance(1999, 10 , 21))[2];
        System.debug('sAppId: ' + sAppId);
    }
    
    public static ContentDocumentLink createDocLink(String sDocId,String sLinkId,String sShare,String sVisbility){
        return new ContentDocumentLink(ContentDocumentId =	sDocId,LinkedEntityId = sLinkId, ShareType = sShare,
                                       Visibility =sVisbility);
    }
    
    @isTest
    public static void loadBlankDocuments() {
        List<CC_Application__c> lstApp = [SELECT ID FROM CC_Application__c];
        System.debug('lstApp: ' + lstApp);
        sAppId = lstApp[0].Id;
        
        Test.startTest();
        CC_FileUpload_Controller.DocumentWrapper wrapDoc = new CC_FileUpload_Controller.DocumentWrapper();
        CC_FileUpload_Controller.loadData(sAppId, 'Application__c', 'CC_ApplicationDocumentUpload_Validator', CC_Constants.CC_MODULE_MDT_APPLICATION);
        String sLoadJSON = CC_FileUpload_Controller.refreshDocumentGrid(sAppId, 'Application__c', 'CC_ApplicationDocumentUpload_Validator');
        Test.stopTest();
        String sJSONPrefix = '{ "lstDocs" : ',sJSONSuffix = ', "lstReqDocs" : ';
        String sJSON = sLoadJSON.substring(sLoadJSON.indexOf(sJSONPrefix)+sJSONPrefix.length(),sLoadJSON.indexOf(sJSONSuffix));
        System.debug('sJSON: ' + sJSON);
        List<CC_FileUpload_Controller.DocumentWrapper> lstDocs = (List<CC_FileUpload_Controller.DocumentWrapper>) JSON.deserialize(sJSON, List<CC_FileUpload_Controller.DocumentWrapper>.class);
        System.debug('lstDocs: ' + lstDocs);
        System.assert(lstDocs.isEmpty(),'Documents found without uploading!');
    }

    @isTest
    public static void loadDocuments() {
        List<CC_Application__c> lstApp = [SELECT ID FROM CC_Application__c];
        System.debug('lstApp: ' + lstApp);
        sAppId = lstApp[0].Id;
        ContentVersion objCV = new ContentVersion(Title = 'TestDoc',PathOnClient = 'Pic.jpg',
                                                             VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert objCV;
        objCV = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :objCV.Id];
        System.debug('objCV: ' + objCV);
        
        CC_FileUpload_Controller.DocumentWrapper wrapDoc = new CC_FileUpload_Controller.DocumentWrapper();
        wrapDoc.sDocName='Legal Guardian Proof';
        wrapDoc.sComments='Upload Test';
        String sId = CC_FileUpload_Controller.saveDocumentDetail(sAppId, 'Application__c', JSON.serialize(wrapDoc));
        insert createDocLink(objCV.ContentDocumentId, sId,'V','AllUsers');
        CC_FileUpload_Controller.setPageVisited(sAppId, 'CC_ApplicationDocumentUpload_Validator');
        Test.startTest();
        CC_FileUpload_Controller.loadData(sAppId, 'Application__c', 'CC_ApplicationDocumentUpload_Validator', CC_Constants.CC_MODULE_MDT_APPLICATION);
        String sLoadJSON = CC_FileUpload_Controller.refreshDocumentGrid(sAppId, 'Application__c', 'CC_ApplicationDocumentUpload_Validator');
        Test.stopTest();

        String sJSONPrefix = '{ "lstDocs" : ',sJSONSuffix = ', "lstReqDocs" : ';
        String sJSON = sLoadJSON.substring(sLoadJSON.indexOf(sJSONPrefix)+sJSONPrefix.length(),sLoadJSON.indexOf(sJSONSuffix));
        System.debug('sJSON: ' + sJSON);
        List<CC_FileUpload_Controller.DocumentWrapper> lstDocs = (List<CC_FileUpload_Controller.DocumentWrapper>) JSON.deserialize(sJSON, List<CC_FileUpload_Controller.DocumentWrapper>.class);
        System.debug('lstDocs: ' + lstDocs);
        System.assert(!lstDocs.isEmpty(),'Documents not found after uploading!');
    }

    @isTest
    public static void loadDocumentsWithValidations() {
        List<CC_Application__c> lstApp = [SELECT ID FROM CC_Application__c];
        System.debug('lstApp: ' + lstApp);
        sAppId = lstApp[0].Id;
        CC_Application__c objApp = new CC_Application__c(ID = sAppId, CC_Does_Individual_have_Auth_Rep__c=true,CC_individual_have_LegalGuardian__c= true, 
                                                         CC_Where_does_the_individual_live__c =System.Label.CC_Application_Living_Currently_PF);
        update objApp;
        ContentVersion objCV = new ContentVersion(Title = 'TestDoc',PathOnClient = 'Pic.jpg',
                                                             VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert objCV;
        objCV = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :objCV.Id];
        System.debug('objCV: ' + objCV);
        
        CC_FileUpload_Controller.DocumentWrapper wrapDoc = new CC_FileUpload_Controller.DocumentWrapper();
        wrapDoc.sDocName='Legal Guardian Proof';
        wrapDoc.sComments='Upload Test';
        String sId = CC_FileUpload_Controller.saveDocumentDetail(sAppId, 'Application__c', JSON.serialize(wrapDoc));
        Test.startTest();
        String sLoadJSON = CC_FileUpload_Controller.loadData(sAppId, 'Application__c', 'CC_ApplicationDocumentUpload_Validator', CC_Constants.CC_MODULE_MDT_APPLICATION);
        insert createDocLink(objCV.ContentDocumentId, sId,'V','AllUsers');
        String refreshJSON =  CC_FileUpload_Controller.refreshDocumentGrid(sAppId, 'Application__c', 'CC_ApplicationDocumentUpload_Validator');
        Test.stopTest();

        String sJSONPrefix = ', "lstReqDocs" : ',sJSONSuffix = ', "wrapDummyDoc" : ';
        String sJSON = sLoadJSON.substring(sLoadJSON.indexOf(sJSONPrefix)+sJSONPrefix.length(),sLoadJSON.indexOf(sJSONSuffix));
        System.debug('sJSON: ' + sJSON);
        List<CC_FileUpload_Controller.RequiredDocumentWrapper> lstReqDocs = (List<CC_FileUpload_Controller.RequiredDocumentWrapper>) JSON.deserialize(sJSON, List<CC_FileUpload_Controller.RequiredDocumentWrapper>.class);
        System.debug('lstReqDocs: ' + lstReqDocs);
        System.assert(!lstReqDocs.isEmpty(),'Required documents not calculating!');
        System.assertEquals(lstReqDocs.size(),3,'Correct Required documents not calculated!');
        Boolean bFound = false;
        for(CC_FileUpload_Controller.RequiredDocumentWrapper wrapReqDoc : lstReqDocs)
            if(wrapReqDoc.bUploaded){
                bFound = true;
                break;
            }
        System.assert(!bFound,'Without uploading doc uploaded being set!');
        sJSON = refreshJSON.substring(refreshJSON.indexOf(sJSONPrefix)+sJSONPrefix.length(),refreshJSON.indexOf(sJSONSuffix));
        System.debug('sJSON: ' + sJSON);
        lstReqDocs = (List<CC_FileUpload_Controller.RequiredDocumentWrapper>) JSON.deserialize(sJSON, List<CC_FileUpload_Controller.RequiredDocumentWrapper>.class);
        System.debug('lstReqDocs: ' + lstReqDocs);
        System.assert(!lstReqDocs.isEmpty(),'Required documents not calculating!');
        System.assertEquals(lstReqDocs.size(),3,'Correct Required documents not calculated!');
        bFound = false;
        for(CC_FileUpload_Controller.RequiredDocumentWrapper wrapReqDoc : lstReqDocs)
            if(wrapReqDoc.bUploaded){
                bFound = true;
                break;
            }
        System.assert(bFound,'After uploading doc uploaded not being set!');
        
    }

    @isTest
    public static void uploadMultipleDocuments() {
        List<CC_Application__c> lstApp = [SELECT ID FROM CC_Application__c];
        System.debug('lstApp: ' + lstApp);
        sAppId = lstApp[0].Id;
        CC_Application__c objApp = new CC_Application__c(ID = sAppId, CC_Does_Individual_have_Auth_Rep__c=true,CC_individual_have_LegalGuardian__c= true, 
                                                         CC_Where_does_the_individual_live__c =System.Label.CC_Application_Living_Currently_PF);
        update objApp;
        ContentVersion objCV = new ContentVersion(Title = 'TestDoc',PathOnClient = 'Pic.jpg',
                                                             VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert objCV;
        objCV = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :objCV.Id];
        System.debug('objCV: ' + objCV);
        
        Test.startTest();
        CC_FileUpload_Controller.DocumentWrapper wrapDoc = new CC_FileUpload_Controller.DocumentWrapper();
        wrapDoc.sDocName='Legal Guardian Proof';
        wrapDoc.sComments='Upload Test';
        String sId = CC_FileUpload_Controller.saveDocumentDetail(sAppId, 'Application__c', JSON.serialize(wrapDoc));
        insert createDocLink(objCV.ContentDocumentId, sId,'V','AllUsers');
        CC_FileUpload_Controller.loadData(sAppId, 'Application__c', 'CC_ApplicationDocumentUpload_Validator', CC_Constants.CC_MODULE_MDT_APPLICATION);
        
        objCV = new ContentVersion(Title = 'TestDoc2',PathOnClient = 'Pic.jpg',
                                                             VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert objCV;
        objCV = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :objCV.Id];
        insert createDocLink(objCV.ContentDocumentId, sId,'V','AllUsers');
        String sLoadJSON = CC_FileUpload_Controller.refreshDocumentGrid(sAppId, 'Application__c', 'CC_ApplicationDocumentUpload_Validator');
        List<String> lstIds = new List<String>();
        lstIds.add(sId);
        CC_FileUpload_Controller.deleteDocumentDetail(JSON.serialize(lstIds));
        CC_FileUpload_Controller.refreshDocumentGrid(sAppId, 'Application__c', 'CC_ApplicationDocumentUpload_Validator');
        Test.stopTest();

        String sJSONPrefix = '{ "lstDocs" : ',sJSONSuffix = ', "lstReqDocs" : ';
        String sJSON = sLoadJSON.substring(sLoadJSON.indexOf(sJSONPrefix)+sJSONPrefix.length(),sLoadJSON.indexOf(sJSONSuffix));
        System.debug('sJSON: ' + sJSON);
        List<CC_FileUpload_Controller.DocumentWrapper> lstDocs = (List<CC_FileUpload_Controller.DocumentWrapper>) JSON.deserialize(sJSON, List<CC_FileUpload_Controller.DocumentWrapper>.class);
        System.debug('lstDocs: ' + lstDocs);
        System.assert(!lstDocs.isEmpty(),'Documents not found after uploading!');
    }


    // Start Debalina 14th Dec,2017
     @isTest
    public static void uploadMultipleDocUrgency() {
        List<CC_Application__c> lstApp = [SELECT ID FROM CC_Application__c];
        System.debug('lstApp: ' + lstApp);
        sAppId = lstApp[0].Id;

        String sAppDetailTypeId = CC_Utility.getRecordTypeId(CC_Constants.CC_APP_DETAIL_OBJ, System.label.CC_RT_Waiver_AppDetail);
        CC_Application_Detail__c objAppDetail = new CC_Application_Detail__c();
        objAppDetail.Related_Application__c = sAppId;
        objAppDetail.RecordTypeId = sAppDetailTypeId;
        insert objAppDetail;

        ContentVersion objCV = new ContentVersion(Title = 'TestDoc',PathOnClient = 'Pic.jpg',
                                                             VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert objCV;
        objCV = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :objCV.Id];
        System.debug('objCV: ' + objCV);
        
        Test.startTest();
        CC_FileUpload_Controller.DocumentWrapper wrapDoc = new CC_FileUpload_Controller.DocumentWrapper();
        wrapDoc.sDocName='Urgency Request form';
        wrapDoc.sComments='Upload Test';
        String sId = CC_FileUpload_Controller.saveDocumentDetail(objAppDetail.Id, 'Application_Detail__c', JSON.serialize(wrapDoc));
        
        insert createDocLink(objCV.ContentDocumentId, sId,'V','AllUsers');
        CC_FileUpload_Controller.loadData(objAppDetail.Id, 'Application_Detail__c', 'CC_UrgencyDocUpload_Validator', CC_Constants.CC_MODULE_MDT_CAPACITY_REVIEW);
        
        objCV = new ContentVersion(Title = 'TestDoc2',PathOnClient = 'Pic.jpg',
                                                             VersionData = Blob.valueOf('Test Content'),IsMajorVersion = true);
        insert objCV;
        objCV = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :objCV.Id];
        insert createDocLink(objCV.ContentDocumentId, sId,'V','AllUsers');
        String sLoadJSON = CC_FileUpload_Controller.refreshDocumentGrid(objAppDetail.Id, 'Application_Detail__c', 'CC_UrgencyDocUpload_Validator');
        List<String> lstIds = new List<String>();
        lstIds.add(sId);
        CC_FileUpload_Controller.deleteDocumentDetail(JSON.serialize(lstIds));
        CC_FileUpload_Controller.refreshDocumentGrid(objAppDetail.Id, 'Application_Detail__c', 'CC_UrgencyDocUpload_Validator');
        Test.stopTest();

        String sJSONPrefix = '{ "lstDocs" : ',sJSONSuffix = ', "lstReqDocs" : ';
        String sJSON = sLoadJSON.substring(sLoadJSON.indexOf(sJSONPrefix)+sJSONPrefix.length(),sLoadJSON.indexOf(sJSONSuffix));
        System.debug('sJSON: ' + sJSON);
        List<CC_FileUpload_Controller.DocumentWrapper> lstDocs = (List<CC_FileUpload_Controller.DocumentWrapper>) JSON.deserialize(sJSON, List<CC_FileUpload_Controller.DocumentWrapper>.class);
        System.debug('lstDocs: ' + lstDocs);
        System.assert(!lstDocs.isEmpty(),'Documents not found after uploading!');
    }
}