(function(global)
{
	global.aClass = function() {
		return "LIB::aClassValue";
	};
	
	global.aClass.prototype.aFunct = function() {
		return "LIB::aFunctValue";
	};
	
	return global.aClass;
})(exports);