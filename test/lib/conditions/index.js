(function(global)
{
	if (module.parent.exports.locals.hasOwnProperty('condition'))
	{
		var condition = module.parent.exports.locals.condition;
		// -- note that we can pass package from the local scope to the new sub-tree scope
		var options =  {preserve_filenames:true, locals:{packages:module.parent.exports.packages}};
		global.methods = require('../../../require_tree').require_tree('./test/data/condition_'+condition, options);
	}
})(exports);
