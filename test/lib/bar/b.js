(function(global)
{
	global.bClass = function() {
		return "BAR::bClassValue";
	};
	
	global.bClass.prototype.bFunct = function() {
		return "BAR::bFunctValue";
	};
	
	global.bClass.prototype.getAFunct = function() {
		return (new module.parent.exports.packages.aClass()).aFunct();
	};
	
	return global.bClass;
})(module.exports);