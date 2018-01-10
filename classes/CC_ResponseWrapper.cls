/***************************************************************************************************************************************
 * NAME   : CC_ResponseWrapper
 * DESCRIPTION  : Wrapper Class for Response Component
 *
 * @AUTHOR   : Nidhin V K
 * @DATE   : 11-29-2017
 *
 * MODIFICATION LOG:  
 * --------------------------------------------------------------------------------------------------------------------------------------
 * DEVELOPER                DATE                DESCRIPTION 
 * --------------------------------------------------------------------------------------------------------------------------------------
 * Nidhin V K               11-29-2017          Initial version        
 *
 ****************************************************************************************************************************************/
public class CC_ResponseWrapper {
    public Boolean success;
    public String response;
    public List<String> messages;
    
    public CC_ResponseWrapper(){
    	messages = new List<String>();
    }
    
    public CC_ResponseWrapper(Boolean success) {
        this();
        this.success = success;
    }
    
    public CC_ResponseWrapper(Boolean success, String response) {
        this(success);
        this.response = response;
    }
    
    public CC_ResponseWrapper(Boolean success, String response, List<String> messages) {
        this(success, response);
        this.messages = messages;
    }
}