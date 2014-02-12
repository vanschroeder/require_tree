## require_tree
# (c)2013 Van Carney
# Licensed under the MIT License
#### Recursive Package like Module and JSON Loading for NodeJS
# A partial port of Backbone.Events for event binding/triggering
Events =
  #### on(name, callback, context)
  #> Adds an event listener
  on: (name, callback, context)->
    return @ if  !eventsApi( @, 'on', name, [callback, context]) || !callback
    @_events || (@_events = {})
    events = @_events[name] || (@_events[name] = [])
    events.push callback: callback, context: context, ctx: context || @
    @
  #### off(name, callback, context)
  #> Removes an event listener
  off: (name, callback, context)->
    return @ if !@_events || !eventsApi(@, 'off', name, [callback, context])
    if (!name && !callback && !context)
      @_events = {};
      return @
    keys = (o)->
      a = []
      for n,x of o
        a.push n
      a
    for ord,name of (names = if name then [name] else keys @_events)
      if (events = @_events[name]) 
        @_events[name] = retain = []
        if (callback || context)
          for evt of events
            retain.push evt if (callback && callback != evt.callback) && (callback != evt.callback._callback) || (context && context != evt.context)
        delete @_events[name] if !retain.length     
    @
  #### trigger(name, ...)
  #> Dispatches an event 
  trigger: (name)->
    return @ if !@_events
    args = [].slice.call arguments, 1
    return @ if !eventsApi @, 'trigger', name, args
    events    = @_events[name]
    allEvents = @_events.all
    triggerEvents events, args if events
    triggerEvents allEvents, arguments if allEvents
    @
eventSplitter = /\s+/
#### eventsApi(name, callback, context)
#> Implementation of Backbone's eventsAPI
eventsApi = (obj, action, name, rest)->
  return true if !name
  if typeof name == 'object'
    for key of name
      obj[action].apply obj, [key, name[key]].concat rest
    false
  if eventSplitter.test name
    names = name.split eventSplitter
    for idx of names
      obj[action].apply obj, [names[idx]].concat rest
    false
  true
#### triggerEvents(events, args)
#> Implementation of Backbone's triggerEvents
triggerEvents = (events, args)->
  i = -1
  l = events.length
  a1 = args[0]
  a2 = args[1]
  a3 = args[2]
  switch (args.length)
    when 0
      while (++i < l) 
        (ev = events[i]).callback.call(ev.ctx) 
      return
    when 1
      while (++i < l)
        (ev = events[i]).callback.call(ev.ctx, a1) 
      return
    when 2
      while (++i < l) 
        (ev = events[i]).callback.call(ev.ctx, a1, a2)
      return
    when 3
      while (++i < l) 
        (ev = events[i]).callback.call(ev.ctx, a1, a2, a3)
      return
    else
      while (++i < l) 
        (ev = events[i]).callback.apply(ev.ctx, args)
# supports `bind` usage
Events.bind   = Events.on
# supports `unbind` usage
Events.unbind = Events.off
#### require_tree(uPath, [options])
#> Loads given path hierarchy into package structure
exports.require_tree = (uPath=null, options={})->
  'use strict'
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
  extend @, Events
  @on 'completed', options.completed, @ if options.completed? and typeof options.completed == 'function'
  @on 'changed', options.changed, @ if options.changed? and typeof options.changed == 'function'
  # a local version of dirname thatwill replace path '.' with and empty string for internal use
  dirname = (p)->
    (path.dirname p).replace /^\.+$/, ''
  # clean up the uPath and set as the root path to the package we are importing -- we will use this to filter
  _root = (path.normalize uPath || '.').split(path.sep).join path.sep
  # Our packages object that we will build and return 
  module.exports.packages = packages = extend options.packages || {}, require_tree: (extend {}, Events)
  # returns the path parts as an array
  parsePath = (p)-> p.replace(new RegExp("^\\.?(\\#{path.sep})"),'').split path.sep
  # returns a path woth the _root filtered out
  getPwd = (p)->
    # p.replace new RegExp("^(\\.\\#{path.sep})?#{(parsePath _root).join '\\'+path.sep}\\#{path.sep}"), ''
    p.replace new RegExp("^(\\.\\#{path.sep})?#{parsePath(_root).join '\\'+path.sep}+\\#{path.sep}?"), ''#).split(path.sep).shift()
  # adds a given path to the Package
  appendPackage = (p)->
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
        return null if s[d].length
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
        catch e
          throw new Error e
          return false
        if stat?.isDirectory()
          # add this directory to our Package
          appendPackage pwd
          # walk this directory
          walker file
        else 
          # we only handle JS and JSON files
          continue if !path.extname(file).match /^\.js+(on)?$/
          try
            # detect path formatting -- default is to ditch the filenames
            if !options.preserve_filenames
              # composite this Package (FYI: will join all.json and .js file contents into one package item)
              if typeof (x = require fs.realpathSync "#{file}") != 'function' and !(x instanceof Array)
                # added kludge to fix addTree calls from completely unrelated paths
                # if x instanceof Object  
                o = extend (getPackage(dirname pwd) || getPackage(dirname(pwd).split(path.sep).pop())), x
                # else
                  # console.log "dirname: #{dirname pwd}"
                  # o = [] if !((o = getPackage(dirname pwd) || getPackage dirname(pwd).split(path.sep).pop() ) instanceof Array)
                  # o.push x
              else
                # if we have orphaned functions, we will ignore the directive and append the function with the filename
                (m = {})[if (n = name.split('.').shift()) == 'index' then _root.split(path.sep).pop() else n] = x
                o = extend (getPackage dirname pwd), m
            else
              # then we keep file names in the package path structure
              if name.match /^index+/
                # if we have an index, we will build this directly into the current package
                o = getPackage ((p=parsePath pwd).slice 0, p.length - (if p.length > 1 then 1 else 0) ).join path.sep
                # composite this Package (FYI: will join index.json and index.js into one package item)
                o = extend o, r = require fs.realpathSync "#{file}" 
              else
                # we will append a new Package for each unique file name (excluding ext)
                o = if (o = getPackage dirname pwd)? then o else appendPackage (parsePath pwd).join path.sep
                # add the module or JSON structure to the current Package
                v = extend o[name.split('.').shift()] || {}, require fs.realpathSync "#{file}"
                o[name.split('.').shift()] = v
          catch e
            throw new Error e
            return false
    true
  # packages getPackage method for consumptions by caller
  packages.require_tree.getPackage = 
  # exports getTree for loaded module consumptions
  exports.getTree = (p)->
    getPackage "#{(p ?= '.').replace /\./, path.sep}"
  # packages addTree method for consumptions by caller
  packages.require_tree.addTree =
  # exports addTree for loaded module consumptions
  exports.addTree = (p) ->
    _oR = _root
    _root = initial(b = p.split path.sep).join path.sep
    packages[_ns = b] ?= (packages[_ns = b] = {})
    if walker p
      _root = _oR
      # dispatches changed event with added tree
      Events.trigger.call @, 'changed', {packages:packages, added:packages[b] || {}}
      # exports current packages
      return exports.packages = packages
    _root = _oR
    false
  # packages extendTree method for consumptions by caller
  packages.require_tree.extendTree =
  # exports extendTree for loaded module consumptions
  exports.extendTree = (obj) ->
    packages = extend packages, obj
    # dispatches changed event with added tree
    Events.trigger.call @, 'changed', {packages:packages, added:obj}
  # packages removeTree method for consumptions by caller
  packages.require_tree.removeTree =
  # exports removeTree for loaded module consumptions
  exports.removeTree = (p) ->
    pkg = getPackage initial(s=p.replace(/\./g,path.sep).split path.sep).join path.sep
    try
      if (rm = pkg[s[s.length-1]])?
        # deletes the found tree
        delete pkg[s[s.length-1]]
        # dispatches changed event with removed tree
        Events.trigger.call @, 'changed', {packages:packages, removed:rm}
    catch e
      throw new Error e
  extend packages.require_tree, Events
  # walk the given path if uPath is set
  walker uPath, null, null if uPath?
  # dispatches 'completed' event
  Events.trigger.call this, 'completed', packages
  # returns the packaged contents
  packages