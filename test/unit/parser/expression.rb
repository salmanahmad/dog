#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::ExpressionTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :expression
  end
  
  def test_assignment
    @parser.parse("i = ASK ME VIA email TO rank")
    
    @parser.parse("i = 0")
    @parser.parse("i = 1")
    @parser.parse("i = -1")
    @parser.parse("i = 1.1")
    @parser.parse("i = -1.1")
    @parser.parse("i = true")
    @parser.parse("i = false")
    @parser.parse("i = [1,2,3]")
    @parser.parse('i = "Foo bar"')
    @parser.parse("i = 'Foo bar'")
    @parser.parse("i = {'key':'value'}")
    
    @parser.parse("i.j = 8") 
    @parser.parse("i[i] = {'key':'value'}")
    @parser.parse("i[0] = {'key':'value'}")
    @parser.parse("i['string'] = {'key':'value'}")
    @parser.parse("i[j[k]][l] = {'key':'value'}")
    
    @parser.parse("i.j.k.l = {'key':'value'}")
    
    @parser.parse("i's j's k = {'key':'value'}")
  end
  
  def test_literals
    @parser.parse("i = task")
    @parser.parse("i = task {}")
    @parser.parse("i = task {'key':'value'}")
  end
  
  def test_operation
    @parser.parse("NOT TRUE")
    @parser.parse("5 + 5")
    @parser.parse("5 + 5 + 5 + 5")
    
    
    @parser.parse("5 + 5 + foo['hi']['world'] + 5")
    @parser.parse("5 + 5 + (foo['hi']['world']) + 5")
    @parser.parse("5 + 5 + (((foo['hi']['world']))) + 5")
    
    # TODO - Fix the order of operations. Division should be stronger than addition.
    # You should take a look at how Koi does this. They encode that directly in the
    # grammar...
    @parser.parse("5 + 5 / 2")
    @parser.parse("5 / 2 + 5")
    @parser.parse("(5) + (5 + 5) + 5")
    @parser.parse("(5) UNION (5 - 5) / 5")
    @parser.parse("foo = (5) UNION (5 - 5) / 5")
  end
  
  def test_access
    @parser.parse("foo")
    @parser.parse("foo.bar") 
    @parser.parse("foo.bar.baz")
    @parser.parse("foo.bar.baz.poo")
    @parser.parse("foo.bar['hi']")
    
    @parser.parse("foo[bar]")
    
    @parser.parse("foo[bar][baz]")
    @parser.parse("foo[bar[bar]]")
    @parser.parse("(foo[bar])[baz]")
    @parser.parse("foo[bar][baz[foo][bar]][poo]")
    
    @parser.parse("foo's bar's baz")
    @parser.parse("foo's bars' baz")
  end
  
end