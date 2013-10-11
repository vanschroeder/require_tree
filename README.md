require_tree(path [,locals])
============

Recursive JS and JSON Module Loading for NodeJS

[![Build Status](https://travis-ci.org/vancarney/require_tree.png)](https://travis-ci.org/vancarney/require_tree)


Basic Usage
-----------

Given a directory structure as follows

```
- lib/
	- models/
		- User.js
	- controllers/
		- Login.js
	- utils/
		- index.js
		- specialUtility.js
	- config.json
```

You can import all these in a single `require_tree` statement and access them via hash syntax like a traditional OO Package

```
 var app = require('require_tree').require_tree('lib');
 
 // models.User is now accessable
 var user  = new app.models.User();
 
 // JSON objects are accessed in the same manner
 var configVal = app.config.myValue;
 
 // index files are appended directly to the local root
 app.utils.myIndexFunction();
 
 // other files are appended within the same scope
 var util = new app.utils.specialUtility();
```

Passing Data
-----------

By passing a JSObject to the `locals` param, You can set that Object for access from `module.parent.exports.locals` in your loaded Module's scope.

index.js:
```
var myMods = require_tree('lib', {"myArray":[1,2,3,4]});
``` 

lib/myMod.js:
```
 var passedArray = module.parent.exports.locals.myArray;
 console.log(passedArray);
```

*Note*: This value does not pass downrecursively, it stays at the top level of the heirarchy. So a JS file nested 2 levels deep would need to reference `module.parent.parent.parent`, or your modules will need to explicitely pass the locals via module.exports.



Building Data Structures
-----------

`require_tree` allows you to import JSON documents and treats each index file as a root element.
This functionality allows you to create multiple index and data files to selectively build complex JSON data sets from static files.

```
- conf/
	- condition_1/
		- index.js
	- condition_2/
		- index.js
- lib/
	- config.js
- index.js
```

In the above diagram, we see a `configure.js` file and a `conf` structure.
The intent here is to have build a config file based on the user environment much as we would build an application config using a `configure` script

lib/config.js
```
(function(global)
{
	// attempt to get passed data from locals Object
	var conditionValue = module.parent.exports.locals.condition || 2;
	// use require_tree to load a given structure
	global.config = require('require_tree').require_tree( '../conf/condition_' +  conditionValue);
})(exports);
```

index.js:
```
config = require_tree("lib", {"condition":2}).config;
// config will now contain the dynmically generated JS object structure
console.log(config);
```

Accessing the Package Structure From Loaded Modules
-----------

While `require_tree` returns the loaded package Structure to the caller, it can be useful to be aware of the Package Structure from within a loaded module
`require_tree` exports the packages as `exports.packages` and can be accessed in the same manner as `locals` described above.


What Next?
-----------

With recursive Module loading the ability to pass data and to create programmaticly defined structures on the fly, it seems only logical to add in module defined flow control and introspection,
However, what those would mean for performance, usability and whether or not such features are appropriate for a module loader need some mulling over. So feel free to chime in with ideas, suggestions or pull requests.