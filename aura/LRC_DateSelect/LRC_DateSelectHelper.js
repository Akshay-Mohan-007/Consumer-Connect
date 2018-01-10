({
    init: function(component, event) {
        try{
            this.setSelected(component);
        }catch(e){
            console.log(e.stack, true);
        }
    },
    
    setSelected: function(component) {
        try{
            var value = component.get("v.value");
            var values = component.get("v.options");
            var selected= (new Date()).getFullYear();
            console.log("selected year is"+selected);
            
            window.setTimeout(
                $A.getCallback(function() {
                    
                    if (!component.isValid()){
                        return;
                    }
                    var selectL = component.find('select-element');
                    var select = selectL.getElement();
                    
                    if (!value || !select || select.options.length === 0) {
                        return;
                    }
                    var len = select.options.length;
                    for (var i = 0; i < len; i++) {
                        if (select.options[i].value == selected) {
                            console.log("matched for"+select.options[i].value)
                            select.options[i].selected = true;
                            return;
                        }
                    }
                }), 200
            );
        }catch(e){
            console.log(e.stack, true);
        }
    }
})