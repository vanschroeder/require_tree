require_tree
============

Package like Module Loading for Nodejs

Basic Usage
-----------

Given a directory structure as follows

```
- lib
  - models
    - User.js
  - controllers
  	- Login.js
  - utils
  	- index.js
  	- specialUtility.js
  - config.json
```

You can import all these in a single `require_tree` statement and access them via hash syntax like a traditional OO Package

```
 var app = require('require_tree').require_tree('./lib');
 
 // models.User is no accessable
 var user  = new app.models.User();
 
 // JSON objects are accessed in the same manner
 var configVal = app.config.myValue;
 
 // index files are appended directly to the local root
 app.utils.myIndexFunction();
 
 // other files are appended within the same scope
 var util = new app.utils.specialUtility();
```