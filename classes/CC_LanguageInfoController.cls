public class CC_LanguageInfoController {
        @AuraEnabled
    public static String getPicklistValue(){
       
          pickListWrapper objPickVal = new pickListWrapper();
        
          map<String, Schema.SObjectField> mapContactSchema = new map<String, Schema.SObjectField>();
          mapContactSchema = CC_Utility.getFieldMap(CC_Constants.CC_CONTACT_OBJ);
         
        
         objPickVal.spokenLan = CC_Utility.getPicklistValuesFromFieldMap(mapContactSchema,CC_Constants.CC_CONTACT_SPOKEN_LANG);
         objPickVal.writtenLan = CC_Utility.getPicklistValuesFromFieldMap(mapContactSchema,CC_Constants.CC_CONTACT_WRITTEN_LANG);
         objPickVal.preferredLan = CC_Utility.getPicklistValuesFromFieldMap(MapContactSchema,CC_Constants.CC_CONTACT_PREFERRED_LANG);
             
             System.debug('******pickVal'+objPickVal);
             System.debug('******JSON Values : '+'{"pickValWrapper":'+JSON.serialize(objPickVal)+'}');
             return '{"objPickVal":'+JSON.serialize(objPickVal)+'}';
	  
}
    public class pickListWrapper{
        List<String> spokenLan;
        List<String> writtenLan;
        List<String> preferredLan;
        
       // List<String> State;
    }

}