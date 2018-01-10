/* Class Name   : DT_RuleExtension
 * Description  :    
 * Created By   : Nidhin V K
 * Created On   : 07-28-2016

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date        Modification ID      Description 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K            07-28-2016        1000            Initial version
 * Debalina Chatterjee   10-03-2016        1001            Target Objects are relationship objects of DT_Task__c
 *
 */
public with sharing class DT_RuleExtension {
    
    public List<SelectOption> lstTargetObjects{get; set;}
    
    public DT_Rule__c objRule;
    
    public Boolean bShowError{get; set;}
    
    public Boolean bAllowEditSobj{get; set;}
    
    
    /* DT_RuleExtension constructor does the basic functionalities like 
     * initialization of objects and get some needed data
     * Enable/Disable Buttons
     * Show/Hide fields
     * @params : controller - Apex Standard Controller
     * @return : null
     */
    public DT_RuleExtension(ApexPages.StandardController controller) {
        
        //Get the fields which are not used in the Page
        if(!Test.isRunningTest())
        	controller.addFields(new List<String>{System.Label.DT_FIELD_IS_ACTIVE});
        this.objRule = (DT_Rule__c)controller.getRecord();
        //If active then show message while editing
        if(objRule.DT_IsActive__c){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.DT_LABEL_DEACTIVATE_RULE_EDIT));
            bShowError = true;
            return;
        }
        
        //If rule is new allow some fields editable
        if(objRule.Id == NULL){
            bAllowEditSobj = true;
        }
        lstTargetObjects = populateSObjects();
    }
    
    
    /* populateSObjects 
     * Populate the sobject based in the Org
     * @params : null
     * @return : List<SelectOption> - lstOptions to populate list of sObjects
     */
    public List<SelectOption> populateSObjects(){
     
        List<String> lstOptionsLabel = new List<String>();
        List<SelectOption> lstOptions = new List<SelectOption>();
        Map<String, SelectOption> mapOptions = new Map<String, SelectOption>();
        //get all the sobjects
        List<Schema.SObjectType> lstGblDescribe = Schema.getGlobalDescribe().values();

        //Filter the Objects
        for(Schema.SObjectType sobjType : lstGblDescribe){
            Schema.DescribeSobjectResult sObj = sobjType.getDescribe();
            if(sObj.isAccessible() && sObj.isCreateable() && sObj.isUpdateable()){
                lstOptionsLabel.add(sObj.getLabel() + sObj.getName());
                mapOptions.put(sObj.getLabel() + sObj.getName(), new SelectOption(sObj.getName(), sObj.getLabel() + ' (' + sObj.getName() + ')'));
            }
        }
        lstOptionsLabel.sort();
        for(String key : lstOptionsLabel){
            lstOptions.add(mapOptions.get(key));
        }
        return lstOptions;
    }
    
    
    /* cancel 
     * Override cancel method to Redirect to Rule list if creating new record
     * else redirect to newly created record
     * @params :
     * @return :
     */
    public PageReference cancel(){
        //Redirect to Rule list if creating new record
        if(objRule != NULL && objRule.Id == NULL){
            return new PageReference(System.Label.DT_URL_VIEW_RULE_LIST);
        }
        //else redirect to newly created record
        return new PageReference('/' + objRule.Id);
    }
    
    
    /* toggleActivate 
     * Activate/Deactivate the Rule
     * @params :
     * @return :
     */    
    public PageReference toggleActivate(){

        //Allow activation only if there is an active rule version
        if(objRule != NULL && objRule.Id != NULL && objRule.DT_IsActive__c == false){
            AggregateResult agResult = [SELECT
                                            Count(Id) versionCount
                                        FROM
                                            DT_Rule_Version__c
                                        WHERE
                                            DT_Rule__r.Id = :objRule.Id
                                        AND
                                            DT_IsActive__c = true];

            
            if(Integer.valueOf(agResult.get('versionCount')) != 1){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.DT_LABEL_NO_ACTIVE_RULE_VERSION));
                bShowError = true;
                return NULL;
            }                                      
        }
        
        //toggle activation
        bShowError = objRule.DT_IsActive__c = objRule.DT_IsActive__c ? false : true;
        
        //update rule
        try{
            update objRule;
        } catch(Exception ex){
            //throw error
            System.debug('Exception on Class : DT_RuleExtension - toggleActivate, Error : ' 
                            + ex.getMessage() 
                            + ' Line Number : ' 
                            + ex.getLineNumber()
                            + ' Cause : '
                            + ex.getCause()
                            + ' Type : '
                            + ex.getTypeName());
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.DT_LABEL_CONTACT_ADMIN));
            bShowError = true;                
            
            DT_Error_Log.genericException(
                            ex.getMessage(),
                            System.Label.DT_ERROR_TYPE_BUSINESS_VALIDATION,
                            ex, 
                            System.Label.DT_CLASS_RULE_EXTENSION,
                            System.Label.DT_METHOD_TOGGLE_ACTIVATE,
                            objRule.Id == NULL ? NULL : objRule.Id,
                            DT_Constants.DT_EMPTY);
            return NULL;
        }
        return NULL;
    }
    
    
    /* deleteRule 
     * Delete Rule and redirect to Rule List View VF Page
     * @params :
     * @return : PageReference
     */
    public PageReference deleteRule(){
        try{
            //delete if not null
            if(objRule != NULL){
                delete objRule;
            }
            return new PageReference(System.Label.DT_URL_VIEW_RULE_LIST);
        }catch(Exception ex){
            DT_Error_Log.genericException(
                            ex.getMessage(),
                            System.Label.DT_ERROR_TYPE_BUSINESS_VALIDATION,
                            ex, 
                            System.Label.DT_CLASS_RULE_EXTENSION,
                            System.Label.DT_METHOD_DELETE_RULE,
                            objRule.Id == NULL ? NULL : objRule.Id,
                            DT_Constants.DT_EMPTY);
            return null;
        }
    }
}