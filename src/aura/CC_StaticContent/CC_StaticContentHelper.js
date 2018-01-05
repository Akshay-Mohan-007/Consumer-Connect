({
	loadPage : function(component) {
	var sPhone = component.get('v.phone');
	if(!$A.util.isEmpty(sPhone) && !isNaN(sPhone) )
		component.set('v.bIsPhone',true);
	else if(!$A.util.isEmpty(sPhone))
		component.set('v.text',sPhone);
	}
})