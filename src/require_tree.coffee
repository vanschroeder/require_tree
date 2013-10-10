## require_tree
# (c)2013 Van Carney
# Licensed under the MIT License
#### Package like Module Loading for Nodejs
exports.require_tree = (uPath)->
  'use strict'
  fs    = require 'fs'
  path  = require 'path'
  # retrieves all but the last value of a given array
  initial = (a)-> a.splice 0, a.length - 1
  # composites two or more Objects
  extend = (obj)->
    for o in Array.prototype.slice.call arguments, 1
      if o?
        for x of o
          obj[x] = o[x]
    obj
  # the root path to the package we are importing -- we use this to filter
  _root = initial(b = uPath.split path.sep).join path.sep
  # Our packages object that we will build and return 
  (packages = {})[_ns = b.pop()] = {}
  # returns the path parts as an array
  parsePath = (p)-> p.replace(new RegExp("^\\.?(\\#{path.sep})"),'').split path.sep
  # returns a path woth the _root filtered out
  getPwd = (p)->
    p.replace new RegExp("^(\\.\\#{path.sep})?#{(parsePath _root).join '\\'+path.sep}\\#{path.sep}"), ''
  # add a path to the Package
  appendPackages = (p)->
    pkg = packages
    for d in [0...(s=parsePath p).length]
      pkg[s[d]] ?= {}
      pkg = pkg[s[d]]
    pkg
  # get a Path from the Package
  getPackage = (p)->
    pkg = packages
    for d in [0...(s=parsePath p).length]
      if (f=pkg[s[d]])?
        pkg = f
      else
        return null
    pkg
  # taverse the given Path
  walker = (dir)=>
    if (list = fs.readdirSync dir).length
      for name in list
        continue if name.match /^\./
        file = path.join dir, name
        pwd = getPwd file
        try
          stat = fs.statSync file
        catch err
          stat = null
        if stat?.isDirectory()
          appendPackages pwd
          walker file
        else 
          continue if !path.extname(file).match /^\.js+(on)?$/
          try
            if name.match /^index+/
              o = getPackage ((p=parsePath pwd).slice 0, p.length - (if p.length > 1 then 1 else 0) ).join path.sep
              o = extend o, require( fs.realpathSync "#{initial( file.split path.sep ).join path.sep}")
            else
              o = if (o = getPackage initial(parsePath pwd).join path.sep)? then o else appendPackages initial(parsePath pwd).join path.sep
              o[name.split('.').shift()] = require fs.realpathSync "#{file}"
          catch e
            console.error "Error requiring #{file}: #{e.message}"
  walker uPath
  # returns the provided Namespace and it's contents
  packages[_ns]