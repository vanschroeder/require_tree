module.parent.exports.addTree( 'test/data/condition_3', {
	packages: module.parent.exports.getTree('.')
} );

function SubTreeClass() {
};
	
SubTreeClass.prototype.subFunct = function() {
	return "SubTreeClass::aFunctValue";
};
	
exports.SubTreeClass = SubTreeClass;