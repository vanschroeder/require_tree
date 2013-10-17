(function(global)
{
	if (module.parent.exports.locals.hasOwnProperty('condition'))
	{
		var condition = module.parent.exports.locals.condition;
		// -- note that we can pass package from the local scope to the new sub-tree scope
		var options =  {}; //{preserve_filenames:false, locals:{packages:module.parent.exports.packages}};
		module.parent.exports.packages.conditions.methods = module.parent.exports.addTree('./test/data/condition_'+condition)['condition_'+condition];
	}
})(exports);
