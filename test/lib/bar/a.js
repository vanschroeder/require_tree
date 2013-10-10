(function(global)
{
	global.aClass = function() {
		return "BAR::aClassValue";
	};
	
	global.aClass.prototype.aFunct = function() {
		return "BAR::aFunctValue";
	};
	
	return global.aClass;
})(exports);