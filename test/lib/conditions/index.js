(function(globals)
{
	if (module.parent.exports.locals.hasOwnProperty('condition'))
	{
		var condition = module.parent.exports.locals.condition;
		module.exports.methods = require('../../../require_tree').require_tree('./test/data/condition_'+condition);
	}
})(exports);
