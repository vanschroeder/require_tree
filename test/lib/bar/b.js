(function(global)
{
	global.bClass = function() {
		return "BAR::bClassValue";
	};
	
	global.bClass.prototype.bFunct = function() {
		return "BAR::bFunctValue";
	};
	
	global.bClass.prototype.getAFunct = function() {
		var aClass = module.parent.exports.getPackage('foo').aClass;
		return new aClass().aFunct();
	};
	
	return global.bClass;
})(module.exports);