(function(global)
{
	a = require('../../../require_tree').require_tree('./test/lib/bar').a;
	global.bClass = function() {
		return "BAR::bClassValue";
	};
	
	global.bClass.prototype.bFunct = function() {
		return "BAR::bFunctValue";
	};
	
	global.bClass.prototype.getAFunct = function() {
		return (new a.aClass()).aFunct();
	};
	
	return global.bClass;
})(module.exports);