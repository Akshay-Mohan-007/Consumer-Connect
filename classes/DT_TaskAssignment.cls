/* Class Name   : DT_TaskAssignment
 * Description  : Task Assignment framework. Assigns sObjects a Task by evaluating the Rule Criteria. 
 *					Before using this make sure that 'DT_Task_Master_Object__c' in 'DT_Task_Settings__c' 
 *					custom settings are populated correctly   
 * Created By   : Nidhin V K
 * Created On   : 07-26-2016
 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date        Modification ID      Description 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K            07-26-2016        1000            Initial version
 * Debalina Chatterjee   09-26-2016        1001
 * Akshay Mohan          12-20-2017        1002            Check for no task to close ID pass
 */
public without sharing class DT_TaskAssignment {

    private static DT_Task_Settings__c objSettings;

    public static String strSobjAPIName;
    
    /* executeTaskRules 
     * create a objTask for the object record once the rule evaluates to true and Returns the record
     * @params : objRecord, mapObjectToTask (key->Task Field, Value->Value to Assign)
     * @return : DT_TaskResponseWrapper
     */
    public static DT_TaskResponseWrapper executeTaskRules(
                                Id recordId,
                                Map<String, String> mapTask,
                                String sTaskIdToClose
                            ) {
        DT_TaskResponseWrapper objResponse = new DT_TaskResponseWrapper();
        if (String.isBlank(recordId)) {
            System.debug('DT_TaskAssignment : SObject NULL');

            DT_Error_Log.BusinessException(
                System.Label.DT_LABEL_EMPTY_RECORD,
                DT_Constants.DT_ERROR_TYPE_BUSINESS_VALIDATION,
                System.Label.DT_LABEL_EMPTY_RECORD,
                System.Label.DT_LABEL_EMPTY_RECORD,
                DT_Constants.DT_CLASS_TASK_ASSIGNMENT,
                DT_Constants.DT_METHOD_EVALUATE_TASK_RULES,
                null,
                DT_Constants.DT_EMPTY);
            objResponse.success = false;
            objResponse.message = System.Label.DT_LBL_EMPTY_RECORD;
            return objResponse;
        }
		try {
			//initializing custom objSettings
	        objSettings = DT_Task_Settings__c.getInstance();
			//new req changes
			if(String.isBlank(objSettings.DT_Task_Master_Object__c)
				|| !mapTask.containsKey(DT_Constants.DT_FIELD_MASTER_RECORD_ID)
				|| !objSettings.DT_Task_Master_Object__c.equals(Id.valueOf(mapTask.get(DT_Constants.DT_FIELD_MASTER_RECORD_ID)).getSObjectType().getDescribe().getName())){
				
				System.debug('DT_TaskAssignment : Master Record Id Missing');
	            DT_Error_Log.BusinessException(
	                DT_Constants.DT_VALUE_MASTER_RECORD_MISSING,
	                DT_Constants.DT_ERROR_TYPE_BUSINESS_VALIDATION,
	                DT_Constants.DT_VALUE_MASTER_RECORD_MISSING,
	                DT_Constants.DT_VALUE_MASTER_RECORD_MISSING,
	                DT_Constants.DT_CLASS_TASK_ASSIGNMENT,
	                DT_Constants.DT_METHOD_EVALUATE_TASK_RULES,
	                null,
	                DT_Constants.DT_EMPTY);
	            objResponse.success = false;
	            objResponse.message = System.Label.DT_LBL_MASTER_RECORD_ID_MISSING;
	            return objResponse;
			}
			List < String > lstObjectFields = new List < String > ();
			Schema.SObjectType objTargetObjectType = recordId.getSObjectType();
			strSobjAPIName = objTargetObjectType.getDescribe().getName();
			
			System.debug('strSobjAPIName : ' + strSobjAPIName);
			
			lstObjectFields.addAll(objTargetObjectType.getDescribe().fields.getMap().keySet());
			
			//Using the list of fields and the object type,
			//we can construct a string based SOQL query
			//to retrieve the field values of all the objects.
		    String sAllFieldsQuery = 'SELECT ' + lstObjectFields.get(0);
		    for (Integer i = 1; i < lstObjectFields.size(); i++) {
		        sAllFieldsQuery += ', ' + lstObjectFields.get(i);
		    }
		    sAllFieldsQuery += ' FROM ' + strSobjAPIName + ' WHERE ID = \'' + recordId + '\'';
			
			System.debug('sAllFieldsQuery : ' + sAllFieldsQuery);
			sObject objRecord = Database.query(sAllFieldsQuery);
			System.debug('objRecord : ' + objRecord);

            //fetch the active rules along with versions and criteria
            List < DT_Rule_Version__c > lstActiveRules = DT_Util.getActiveRules(strSobjAPIName, DT_Constants.DT_RULE_TYPE_TASK);
			
            //if there are more than one rule or if the only rule evaluates to false
            if (lstActiveRules.size() == 0) {
                System.debug('DT_TaskAssignment : No Active Rules');
                objResponse.success = false;
	            objResponse.message = System.Label.DT_LBL_NO_ACTIVE_RULES;
	            return objResponse;
            }
			System.debug('lstActiveRules (' + lstActiveRules.size() + ') : ' + lstActiveRules);
            //evaluate the rule criteria to check whether the record satisfies the criteria
            List < DT_Rule_Version__c > lstEligibleRules = DT_Util.evaluateRuleCriteria(objRecord, lstActiveRules);

            if (lstEligibleRules == NULL || lstEligibleRules.size() == 0) {
                System.debug('DT_TaskAssignment : No Eligible Rules');
                objResponse.success = false;
	            objResponse.message = System.Label.DT_LBL_NO_ELIGIBLE_RULES;
	            return objResponse;
            }
			System.debug('lstEligibleRules (' + lstEligibleRules.size() + ') : ' + lstEligibleRules);
            //get the high priority rule
            DT_Rule_Version__c objRuleToExecute = DT_Util.getHighPriorityRule(lstEligibleRules);
			System.debug('objRuleToExecute : ' + objRuleToExecute);

            //Create objTask
            objResponse = createTask(
                objRecord,
                objRuleToExecute,
                mapTask,
                sTaskIdToClose);

            System.debug('DT_TaskAssignment : objResponse->' + objResponse);
            return objResponse;

        } catch (Exception ex) {
            //throw error
            String sErrorMessage = 'Exception on Class : DT_TaskAssignment - evaluateTaskRules, Error : ' +
                ex.getMessage() +
                ' Line Number : ' +
                ex.getLineNumber() +
                ' Cause : ' +
                ex.getCause() +
                ' Type : ' +
                ex.getTypeName();
            System.debug(sErrorMessage);

            DT_Error_Log.genericException(
                ex.getMessage(),
                DT_Constants.DT_ERROR_TYPE_BUSINESS_VALIDATION,
                ex,
                DT_Constants.DT_CLASS_TASK_ASSIGNMENT,
                DT_Constants.DT_METHOD_EVALUATE_TASK_RULES,
                recordId,
                DT_Constants.DT_EMPTY);
            objResponse.success = false;
            objResponse.message = sErrorMessage;
            return objResponse;
        }
    }


    /* createTask 
	 * create a objTask for the object record and Returns the task record
	 * @params : objRecord, lstEligibleRules
	 * @return : DT_TaskResponseWrapper
	 */
	public static DT_TaskResponseWrapper createTask(
											    sObject objRecord,
											    DT_Rule_Version__c objRuleToExecute,
											    Map < String, String > mapTaskToOverride,
											    String sTaskIdToClose
											) {
	
        DT_TaskResponseWrapper objResponse = new DT_TaskResponseWrapper();
	    List < DT_Task__c > lstTask = new List < DT_Task__c > ();
        DT_Task__c objTask = new DT_Task__c();
        Map < String, String > mapTask = new Map < String, String > ();
        DT_Task__c objPrevTask;
        //Start[Akshay 20-Dec-17]: Check that sTaskIdToClose is blank or not
        if(String.isNotBlank(sTaskIdToClose)) 
            objPrevTask =   [SELECT
								Id, CreatedById, DT_Secondary_Identifier__c,
								DT_Status__c
    						FROM
    							DT_Task__c
    						WHERE
    							Id = :sTaskIdToClose];
        //End[Akshay 20-Dec-17]: Check that sTaskIdToClose is blank or not
        //populate the queue/user details to assign
        if(!mapTaskToOverride.containsKey(DT_Constants.DT_FIELD_OWNERID)) {
        	if(objRuleToExecute.DT_Assignment_Type__c.equals(System.Label.DT_RULE_VER_TYPE_MANUAL)
        		&& objPrevTask != NULL){
            	if(objRuleToExecute.DT_Assignee__c.equals(DT_Constants.DT_ASSIGNEE_TYPE_TASK)){
	                DT_Task__c objTargetTask = [SELECT
			        								Id, OwnerId
			        							FROM
			        								DT_Task__c
			        							WHERE
			        								DT_Rule_Version__r.DT_Rule__r.DT_Task_Name__c = :objRuleToExecute.DT_Assign_To_Owner_Of__c
			        							AND
			        								DT_Master_Record_Id__c = :mapTaskToOverride.get(DT_Constants.DT_FIELD_MASTER_RECORD_ID)
			        							AND 
			        								(DT_Secondary_Identifier__c = :objPrevTask.DT_Secondary_Identifier__c
			        								OR DT_Secondary_Identifier__c = NULL)
				    							ORDER BY 
				    								CreatedDate DESC
				                				LIMIT 1];
	            	objTask.OwnerId = objTargetTask.OwnerId;
            	} else if(objRuleToExecute.DT_Assignee__c.equals(DT_Constants.DT_ASSIGNEE_TYPE_TASK)){
            		DT_Task__c objTargetTask = [SELECT
			        								Id, OwnerId
			        							FROM
			        								DT_Task__c
			        							WHERE
			        								DT_Rule_Version__r.DT_Rule__r.DT_Module__c = :objRuleToExecute.DT_Assign_To_Owner_Of__c
			        							AND
			        								DT_Master_Record_Id__c = :mapTaskToOverride.get(DT_Constants.DT_FIELD_MASTER_RECORD_ID)
			        							AND 
			        								(DT_Secondary_Identifier__c = :objPrevTask.DT_Secondary_Identifier__c
			        								OR DT_Secondary_Identifier__c = NULL)
				    							ORDER BY 
				    								CreatedDate DESC
				                				LIMIT 1];
	            	objTask.OwnerId = objTargetTask.OwnerId;
            	} else{
	            	objTask.OwnerId = objPrevTask.CreatedById;
            	}
            } else if (objRuleToExecute.DT_Assignment_Type__c.equals(System.Label.DT_RULE_TYPE_QUEUE)) {
                objTask.OwnerId = DT_Util.getQueueId(objRuleToExecute.DT_Queue_Name__c);
            }
        }
		Map<String, Schema.RecordTypeInfo> mapRTbyName = Schema.SObjectType.DT_Rule_Criterion__c.getRecordTypeInfosByName();
		
        //Task creation based on the fields given in mapTaskToOverride or DT_Target_Task_Field__c
        for (DT_Rule_Criterion__c criterion: objRuleToExecute.DT_Rule_Criteria__r) {
            //if objTask field is defined, then we will map it with the sobject field value based on the record type
            if (mapRTbyName.get(DT_Constants.DT_RECORD_TYPE_MAP_STATIC).getRecordTypeId() == criterion.RecordTypeId &&
                (!String.isBlank(criterion.DT_Target_Task_Field__c)) &&
                (!String.isBlank(criterion.DT_Value_to_Map__c))) {

                if (criterion.DT_Target_Task_Field__c == DT_Constants.DT_FIELD_DUE_DATE) {
                    Date dtDueDate = Date.today() + Integer.valueOf(criterion.DT_Value_to_Map__c);
                    mapTask.put(criterion.DT_Target_Task_Field__c, String.valueOf(dtDueDate));
                } else {
                    mapTask.put(criterion.DT_Target_Task_Field__c, criterion.DT_Value_to_Map__c);
                }

            } else if (mapRTbyName.get(DT_Constants.DT_RECORD_TYPE_MAP_SOBJECT).getRecordTypeId() == criterion.RecordTypeId &&
                (!String.isBlank(criterion.DT_Target_Task_Field__c)) &&
                (!String.isBlank(criterion.DT_Source_SObject_Field__c))) {

                mapTask.put(criterion.DT_Target_Task_Field__c, String.valueOf(objRecord.get(criterion.DT_Source_SObject_Field__c)));
            }
            System.debug('mapTask : ' + mapTask);
        }

        //generate the record based on the data type
        objTask = (DT_Task__c) DT_Util.generateRecordFromMap((sObject) objTask, mapTask);

        //Override with 
        if (mapTaskToOverride != null && mapTaskToOverride.size() > 0) {
            objTask = (DT_Task__c) DT_Util.generateRecordFromMap((sObject) objTask, mapTaskToOverride);
        }

        //Create, if objTask not null
        if (objTask != null) {
	        //populate override protected fields
	        objTask.Name = objRuleToExecute.DT_Rule__r.DT_Task_Name__c;
	        objTask.DT_Status__c = DT_Constants.DT_TASK_STATUS_NEW;
	        objTask.DT_Record_Id__c = objRecord.Id;
	        objTask.DT_Record_Type__c = strSobjAPIName;
	        objTask.DT_Rule_Version__c = objRuleToExecute.Id;
        	
            //close previous task and creates the new one.
            //Start[Akshay 20-Dec-17]: Check that objPrevTask is blank or not
            if(objPrevTask == null || objPrevTask.DT_Status__c.equals(DT_Constants.DT_TASK_STATUS_COMPLETE))
            //End[Akshay 20-Dec-17]: Check that objPrevTask is blank or not
            	DT_Util.closePreviousAndCreateNewTask(objTask, NULL);
            else
            	DT_Util.closePreviousAndCreateNewTask(objTask, sTaskIdToClose);
            
        }
        objResponse.success = true;
		objResponse.response = objTask;
        return objResponse;
	}
}