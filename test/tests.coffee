fs              = require 'fs'
(chai           = require 'chai').should()
{require_tree}  = require '../src/require_tree.coffee'
describe 'require_Tree Test Suite', ->
  it 'should exist', =>
    require_tree.should.be.a 'Function'
  it 'should load tree', =>
    exports.myValue = "true"
    {foo, bar, conditions, aClass, multiIndex} = require_tree "./test/lib", locals:{condition:2, test:"foo"}
    @foo = foo
    @bar = bar
    @aClass = aClass
    @multiIndex = multiIndex
    @conditions = conditions
  it 'should have Objects', =>
    @foo.aClass.should.be.a 'Function'
    @bar.aClass.should.be.a 'Function'
    @bar.bClass.should.be.a 'Function'
    @aClass.should.be.a 'Function'
    @conditions.should.be.a "Object"
    (new @bar.aClass).should.be.a 'Object'
    (new @bar.bClass).should.be.a 'Object'
    (new @foo.aClass).should.be.a 'Object'
  it 'should have Functions that return values', =>
    (@bar.aClass()).should.equal 'BAR::aClassValue'
    (@bar.bClass()).should.equal 'BAR::bClassValue'
    (@foo.aClass()).should.equal 'FOO::aClassValue' 
  it 'should have Object methods', =>
    (new @bar.aClass).aFunct.should.be.a 'Function'
    (new @bar.bClass).bFunct.should.be.a 'Function'
    (new @foo.aClass).aFunct.should.be.a 'Function'
  it 'should have Object methods', =>
    (new @bar.aClass).aFunct().should.equal 'BAR::aFunctValue'
    (new @bar.bClass).bFunct().should.equal 'BAR::bFunctValue'
    (new @foo.aClass).aFunct().should.equal 'FOO::aFunctValue'
  it 'should have Nested Objects', =>
    (@bar.baz).should.be.a 'Object'
  it 'Nested Objects should have Functions', =>
    (@foo).fooFunc.should.be.a 'Function'
    (@bar.baz).bazFunc.should.be.a 'Function'
  it 'should have Functions that return values', =>
    (@foo).fooFunc().should.equal 'FOO::fooFunc'
  it 'should have locals passed to Nested Objects', =>
    (@bar.baz).bazFunc().should.equal 'BAR::BAZ::bazFunct locals.test: [foo]'
  it 'should include JSON Objects', =>
    (@bar.baz).should.be.a 'Object'
    (@bar.baz).a.should.equal 'Value A'
    (@bar.baz).c.c1.length.should.equal 3
  it 'should load Nested Packages', =>
    (bar = require_tree('./test/lib/bar')).should.be.a 'Object'
    (new bar.aClass()).aFunct.should.be.a 'Function'
    (new bar.aClass()).aFunct().should.equal 'BAR::aFunctValue'
  it 'Packages should load and use other packages', =>
    (bar = require_tree('./test/lib/bar')).should.be.a 'Object'
    (new bar.bClass()).getAFunct.should.be.a 'Function'
    (new bar.bClass()).getAFunct().should.equal 'BAR::aFunctValue'
  it 'should directly load paths that only contain indexes', =>
    (require_tree "./test/lib/indexOnly").indexOnlyFunct.should.be.a 'Function'
  it 'should merge multipple types of indexes on the same path', =>
    @multiIndex.multiIndexFunct.should.be.a 'Function'
    @multiIndex.value.should.equal 'multiIndex'
  it 'should conditionally load Paths', =>
    @conditions.methods.should.be.a 'Object'
    @conditions.methods.value.should.equal false
  it 'should keep folder names in package when directed', =>
    {foo, bar, conditions, a,multiIndex} = require_tree "./test/lib", preserve_filenames:true
    foo.a.aClass.should.be.a 'Function'
    bar.a.aClass.should.be.a 'Function'
    bar.b.bClass.should.be.a 'Function'
    a.aClass.should.be.a 'Function'
    conditions.should.be.a "Object"
    (new bar.a.aClass).should.be.a 'Object'
    (new bar.b.bClass).should.be.a 'Object'
    (new foo.a.aClass).should.be.a 'Object'
  it 'should respond to boolean directive value', =>
    {foo, bar, conditions, a,multiIndex} = require_tree "./test/lib", preserve_filenames:false
    foo.should.not.have.property 'a'
