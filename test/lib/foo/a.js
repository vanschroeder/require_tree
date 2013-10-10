function aClass() {
	return "FOO::aClassValue";
};
	
aClass.prototype.aFunct = function() {
	return "FOO::aFunctValue";
};
	
exports.aClass = aClass;