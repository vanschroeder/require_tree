## require_tree
# (c)2013 Van Carney
# Licensed under the MIT License
#### Recursive Package like Module and JSON Loading for NodeJS
exports.require_tree = (uPath, options={})->
  'use strict'
  # just return if there is nothing set in the uPath param
  return null if !uPath
  # define locals for access by loaded Child Modules
  module.exports.locals = options.locals || {}
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
  exports.packages = (packages = {})[_ns = b.pop()] = {}
  # returns the path parts as an array
  parsePath = (p)-> p.replace(new RegExp("^\\.?(\\#{path.sep})"),'').split path.sep
  # returns a path woth the _root filtered out
  getPwd = (p)->
    p.replace new RegExp("^(\\.\\#{path.sep})?#{(parsePath _root).join '\\'+path.sep}\\#{path.sep}"), ''
  # adds a given path to the Package
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
  # traverse the given Path
  walker = (dir)=>
    if (list = fs.readdirSync dir).length
      for name in list
        continue if name.match /^\./
        # full path to file
        file = path.join dir, name
        # package path
        pwd = getPwd file
        try
          # attempt to get stats on the file
          stat = fs.statSync file
        catch err
          stat = null
        if stat?.isDirectory()
          # add this directory to our Package
          appendPackages pwd
          # walk this directory
          walker file
        else 
          # we only handle JS and JSON files
          continue if !path.extname(file).match /^\.js+(on)?$/
          try
            # detect path formatting -- default is to ditch the filenames
            if !options.preserve_filenames
              o = getPackage ((p=parsePath pwd).slice 0, p.length - (if p.length > 1 then 1 else 0) ).join path.sep
              # composite this Package (FYI: will join all.json and .js file contents into one package item)
              o = extend o, require fs.realpathSync "#{file}"
            else
              # then we keep file names in the package path structure
              if name.match /^index+/
                # if we have an index, we will build this directly into the current package
                o = getPackage ((p=parsePath pwd).slice 0, p.length - (if p.length > 1 then 1 else 0) ).join path.sep
                # composite this Package (FYI: will join index.json and index.js into one package item)
                o = extend o, require fs.realpathSync "#{file}"
              else
                # we will append a new Package for each unique file name (excluding ext)
                o = if (o = getPackage initial(parsePath pwd).join path.sep)? then o else appendPackages initial(parsePath pwd).join path.sep
                # add the module or JSON structure to the current Package
                o[name.split('.').shift()] = extend o[name.split('.').shift()] || {}, require fs.realpathSync "#{file}"
          catch e
            console.error "Error requiring #{file}: #{e.message}"
  # walk the given path
  walker uPath
  # returns the provided Namespace and it's contents
  packages[_ns]