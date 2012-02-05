#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ExpressionTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :expression
  end
  
  def test_assignment
    @parser.parse("i = ASK ME TO 'rank'")
    
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
    @parser.parse("5 + 5")
    @parser.parse("5 + 5 + 5 + 5")
    @parser.parse("(5) + (5 + 5) + 5")
    @parser.parse("(5) UNION (5 - 5) / 5")
    @parser.parse("foo = (5) UNION (5 - 5) / 5")
  end
  
  def test_access
    @parser.parse("foo")
    @parser.parse("foo.bar")
    @parser.parse("foo.bar.baz")
    @parser.parse("foo.bar.baz.poo")
    
    @parser.parse("foo[bar]")
    @parser.parse("foo[bar[bar]]")
    @parser.parse("(foo[bar])[baz]")
    @parser.parse("foo[bar][baz[foo][bar]][poo]")
    
    @parser.parse("foo's bar's baz")
    @parser.parse("foo's bars' baz")
  end
  
end