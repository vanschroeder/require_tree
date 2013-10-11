exports.bazFunc = function()
{
	return "BAR::BAZ::bazFunct locals.test: ["+ module.parent.parent.parent.exports.locals.test+"]";
};