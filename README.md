require_tree([path], [options])
============

Recursive Package like Module and JSON Loading for NodeJS

[![Build Status](https://travis-ci.org/vancarney/require_tree.png)](https://travis-ci.org/vancarney/require_tree)

Installation
-----------
```
npm install require_tree
```

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

Arguments
-----------

**path**: A standard path to a given directory to import. This parameter is optional and defaults to null

**options**: The `options` object accepts these properties:

> **locals**: A user defined JS Object that will be made avialable to loaded modules

> **packages**: An arbitrary object or existing package structure from another require_tree instance that will serve as the basis for the current require_tree instance

> **preserve_filenames**: A boolean value instructing require_tree to preserve the filename in the package path structure. The default value is `false`
> *note*: This directive will be temporarily ignored and the filename used to name an unnamed function to support sloppy `module.exports = function() {...}` usage


Methods
-----------

The following `methods` are accessable from both the returned `package` structure and the `module.parent.exports`


**getTree(path)**

Returns a given `package` and it\'s descendants. Accepts both hash and path syntax

*example:*

```
// from application scope
tree = require('require_tree').require_tree('lib');
console.log( tree.require_tree.getTree('models') );

// from loaded module
console.log( module.parent.exports.getTree('models') );
```


**addTree(path)**

Recursively loads a new directory structure into the `package` structure of the current scope

*example:*

```
// from application scope
tree = require('require_tree').require_tree('lib');
tree.require_tree.addTree('otherLib');

// from loaded module
module.parent.exports.addTree('otherLib');
```

**extendTree(object)**

Merges a given `package` and it\'s descendants with the existing `package` structure. 

*example:*

```
// from application scope
tree = require('require_tree').require_tree('lib');
eTree = require('require_tree').require_tree('lib2');
tree.require_tree.extendTree(eTree);

// from loaded module
eTree = require('require_tree').require_tree('lib2');
module.parent.exports.extendTree(eTree);
```

**removeTree(path)**

Removes a given `package` and it\'s descendants from the `package` strucure. Accepts both hash and path syntax. 

*Note*: This will not remove loaded Modules from the Module Cache.

*example:*

```
// from application scope
tree = require('require_tree').require_tree('lib');
tree.require_tree.removeTree('models');

// from loaded module
module.parent.exports.removeTree('models');
```

**on(name, callback, context)**

Adds an event handler for a given event

*example:*

```
// -- will print contents of package to console when loading has completed
(rTree = require('require_tree')).on( 'completed', function(data) {
	console.log(data);
});
	
rTree.require_tree('./lib');  
```

**off(name, callback, context)**

Removes an event handler for a given event

*example:*

```

(rTree = require('require_tree')).on( 'completed', function(data) {
	// -- will remove the event handler for further completed events.
	data.require_tree.off('completed');
	console.log(data);
});
	
rTree.require_tree('./lib');  
```

**trigger(name, ...)**

Dispatches an event to all listeners

*example:*

```

(rTree = require('require_tree')).on( 'myEvent', function(data) {
	console.log(data);
});

// -- calling trigger will cause the above listener to capture and event
rTree.trigger('myEvent', {data:"hello world"});
```

Events
-----------
 Event listeners may be added and removed using the `on` and `off` methods listed above
 the following events are dispatched by require_tree
 
**completed**

Triggered when `require_tree` has been called directly, passes package structure as it's data payload

**changed**

Triggered when `addTree`, `removeTree` or `extendTree` have been called with the following payload:

> *packages*: the complete package structure in it's present state
> *added*: If present, will contain the tree that has been added. Passed on addTree or extendTree operations
> *removed*: If present will contain the tree that has been removed. Only passed on removeTree operations


Passing Data
-----------

By passing a JS Object to the `locals` param of the`options` object, you can set that Object for access from `module.parent.exports.locals` in your loaded Module\'s scope.

*index.js:*

```
var myMods = require_tree("lib", {locals:{"myArray":[1,2,3,4]}});
``` 

*lib/myMod.js:*

```
var passedArray = module.parent.exports.locals.myArray;
console.log(passedArray);
```

Nesting `require_tree` Calls
-----------

Making nested `require_tree` calls from within loaded Modules will create a new `require_tree` instance and Module Scope with a new package structure.
Use the `packages` params of the `options` argument to pass in an exising object or `package` structure to `inherit` from. 

*example:*

```
(function(global)
{
	// use require_tree to load a structure into a new scope
	// note that we pass in the packages object in the options for the new sub-tree
	global.config = require('require_tree').require_tree( '../subtree', {packages:{module.parent.exports.getPath('.')}});
	
	// our new tree will have inherited the parent require_tree packages
	console.log( global.config );
})(exports);
```

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

*lib/config.js*

```
(function(global)
{
	// attempt to get passed data from locals Object
	var conditionValue = module.parent.exports.locals.condition || 1;
	// use require_tree to load a given structure into the current scope
	module.parent.exports.addTree( '../conf/condition_' +  conditionValue);
})(exports);
```

*index.js:*

```
config = require_tree("lib", {locals:{"condition":2}});

// config will now contain the dynmically generated JS object structure
console.log(config);
```

Accessing the Package Structure
-----------

While `require_tree` returns the loaded package Structure to the caller, it can be very useful to be aware of the Package Structure from within a loaded module
`require_tree` exports the packages as `exports.packages` and includes a `require_tree` package containing the exported methods listed in the`Methods` section above. 

### From the Application Scope

*example:*

```
var tree = require('require_tree').require_tree('path/to/dir');

// using the `module.parent.exports.getTree` method
var otherObjectRef = tree.getTree('path.to.other.Object');
this.myRefInstance = new otherObjectRef();

// add another directory structure to the current package
tree.addTree('path/to/new/dir');
// access the new tree
console.log( tree.getTree('dir') );

// remove a directory structure to the current package
tree.removeTree('dir/subtree');
// access the updated tree
console.log( tree.getTree('dir') );

// remove a directory structure to the current package
tree.extendTree({dir:{newSubTree:{val1:"value1", val2:"value2"}}});
// tree 'dir' will now have 'newSubTree' nested
console.log( tree.getTree('dir') );
```

### From Loaded Modules

*example:*

```
(function(global)
{
	// using the `module.parent.exports.getTree` method
	var otherObjectRef = module.parent.exports.getTree('path.to.other.Object');
	global.myModule = function() {
		this.myRefInstance = new otherObjectRef();
	}
	
	// add another directory structure to the current package
	module.parent.exports.addTree('path/to/new/dir');
	// access the new tree
	console.log( module.parent.exports.getTree('dir') )
	
	// remove a directory structure to the current package
	module.parent.exports.removeTree('dir/subtree');
	// access the updated tree
	console.log( module.parent.exports.getTree('dir') );

	// remove a directory structure to the current package
	module.parent.exports.extendTree({dir:{newSubTree:{val1:"value1", val2:"value2"}}});
	// tree 'dir' will now have 'newSubTree' nested
	console.log( module.parent.exports.getTree('dir') );
})(exports)

```

What Next?
-----------

With recursive Module loading the ability to pass data and to create programmaticly defined structures on the fly, it seems only logical to add in module defined flow control and introspection,
However, what those would mean for performance, usability and whether or not such features are appropriate for a module loader need some mulling over. So feel free to chime in with ideas, suggestions or pull requests.
