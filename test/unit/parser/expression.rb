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
  
  def test_operation
    @parser.parse("NOT TRUE")
    @parser.parse("5 + 5")
    @parser.parse("5 + 5 + 5 + 5")
    
    
    @parser.parse("5 + 5 + foo['hi']['world'] + 5")
    @parser.parse("5 + 5 + (foo['hi']['world']) + 5")
    @parser.parse("5 + 5 + (((foo['hi']['world']))) + 5")
    
    @parser.parse("(5 + 5) / 2")
    @parser.parse("5 + 5 / 2")
    @parser.parse("5 / 2 + 5")
    @parser.parse("(5) + (5 + 5) + 5")
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
  end
  
end