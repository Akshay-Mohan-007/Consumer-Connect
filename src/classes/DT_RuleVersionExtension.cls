/* Class Name   : DT_RuleVersionExtension
 * Description  :    
 * Created By   : Nidhin V K
 * Created On   : 07-28-2016

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date        Modification ID      Description 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K            07-28-2016        1000            Initial version
 * Debalina Chatterjee   09-22-2016        1001            Updated for displaying queue in Task rule version
 * Arya Parvathy         10-04-2016        1002            Made updates for enhanced task framework
 * Nidhin V K            12-Dec-2017       1003            CHanged manual picklist values to populate
 *
 */
public with sharing class DT_RuleVersionExtension {
    
    public List<SelectOption> lstQueues{get; set;}
    public List<SelectOption> lstAssignees{get; set;}
    public Boolean bShowQueue{get; set;}
    public Boolean bShowAssigneeType{get; set;}
    public Boolean bShowError{get; set;}
    public Boolean bError{get; set;}
    public Boolean bShowAssignees{get; set;}
    public DT_Rule_Version__c objRuleVer; //ruleVersion
    
    /* DT_RuleVersionExtensions 
     * constructor does the basic functionalities like checking Rule Type to show and hide Email/Queue fields
     * @params : ApexPages controller
     * @return : null
     */
    public DT_RuleVersionExtension(ApexPages.StandardController controller) { 
        if(!Test.isRunningTest())
        	controller.addFields(new List<String>{System.Label.DT_FIELD_RULE, System.Label.DT_FIELD_IS_ACTIVE, DT_Constants.DT_FIELD_DEACTIVATED_DATE });
        this.objRuleVer = (DT_Rule_Version__c)controller.getRecord();
        
        DT_Rule__c objRule = [SELECT id, 
                                  DT_Target_SObject_API_Name__c, 
                                  DT_Rule_Type__c,DT_IsActive__c 
                              FROM 
                                  DT_Rule__c 
                              WHERE 
                                  id=:objRuleVer.DT_Rule__c];

        AggregateResult arCriteria = [SELECT 
                                            Count(Id) RecordCount 
                                      FROM 
                                            DT_Rule_Version__c 
                                      WHERE 
                                            DT_Rule__c=:objRule.Id];
        
        if(String.isBlank(objRuleVer.Id)){
            objRuleVer.DT_Version_Number__c= Integer.valueOf(arCriteria.get('RecordCount')) + 1;
        } else if(objRuleVer.DT_Deactivated_Date__c != NULL){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You cannot edit the Rule Version once deactivated. Please revise it.'));
            bShowError = true;
        }
        
        if(objRuleVer.DT_IsActive__c){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You cannot edit the Rule Version once activated. Please revise or deactivate it.'));
            bShowError = true;
        }
        // hide fields based on Assignment Type
        if(String.isNotBlank(objRuleVer.DT_Assignment_Type__c)){
        	if(objRuleVer.DT_Assignment_Type__c.equals(System.Label.DT_RULE_VER_TYPE_MANUAL)){
        		bShowAssigneeType = true;
            	bShowQueue = false;
            	if(String.isNotBlank(objRuleVer.DT_Assignee__c)){
            		bShowAssignees = true;
            		if(objRuleVer.DT_Assignee__c.equals(DT_Constants.DT_ASSIGNEE_TYPE_TASK)){
        				lstAssignees = populateAssignees(DT_Constants.DT_FIELD_TASK_NAME);
            		} else if(objRuleVer.DT_Assignee__c.equals(DT_Constants.DT_ASSIGNEE_TYPE_MODULE)){
            			lstAssignees = populateAssignees(DT_Constants.DT_FIELD_MODULE);
            		} else{
            			bShowAssignees = false;
            		}
            	}
        	} else{
        		bShowQueue = true;
            	bShowAssigneeType = false;
        		lstQueues = populateQueues();
        	}
        }
    }
    
    /* onChangeAssignmentType 
     * on Change of AssignmentType
     * @params : 
     * @return : 
     */
    public void onChangeAssignmentType(){
    	if(String.isNotBlank(objRuleVer.DT_Assignment_Type__c)){
	    	if(objRuleVer.DT_Assignment_Type__c.equals(System.Label.DT_RULE_VER_TYPE_MANUAL)){
	    		bShowAssigneeType = true;
	        	bShowQueue = false;
	        	objRuleVer.DT_Assignee__c = DT_Constants.DT_ASSIGN_BACK_TO_PERSON;
	    	} else{
	    		bShowQueue = true;
	        	bShowAssigneeType = false;
	    		lstQueues = populateQueues();
	    	}
    	}
    }
    
    /* onChangeAssignmentType 
     * on Change of AssignmentType
     * @params : 
     * @return : 
     */
    public void onChangeAssigneeType(){
    	if(String.isNotBlank(objRuleVer.DT_Assignee__c)){
    		bShowAssignees = true;
    		if(objRuleVer.DT_Assignee__c.equals(DT_Constants.DT_ASSIGNEE_TYPE_TASK)){
				lstAssignees = populateAssignees(DT_Constants.DT_FIELD_TASK_NAME);
    		} else if(objRuleVer.DT_Assignee__c.equals(DT_Constants.DT_ASSIGNEE_TYPE_MODULE)){
    			lstAssignees = populateAssignees(DT_Constants.DT_FIELD_MODULE);
    		} else{
    			bShowAssignees = false;
    		}
    	}
    }

    /* toggleActivate 
     * method to Activate/ Deactivate a Rule Version
     * @params : null
     * @return : PageReference of Rule Version page
     */
    public PageReference toggleActivate(){
        try{
        	bError = false;
            if(objRuleVer != NULL){
                Integer iCount = [SELECT
	                                    Count()                                         
	                                FROM
	                                    DT_Rule_Criterion__c
	                                WHERE
	                                    DT_Rule_Version__c = :objRuleVer.Id];
                
                DT_Rule_Version__c  objVersion = [SELECT
                                                    Id,
                                                    DT_Rule__r.DT_IsActive__c
                                                FROM
                                                    DT_Rule_Version__c 
                                                WHERE
                                                    Id = :objRuleVer.Id];
                System.debug('iCount>>' + iCount);
                System.debug('objVersion>>' + objVersion);
                if(iCount < 1){ // Check if Rule Version has atleast one criteria
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.DT_LABEL_NO_CRITERIA_FOUND));
                    bShowError = true;
                    bError = true;
                    return null;
                }
                if(objVersion.DT_Rule__r.DT_IsActive__c == true){ //Check if Rule is Active
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.DT_LABEL_DEACTIVATE_RULE));
                    bShowError = true;
                    bError = true;
                    return null;
                }                                           
            }
            System.debug('bError>>' + bError);
            if(bError == false){
                objRuleVer.DT_IsActive__c = objRuleVer.DT_IsActive__c ? false : true;
                if(objRuleVer.DT_IsActive__c){
            		System.debug('objRuleVer.DT_IsActive__c>>' + objRuleVer.DT_IsActive__c);
                    if(String.isBlank(objRuleVer.DT_Criteria_Logic__c)){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide the Criteria Logic.'));
                        bShowError = true;
                        objRuleVer.DT_IsActive__c = false;
                    } else{
                        if(DT_Util.checkCriteriaLogic(objRuleVer)){
                            objRuleVer.DT_Activated_Date__c = DateTime.now();
                        } else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Wrong Criteria Logic.'));
                            bShowError = true;
                            objRuleVer.DT_IsActive__c = false;
                        }
                    }
                } else{
                    objRuleVer.DT_Deactivated_Date__c = DateTime.now();
                }
                update objRuleVer;
                return NULL;
            }
            return NULL;
        }catch(Exception ex){
            //throw error
            String sId = DT_Error_Log.genericException(ex.getMessage(), 
                                                       System.Label.DT_ERROR_TYPE_VF_CONTROLLER, 
                                                       ex, 
                                                       System.Label.DT_CLASS_RULE_VERSION_EXTENSION , 
                                                       System.Label.DT_METHOD_TOGGLE_ACTIVATE, '', '');
            return NULL;
        }
    }

    /* populateQueues 
     * method to populate Queue field to select among all queues in the org.
     * @params : null
     * @return : List of SelectOption with Queues in the Org
     */
    public List<SelectOption> populateQueues(){
        List<SelectOption> lstQueues = new List<SelectOption>(); 
        for(Group objGrp :[SELECT Id, 
                             Name, 
                             DeveloperName 
                      FROM Group 
                      WHERE Type = 'Queue']){
                lstQueues.add(new SelectOption(objGrp.DeveloperName, objGrp.Name));
        }
        return lstQueues;
    }
    
    
    /* populateAssignees 
     * method to populate Tasks field to select among all queues in the org.
     * @params : null
     * @return : List of SelectOption with Queues in the Org
     */
    public List<SelectOption> populateAssignees(String sFieldName){
        List<SelectOption> lstAssignees = new List<SelectOption>(); 
        String sQuery = 'SELECT ' + sFieldName + ', count(Id) FROM DT_Rule__c WHERE DT_IsActive__c = true GROUP BY ' + sFieldName;
		System.debug('sQuery>>' + sQuery);
        for(AggregateResult agRule :Database.query(sQuery)){
				System.debug('agRule>>' + agRule);
				String sTaskName = String.valueOf(agRule.get(sFieldName));
				System.debug('sTaskName>>' + sTaskName);
                lstAssignees.add(new SelectOption(sTaskName, sTaskName));
        }
        return lstAssignees;
    }
    
     /* cloneVersion 
     * Clone Version and redirect to Rule Version View VF Page
     * @params : null
     * @return : PageReference to redirect to Rule Version VF page
     */
    public PageReference cloneVersion(){
        try {
		    if (objRuleVer != NULL) {
		        PageReference pgRuleVersion;
		
		        DT_Rule_Version__c objVersion = [SELECT ID, DT_Criteria_Logic__c, DT_Navigation__c, Name, DT_Assignment_Type__c, DT_Assignee__c, DT_Queue_Name__c, DT_Rule__c, DT_Version_Number__c, DT_Version_Description__c FROM DT_Rule_Version__c WHERE Id =: objRuleVer.Id];
		        DT_Rule_Version__c objVersionCopy = new DT_Rule_Version__c();
		        AggregateResult arVersionCount = [SELECT
										            Count(Id) RecordCount
										        FROM
										            DT_Rule_Version__c
										        WHERE
										            DT_Rule__c =: objVersion.DT_Rule__c];
		
		        objVersionCopy = objVersion.clone(false, true, false, false);
		        objVersionCopy.DT_Criteria_Logic__c = '';
		        objVersionCopy.DT_Version_Number__c = Integer.valueOf(arVersionCount.get('RecordCount')) + 1;
		        if (objVersionCopy != null) {
		            insert objVersionCopy;
		            List < DT_Rule_Criterion__c > lstRuleCriteria = new List < DT_Rule_Criterion__c > ();
		
		            for (DT_Rule_Criterion__c objCriteria: [SELECT ID, DT_Operator__c, DT_Serial_Number__c, DT_Source_SObject_Field__c, DT_Source_SObject_Field_Type__c, DT_Target_Task_Field__c, DT_Value_To_Compare__c, DT_Value_to_Map__c, DT_Version_Source_Field_Comb__c from DT_Rule_Criterion__c where DT_Rule_Version__c =: objRuleVer.Id]) {
		                DT_Rule_Criterion__c objCriteriaCopy = new DT_Rule_Criterion__c();
		                objCriteriaCopy = objCriteria.clone(false, true, false, false);
		                objCriteriaCopy.DT_Rule_Version__c = objVersionCopy.Id;
		                lstRuleCriteria.add(objCriteriaCopy);
		
		            }
		            if(lstRuleCriteria.size() > 0){
		            	insert lstRuleCriteria;
		            }
		            objVersionCopy.DT_Criteria_Logic__c = objVersion.DT_Criteria_Logic__c;
		            update objVersionCopy;
		            pgRuleVersion = new PageReference('/apex/DT_CreateRuleVersion?id=' + objVersionCopy.Id);
		            pgRuleVersion.setRedirect(true);
		            return pgRuleVersion;
		        }
		    } //if
		    return null;
		} catch (Exception ex) {
		    String sId = DT_Error_Log.genericException(ex.getMessage(),
		        System.Label.DT_ERROR_TYPE_BUSINESS_VALIDATION,
		        ex,
		        System.Label.DT_CLASS_RULE_VERSION_EXTENSION,
		        'CloneVersion', '', '');
		    return null;
		}
    
    }
    
    /* deleteVersion 
     * Delete Version and redirect to Rule Version View VF Page
     * @params : null
     * @return : PageReference to redirect to Rule VF page
     */
    public PageReference deleteVersion(){
        try{
            if(objRuleVer != null){
                delete objRuleVer;
            }
            return new PageReference(DT_Constants.DT_URL_VIEW_RULE + '?id=' + objRuleVer.DT_Rule__c);
        }catch(Exception ex){
            String sId = DT_Error_Log.genericException(ex.getMessage(), 
                                                       System.Label.DT_ERROR_TYPE_BUSINESS_VALIDATION, 
                                                       ex, 
                                                       System.Label.DT_CLASS_RULE_VERSION_EXTENSION , 
                                                       System.Label.DT_METHOD_DELETE_VERSION, '', '');
            return null;
        }
    }
    
}