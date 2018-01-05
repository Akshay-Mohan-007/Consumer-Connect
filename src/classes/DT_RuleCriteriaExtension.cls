/* Class Name   : DT_RuleCriteriaExtension
 * Description  :    
 * Created By   : Nidhin V K
 * Created On   : 07-26-2016

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date        Modification ID      Description 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K            07-26-2016        1000            Initial ruleVersion
 * Debalina Chatterjee   09-29-2016        1001            RecordType population  
 *
 */
public with sharing class DT_RuleCriteriaExtension {
    
    public List<SelectOption> lstTaskFields{get; set;}
    
    public List<SelectOption> lstTargetObjectFields{get; set;}
    
    public List<SelectOption> lstOperators{get; set;}

    public Id selectedVal{get;set;}
    
    public Boolean bShowTask{get; set;}
    
    public Boolean bShowError{get; set;}

    public Boolean bShowValueCompare{get; set;}

    public Boolean bTaskType{get; set;}

    public Boolean bShowMapValue{get;set;}

    public Boolean bShowSourceField{get;set;}

    public Boolean bShowDueDate{get;set;}
    
    public DT_Rule_Criterion__c objRuleCriteria;

    public String sDaysToAdd{get;set;}
    
    DT_Rule_Version__c ruleVersion;
    
    public String selectedRTName;
    
    
    /* DT_RuleCriteriaExtension constructor does the basic functionalities like 
     * initialization of objects and get some needed data
     * Enable/Disable Buttons
     * Show/Hide fields
     * @params : controller
     */
    public DT_RuleCriteriaExtension(ApexPages.StandardController controller) {
        
        
        //Get the fileds which are not used in the Page
        if(!Test.isRunningTest())
            controller.addFields(new List<String>{DT_Constants.DT_FIELD_RULE_VERSION, DT_Constants.DT_FIELD_SL_NO});
        this.objRuleCriteria = (DT_Rule_Criterion__c)controller.getRecord();
        System.debug(objRuleCriteria);

        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('RecordType')) &&
            ApexPages.currentPage().getParameters().get('RecordType') != null){
            selectedVal = ApexPages.currentPage().getParameters().get('RecordType');
        }
        else{
            selectedVal = objRuleCriteria.RecordTypeId;
        }    

        System.debug('selectedVal' +selectedVal);

        lstTargetObjectFields = new List<SelectOption>();
        
        //Get the selected Rule details
        ruleVersion = [SELECT
                            Id,
                            DT_IsActive__c,
                            DT_Deactivated_Date__c,
                            DT_Rule__r.DT_Target_SObject_API_Name__c,
                            DT_Rule__r.DT_Rule_Type__c,
                            DT_Rule__r.DT_IsActive__c,
                            (
                                SELECT Id FROM DT_Rule_Criteria__r
                            )
                        FROM 
                            DT_Rule_Version__c
                        WHERE
                            Id =: objRuleCriteria.DT_Rule_Version__c];
                            
                            //System.debug('RuleVer--->' +DT_Rule_Version__c.DT_Rule__r.DT_Target_SObject_API_Name__c);
        
        //If active then show message while editing
        if(ruleVersion.DT_IsActive__c){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.DT_LABEL_DEACTIVATE_RULE));
            bShowError = true;
            return;
        } else if(ruleVersion.DT_Deactivated_Date__c != NULL){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You cannot edit the components once the Rule is deactivated. Please create a clone to use.'));
            bShowError = true;
            return;
        }

        if(ruleVersion.DT_Rule__r.DT_Rule_Type__c.equals(DT_Constants.DT_RULE_TYPE_TASK))
        {
            bTaskType = true;
            System.debug('<<task type>>'+ruleVersion.DT_Rule__r.DT_Rule_Type__c.equals(DT_Constants.DT_RULE_TYPE_TASK));

        }

        System.debug(bTaskType);
        
        System.debug('ruleVersion.DT_Rule__r.DT_Rule_Type__c : ' + ruleVersion.DT_Rule__r.DT_Rule_Type__c);
        
        //Populate Task Fields
        //lstTaskFields = new List<SelectOption>{new SelectOption(DT_Constants.DT_EMPTY, DT_Constants.DT_NONE)};
        lstTaskFields = new List<SelectOption>();
        lstTaskFields.addAll(populateSObjectFields(DT_Constants.DT_OBJECT_TASK));
        
        //Populate Target Sobejct Fields
        lstTargetObjectFields = populateSObjectFields(ruleVersion.DT_Rule__r.DT_Target_SObject_API_Name__c);
        
        Map<Id, Schema.RecordTypeInfo> mapRTbyId = Schema.SObjectType.DT_Rule_Criterion__c.getRecordTypeInfosById();
        if(mapRTbyId.containsKey(selectedVal)){ 
            Schema.RecordTypeInfo selectedRTInfo =  mapRTbyId.get(selectedVal);
            selectedRTName = selectedRTInfo.getName();
        }
        enableDisableTaskField();
        
    }
    
    /* enableDisableTaskField 
     * Action support method for enabling and disabling task and value compare field
     * @params : Not Applicable
     * @return : null
     */
    public PageReference enableDisableTaskField() {
        System.debug('selectedRTName>>' + selectedRTName);
        if(DT_Constants.DT_RECORD_TYPE_MAP_SOBJECT.equals(selectedRTName))
        {
            bShowTask = true;
            bShowMapValue = false;
            bShowValueCompare = false;
            bShowSourceField = true;
            bShowDueDate = false;

        }else if(DT_Constants.DT_RECORD_TYPE_COMPARE.equals(selectedRTName)){
            bShowTask = false;
            bShowMapValue = false;
            bShowValueCompare = true;
            bShowSourceField =true;
            bShowDueDate = false;

        }else if(DT_Constants.DT_RECORD_TYPE_MAP_STATIC.equals(selectedRTName)){
            bShowTask = true;
            bShowMapValue = true;
            bShowValueCompare = false;
            bShowSourceField = false;
            bShowDueDate = false;

            if(objRuleCriteria.DT_Target_Task_Field__c == DT_Constants.DT_FIELD_DUE_DATE){
                sDaysToAdd = objRuleCriteria.DT_Value_to_Map__c;
                bShowDueDate = true;
                bShowMapValue = false;
            }
        }

        return null;
    }

    /* populateSObjectFields 
     * Populate the sobject fileds based on the object API Name
     * @params : strObjName
     * @return : List<SelectOption> lstSObjectFields
     */
    public List<SelectOption> populateSObjectFields(String strObjName){
        
        List<SelectOption> lstSObjectFields = new List<SelectOption>(); 
        
        try {
        
            //Populate the sObject Fields
            System.debug('strObjName>>' + strObjName);
            Map<String, Schema.SObjectField> mapObjectFields 
                    = Schema.getGlobalDescribe().get(strObjName).getDescribe().fields.getMap();
            
            //Return all the fields
            for(Schema.SObjectField fld :mapObjectFields.values()){
                schema.describeFieldResult dfield = fld.getDescribe();
                if(dfield.isUpdateable()
                    && dfield.isCreateable()){
                    
                    String sFieldName = dfield.getName();
                    if(!DT_Constants.DT_RESTRICTED_FIELDS.contains(sFieldName))        
                        lstSObjectFields.add(new SelectOption(sFieldName, dfield.getLabel()));
                }
            }
        
        } catch(Exception ex){
            //throw error
            System.debug('Exception on Class : DT_RuleCriteriaExtension - populateSObjectFields, Error : ' 
                            + ex.getMessage() 
                            + ' Line Number : ' 
                            + ex.getLineNumber()
                            + ' Cause : '
                            + ex.getCause()
                            + ' Type : '
                            + ex.getTypeName());
            
            bShowError = true;             
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.DT_LABEL_CONTACT_ADMIN));

            DT_Error_Log.genericException(
                            ex.getMessage(),
                            DT_Constants.DT_ERROR_TYPE_BUSINESS_VALIDATION,
                            ex, 
                            DT_Constants.DT_CLASS_RULE_CRITERIA_EXTENSION,
                            DT_Constants.DT_METHOD_POPULATE_OBJECT_FIELDS,
                            objRuleCriteria.Id == NULL ? NULL : objRuleCriteria.Id,
                            DT_Constants.DT_EMPTY);
            return NULL;
        }
        
        return lstSObjectFields;
    }
    

    
    /* save 
     * Override save method to save the record with additional custom values
     * @params :
     * @return :
     */
    public PageReference save(){
        
        try{
            //Show error if sObject field is NULL
            if(String.isBlank(objRuleCriteria.DT_Source_SObject_Field__c) && (DT_Constants.DT_RECORD_TYPE_MAP_SOBJECT.equals(selectedRTName)
                                || DT_Constants.DT_RECORD_TYPE_COMPARE.equals(selectedRTName)) ){
                bShowError = true;             
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.DT_LABEL_NO_FIELDS_SELECTED));
                return NULL;
            }


            objRuleCriteria.RecordTypeId = selectedVal;
            
            if(DT_Constants.DT_RECORD_TYPE_MAP_STATIC.equals(selectedRTName)){
                objRuleCriteria.DT_Source_SObject_Field_Type__c = DT_Constants.DT_EMPTY;
                objRuleCriteria.DT_Source_SObject_Field__c = DT_Constants.DT_EMPTY;
                objRuleCriteria.DT_Value_To_Compare__c = DT_Constants.DT_EMPTY;
                objRuleCriteria.DT_Operator__c = DT_Constants.DT_EMPTY;

               if(objRuleCriteria.DT_Target_Task_Field__c == DT_Constants.DT_FIELD_DUE_DATE){
                    objRuleCriteria.DT_Value_to_Map__c = sDaysToAdd;
                }
            }
            else if(DT_Constants.DT_RECORD_TYPE_MAP_SOBJECT.equals(selectedRTName)){
                objRuleCriteria.DT_Value_to_Map__c = DT_Constants.DT_EMPTY;
                objRuleCriteria.DT_Value_To_Compare__c = DT_Constants.DT_EMPTY;
                objRuleCriteria.DT_Operator__c = DT_Constants.DT_EMPTY;

                //Populate the data type of the field
                Schema.DisplayType dType 
                    = Schema.getGlobalDescribe().get(ruleVersion.DT_Rule__r.DT_Target_SObject_API_Name__c)
                    .getDescribe().fields.getMap().get(objRuleCriteria.DT_Source_SObject_Field__c)
                    .getDescribe().getType();
            
                objRuleCriteria.DT_Source_SObject_Field_Type__c = dType.name();
            }
            else if(DT_Constants.DT_RECORD_TYPE_COMPARE.equals(selectedRTName)){

                //Populate the data type of the field
                Schema.DisplayType dType 
                    = Schema.getGlobalDescribe().get(ruleVersion.DT_Rule__r.DT_Target_SObject_API_Name__c)
                    .getDescribe().fields.getMap().get(objRuleCriteria.DT_Source_SObject_Field__c)
                    .getDescribe().getType();
            
                objRuleCriteria.DT_Source_SObject_Field_Type__c = dType.name();
                objRuleCriteria.DT_Value_to_Map__c = DT_Constants.DT_EMPTY;  
                
                //Get only the compare rule criterias
                List<DT_Rule_Criterion__c> lstCompareCriteria = [SELECT DT_Rule_Version__c, 
                                        DT_Serial_Number__c, 
                                        Id,
                                        RecordTypeId FROM DT_Rule_Criterion__c 
                                        WHERE DT_Rule_Version__c =: objRuleCriteria.DT_Rule_Version__c 
                                        AND RecordType.Name  =: DT_Constants.DT_RECORD_TYPE_COMPARE];
                
                System.debug('<<This block>>'+objRuleCriteria.DT_Serial_Number__c);
                
                if(objRuleCriteria.DT_Serial_Number__c == null){
                    //auto populate the serial number for Compare Record Type
                    Set<Integer> setSlNos = new Set<Integer>();
                    objRuleCriteria.DT_Serial_Number__c = 1;
                    
                    for(DT_Rule_Criterion__c objRC : lstCompareCriteria){
                        setSlNos.add(Integer.valueOf(objRC.DT_Serial_Number__c));
                    }
                    Integer num = 1;
                    while(setSlNos.contains(num)){
                        objRuleCriteria.DT_Serial_Number__c = ++num;
                    }  
                }  
                
            }

            System.debug('<<This block>>'+objRuleCriteria.DT_Serial_Number__c);

            upsert objRuleCriteria;

        } catch(Exception ex){
            //throw error
            System.debug('Exception on Class : DT_RuleCriteriaExtension - save, Error : ' 
                            + ex.getMessage() 
                            + ' Line Number : ' 
                            + ex.getLineNumber()
                            + ' Cause : '
                            + ex.getCause()
                            + ' Type : '
                            + ex.getTypeName());
            
            bShowError = true;             
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.DT_LABEL_CONTACT_ADMIN));

            DT_Error_Log.genericException(
                            ex.getMessage(),
                            DT_Constants.DT_ERROR_TYPE_BUSINESS_VALIDATION,
                            ex, 
                            DT_Constants.DT_CLASS_RULE_CRITERIA_EXTENSION,
                            DT_Constants.DT_METHOD_SAVE,
                            objRuleCriteria.Id == NULL ? NULL : objRuleCriteria.Id,
                            DT_Constants.DT_EMPTY);
            return NULL;
        }
        
        return new PageReference(DT_Constants.DT_URL_VIEW_RULE_VERSION + '?id=' + objRuleCriteria.DT_Rule_Version__c);
    }
    
    
    /* deleteCriteria 
     * Delete Criteria and redirect to Rule Version View VF Page
     * @params :
     * @return : PageReference
     */
    public PageReference deleteCriteria(){
        try{
            //delete if it is not null
            if(objRuleCriteria != NULL){
                delete objRuleCriteria;
            }
            return new PageReference(DT_Constants.DT_URL_VIEW_RULE_VERSION + '?id=' + objRuleCriteria.DT_Rule_Version__c);
        }catch(Exception ex){
            DT_Error_Log.genericException(
                            ex.getMessage(),
                            DT_Constants.DT_ERROR_TYPE_BUSINESS_VALIDATION,
                            ex, 
                            DT_Constants.DT_CLASS_RULE_CRITERIA_EXTENSION,
                            DT_Constants.DT_METHOD_DELETE_RULE,
                            objRuleCriteria.Id == NULL ? NULL : objRuleCriteria.Id,
                            DT_Constants.DT_EMPTY);
            return null;
        }
    }

}