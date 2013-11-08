fs              = require 'fs'
(chai           = require 'chai').should()
{require_tree}  = require '../src/require_tree.coffee'
describe 'require_Tree Test Suite', ->
  it 'should exist', =>
    require_tree.should.be.a 'Function'
  it 'should load tree', =>
    {config, foo, bar, multiIndex, conditions, aClass, require_tree} = require_tree "./test/lib", {preserve_filenames:false,locals:{condition:2, test:"foo"}}
    @foo = foo
    @bar = bar
    @aClass = aClass
    @multiIndex = multiIndex
    @conditions = conditions
    @config = config
  it 'should have Objects', =>
    @foo.aClass.should.be.a 'Function'
    @foo.NoName.should.be.a 'Function'
    @bar.aClass.should.be.a 'Function'
    @bar.bClass.should.be.a 'Function'
    @aClass.should.be.a 'Function'
    @conditions.should.be.a "Object"
    @config.should.be.a "Object"
    (new @bar.aClass).should.be.a 'Object'
    (new @bar.bClass).should.be.a 'Object'
    (new @foo.aClass).should.be.a 'Object'
  it 'should have events', =>
    require_tree.on.should.be.a 'Function'
    require_tree.off.should.be.a 'Function'
  it 'should have Functions that return values', =>
    (@bar.aClass()).should.equal 'BAR::aClassValue'
    (@bar.bClass()).should.equal 'BAR::bClassValue'
    (new @foo.aClass()).aFunct().should.equal 'FOO::aFunctValue' 
  it 'should have Object methods', =>
    (new @bar.aClass).aFunct.should.be.a 'Function'
    (new @bar.bClass).bFunct.should.be.a 'Function'
    (new @foo.aClass).aFunct.should.be.a 'Function'
    (new @bar.aClass).aFunct().should.equal 'BAR::aFunctValue'
    (new @bar.bClass).bFunct().should.equal 'BAR::bFunctValue'
    (new @foo.aClass).aFunct().should.equal 'FOO::aFunctValue'
  it 'should have Nested Objects', =>
    (@bar.baz).should.be.a 'Object'
  it 'Nested Objects should have Functions', =>
    (@foo).fooFunc.should.be.a 'Function'
    (@bar.baz).bazFunc.should.be.a 'Function'
  it 'should have Functions that return values', =>
    @foo.fooFunc().should.equal 'FOO::fooFunc'
  it 'should have locals passed to Nested Objects', =>
    (@bar.baz).bazFunc().should.equal 'BAR::BAZ::bazFunct locals.test: [foo]'
  it 'should include JSON Objects', =>
    (@bar.baz).should.be.a 'Object'
    (@bar.baz).a.should.equal 'Value A'
    (@bar.baz).c.c1.length.should.equal 3
  it 'Packages should load and use other packages', =>
    #(lib = require_tree('./test/lib')).should.be.a 'Object'
    (new @bar.bClass()).getAFunct.should.be.a 'Function'
    (new @bar.bClass()).getAFunct().should.equal 'FOO::aFunctValue'
  it 'should load Nested Packages', =>
    (bar = require('../src/require_tree').require_tree('./test/lib/bar')).should.be.a 'Object'
    # (new bar.aClass()).aFunct.should.be.a 'Function'
    # (new bar.aClass()).aFunct().should.equal 'BAR::aFunctValue'
  it 'should directly load paths that only contain indexes', =>
    (require('../src/require_tree').require_tree "./test/lib/indexOnly").indexOnlyFunct.should.be.a 'Function'
  it 'should merge multiple types of indexes on the same path', =>
    @multiIndex.multiIndexFunct.should.be.a 'Function'
    @multiIndex.value.should.equal 'multiIndex'
  it 'should conditionally load Paths', =>
    @conditions.methods.should.be.a 'Object'
    @conditions.methods.value.should.equal false
  it 'should keep folder names in package when directed', =>
    {foo, bar, conditions, a, multiIndex} = require('../src/require_tree').require_tree "./test/lib", preserve_filenames:true
    foo.a.aClass.should.be.a 'Function'
    bar.a.aClass.should.be.a 'Function'
    bar.b.bClass.should.be.a 'Function'
    a.aClass.should.be.a 'Function'
    conditions.should.be.a "Object"
    (new bar.a.aClass).should.be.a 'Object'
    (new bar.b.bClass).should.be.a 'Object'
    (new foo.a.aClass).should.be.a 'Object'
  it 'should respond to boolean directive value', =>
    {foo, bar, conditions, a,multiIndex} = require('../src/require_tree').require_tree "./test/lib", preserve_filenames:false
    foo.should.not.have.property 'a'
  it 'should Add a path', =>
    @tree = require('../src/require_tree').require_tree "./test/lib"
    @tree.should.not.have.property 'subtree'
    @tree.require_tree.addTree './test/include/subtree'
    @tree.should.have.property 'subtree'
  it 'should Get a path', =>
    (subTree = @tree.require_tree.getPackage( 'subtree' )).should.have.property 'a'
    (new subTree.a.AClass()).callSubTreeFunct().should.equal "SubTreeClass::aFunctValue"
  it 'should be Extended', =>
    @tree.require_tree.extendTree {extender:"extending value"}
    @tree.should.have.property 'extender'
  it 'should Remove a path', =>
    @tree.require_tree.removeTree './subtree'
    @tree.should.not.have.property 'subtree'
  it 'should take an empty path', =>
    @tree = require('../src/require_tree').require_tree null, packages:@tree
  it 'should merge packages set in options', =>
    @tree.should.have.property 'foo'
  it 'should dispatch a completed Event',(done) =>
    (@rT = require('../src/require_tree')).on 'completed', (pkg)->
      done() if pkg.should.be.a 'object'
    @rT.require_tree( "./test/lib" )
  it 'should dispatch a changed Event on extendTree',(done) =>
    (@rT).on 'changed', (pkg)=>
      (@rT).off 'changed'
      done() if pkg.should.have.property('added') && pkg.added.should.have.property('extender')
    @rT.extendTree extender:"extending value"
  it 'should dispatch a changed Event on addTree',(done) =>
    (@rT).on 'changed', (pkg)=>
      (@rT).off 'changed'
      done() if pkg.should.have.property('added') && pkg.added.should.have.property('value')
    @rT.addTree './test/data/condition_1'
  it 'should dispatch a changed Event on removeTree',(done) =>
    (@rT).on 'changed', (pkg)=>
      (@rT).off 'changed'
      done() if pkg.should.have.property('removed') && pkg.removed.should.have.property('value')
    @rT.removeTree 'condition_1'
  it 'should dispatch an arbitrar Event',(done) =>
    (@rT).on 'arbitrary', (pkg)=>
      (@rT).off 'arbitrary'
      done() if pkg.should.have.property('data') && pkg.data.should.have.property('value')
    @rT.trigger 'arbitrary', data:value:"arbitrary"