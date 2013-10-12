exports.bazFunc = function()
{
	return "BAR::BAZ::bazFunct locals.test: ["+ module.parent.exports.locals.test+"]";
};