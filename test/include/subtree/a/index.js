(function(global) {
	global.AClass = function() {
		
	};

	global.AClass.prototype.callSubTreeFunct = function() {
		return (new (module.parent.exports.getTree('subtree').SubTreeClass)).subFunct();
	};
})(exports);
