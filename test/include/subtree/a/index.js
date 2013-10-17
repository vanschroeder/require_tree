(function(global) {
	global.AClass = function() {
		
	};

	global.AClass.prototype.callSubTreeFunct = function() {
		return (new (module.parent.exports.getPackage('subtree').SubTreeClass)).subFunct();
	};
})(exports);
