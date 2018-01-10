/* Class Name   : DT_Constants
 * Description  : All Constants.    
 * Created By   : Nidhin V K
 * Created On   : 07-29-2016

 * Modification Log:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date        Modification ID      Description 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K            07-29-2016        1000            Initial version
 *
 *
 */
public with sharing class DT_Constants{
    
    public static final String DT_EMPTY = '';
    public static final String DT_NONE = 'None';
    
    public static final String DT_STRING_EQUALS_TO = 'Equals To';
    public static final String DT_STRING_NOT_EQUALS_TO = 'Not Equals To';
    public static final String DT_STRING_GREATER_THAN = 'Greater Than';
    public static final String DT_STRING_GREATER_THAN_OR_EQUALS_TO = 'Greater Than Or Equals To';
    public static final String DT_STRING_LESS_THAN = 'Less Than';
    public static final String DT_STRING_LESS_THAN_OR_EQUALS_TO = 'Less Than Or Equals To';
    
    //For Rule Types
    public static final String DT_RULE_TYPE_QUEUE = 'Queue';
    public static final String DT_RULE_TYPE_TASK = 'Task';
    public static final String DT_RULE_TYPE_EMAIL = 'Email';
    
    public static final String DT_TASK_STATUS_NEW = 'New';
    public static final String DT_TASK_STATUS_IN_PROGRESS = 'In Progress';
    public static final String DT_TASK_STATUS_COMPLETE = 'Complete';
    
    public static final Set<String> DT_RULE_TYPES = new Set<String>{'Queue', 'Task', 'Email'};
    public static final Set<String> DT_RECORD_OWNER_TYPES = new Set<String>{'User', 'Group'};

    //public static final Set<String> DT_TARGET_OBJECTS = new Set<String>{'LTSS_Application_Info__c', 'LTSS_LOC_Info__c', 'LTSS_Enrolled_Program__c', 'LTSS_Application_Detail__c', 'LTSS_POC__c'};
    public static final Set<String> DT_RESTRICTED_FIELDS = new Set<String>{'DT_Record_Id__c', 'DT_Record_Type__c'};
    
    public static final List<String> DT_RULE_PRIORITY_LIST = new List<String>{'High', 'Normal', 'Low'};
    
    public static final String DT_OBJECT_TASK = 'DT_Task__c';
    public static final String DT_OBJECT_RULE_CRITERION = 'DT_Rule_Criterion__c';
    
    public static final String DT_FIELD_IS_ACTIVE = 'DT_IsActive__c';
    public static final String DT_FIELD_RULE_VERSION = 'DT_Rule_Version__c';
    public static final String DT_FIELD_RULE = 'DT_Rule__c';
    public static final String DT_FIELD_SL_NO = 'DT_Serial_Number__c';
    public static final String DT_FIELD_OWNER_ID = 'OwnerId';
    public static final String DT_FIELD_COMMENTS = 'DT_Comments__c';
    public static final String DT_FIELD_STATUS = 'DT_Status__c';
    public static final String DT_FIELD_DUE_DATE = 'DT_Due_Date__c';
    public static final String DT_FIELD_NAME = 'Name';
    public static final String DT_FIELD_DEACTIVATED_DATE = 'DT_Deactivated_Date__c';
    public static final String DT_FIELD_MASTER_RECORD_ID = 'DT_Master_Record_Id__c';
    public static final String DT_FIELD_OWNERID = 'OwnerId';
    public static final String DT_FIELD_TASK_NAME = 'DT_Task_Name__c';
    public static final String DT_FIELD_MODULE = 'DT_Module__c';
    
    public static final String DT_URL_VIEW_RULE_LIST = '/apex/DT_ViewRuleList';
    public static final String DT_URL_VIEW_RULE = '/apex/DT_ViewRules';
    public static final String DT_URL_VIEW_RULE_VERSION = '/apex/DT_ViewRuleVersion';
    
    public static final String DT_ERROR_TYPE_BUSINESS_VALIDATION = 'Business Validation';
    public static final String DT_ERROR_TYPE_VF_CONTROLLER = 'Apex Controller';
    public static final String DT_ERROR_TYPE_APEX_TRIGGER = 'Apex Trigger';
    
    public static final String DT_CLASS_RULE_EXTENSION = 'DT_RuleExtension';
    public static final String DT_CLASS_RULE_VERSION_EXTENSION = 'DT_RuleVersionExtension';
    public static final String DT_CLASS_RULE_CRITERIA_EXTENSION = 'DT_RuleCriteriaExtension';
    public static final String DT_CLASS_RULE_VERSION_TRIGGER_HANDLER = 'DT_RuleVersionTriggerHandler';
    public static final String DT_CLASS_TASK_ASSIGNMENT = 'DT_TaskAssignment';
    public static final String DT_CLASS_QUEUE_ASSIGNMENT = 'DT_QueueAssignment';
    public static final String DT_CLASS_SEND_EMAIL = 'DT_SendEmail';
    public static final String DT_CLASS_UTIL = 'DT_Util';
    
    
    public static final String DT_METHOD_TOGGLE_ACTIVATE = 'toggleActivate';
    public static final String DT_METHOD_SAVE = 'save';
    public static final String DT_METHOD_EVALUATE_TASK_RULES = 'evaluateTaskRules';
    public static final String DT_METHOD_EVALUATE_QUEUE_RULES = 'evaluateQueueRules';
    public static final String DT_METHOD_EVALUATE_EMAIL_RULES = 'evaluateEmailRules';
    public static final String DT_METHOD_CREATE_TASK = 'createTask';
    public static final String DT_METHOD_SEND_EMAIL = 'sendEmail';
    public static final String DT_METHOD_CHECK_VALIDATIONS = 'checkValidations';
    public static final String DT_METHOD_EVALUATE_RULE_CRITERIA = 'evaluateRuleCriteria';
    public static final String DT_METHOD_POPULATE_OBJECT_FIELDS = 'populateSObjectFields';
    public static final String DT_METHOD_DELETE_RULE = 'deleteRule';
    public static final String DT_METHOD_DELETE_VERSION = 'deleteVersion';
    public static final String DT_METHOD_DELETE_CRITERIA = 'deleteCriteria';
    public static final String DT_METHOD_NAVIGATE_URL = 'getNavigateURL';
    
    public static final String DT_RECORD_TYPE_MAP_STATIC = 'Map Static Values To Task';
    public static final String DT_RECORD_TYPE_MAP_SOBJECT = 'Map Object Fields To Task';
    public static final String DT_RECORD_TYPE_COMPARE = 'Compare Field Value';
    
    public static final String DT_VALUE_NOT_STARTED = 'Not Started';
    public static final String DT_VALUE_OTHER = 'Other';
    public static final String DT_VALUE_NORMAL = 'Normal';
    
    public static final String DT_VALUE_MASTER_RECORD_MISSING = 'Master Record Id Missing';
    public static final String DT_ASSIGN_BACK_TO_PERSON = 'Assign it back to the Submitted Person';
    public static final String DT_ASSIGNEE_TYPE_TASK = 'Assign it to latest Task Owner';
    public static final String DT_ASSIGNEE_TYPE_MODULE = 'Assign it to latest Module Owner';
}