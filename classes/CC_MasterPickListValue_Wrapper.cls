public class CC_MasterPickListValue_Wrapper {
       
    public CC_PickListValue_Wrapper conPicklist;
    public List<CC_PickListValue_Wrapper> depPickList;
    
    public CC_MasterPickListValue_Wrapper(CC_PickListValue_Wrapper sKey,List<CC_PickListValue_Wrapper> sVal){
        this.conPicklist=sKey;
        this.depPickList=sVal;
    }

}