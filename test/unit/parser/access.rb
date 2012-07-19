#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::AccessTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :access
  end
  
  def test_simple
    @parser.parse("foo['bar' + 6]")
    @parser.parse("foo['bar' + 6]['foo']['bar']")
    @parser.parse("foo[6]")
  end
  
  
  
end