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
  end
  
  def test_assignment
    @parser.parser.root = :assignment
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
  end
  
end