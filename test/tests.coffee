fs              = require 'fs'
(chai           = require 'chai').should()
{require_tree}  = require '../src/require_tree.coffee'
describe 'require_Tree Test Suite', ->
  it 'should exist', =>
    require_tree.should.be.a 'Function'
  it 'should load tree', =>
    {foo, bar, a} = require_tree "./test/lib"
    (@foo = foo).a.aClass.should.be.a 'Function'
    (@bar = bar).a.aClass.should.be.a 'Function'
    @bar.b.bClass.should.be.a 'Function'
    (@a = a).aClass.should.be.a 'Function'
  it 'should have Objects', =>
    (new @bar.a.aClass).should.be.a 'Object'
    (new @bar.b.bClass).should.be.a 'Object'
    (new @foo.a.aClass).should.be.a 'Object'
  it 'should have Functions that return values', =>
    (@bar.a.aClass()).should.equal 'BAR::aClassValue'
    (@bar.b.bClass()).should.equal 'BAR::bClassValue'
    (@foo.a.aClass()).should.equal 'FOO::aClassValue' 
  it 'should have Object methods', =>
    (new @bar.a.aClass).aFunct.should.be.a 'Function'
    (new @bar.b.bClass).bFunct.should.be.a 'Function'
    (new @foo.a.aClass).aFunct.should.be.a 'Function'
  it 'should have Object methods', =>
    (new @bar.a.aClass).aFunct().should.equal 'BAR::aFunctValue'
    (new @bar.b.bClass).bFunct().should.equal 'BAR::bFunctValue'
    (new @foo.a.aClass).aFunct().should.equal 'FOO::aFunctValue'
  it 'should have Nested Objects', =>
    (@bar.baz).should.be.a 'Object'
  it 'Nested Objects should have Functions', =>
    (@foo).fooFunc.should.be.a 'Function'
    (@bar.baz).bazFunc.should.be.a 'Function'
  it 'should have Functions that return values', =>
    (@foo).fooFunc().should.equal 'FOO::fooFunc'
    (@bar.baz).bazFunc().should.equal 'BAR::BAZ::bazFunct'
  it 'should include JSON Objects', =>
    (@bar.baz).data.should.be.a 'Object'
    (@bar.baz).data.a.should.equal 'Value A'
    (@bar.baz).data.c.c1.length.should.equal 3
  it 'should load Nested Packages', =>
    (a = require_tree('./test/lib/bar').a).should.be.a 'Object'
    (new a.aClass()).aFunct.should.be.a 'Function'
    (new a.aClass()).aFunct().should.equal 'BAR::aFunctValue'
  it 'Packages should load and use other packages', =>
    (b = require_tree('./test/lib/bar').b).should.be.a 'Object'
    (new b.bClass()).getAFunct.should.be.a 'Function'
    (new b.bClass()).getAFunct().should.equal 'BAR::aFunctValue'