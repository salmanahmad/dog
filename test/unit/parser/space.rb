#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::SpaceTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
  end
  
  def test_simple
    @parser.parse("")
    @parser.parse("    ")
    @parser.parse("\n")
    @parser.parse(" \n")
    @parser.parse(" \n\n  \n\n   ")
    @parser.parse(" \n   \n  \n\n\n     \n\n\n   \n\n    \n")
    @parser.parse("\n\n  \n\n  i = 'foobar'  \n\n")
    @parser.parse("\n\n  \n\n  i = 'foobar'\n5+5  \n\n")
    @parser.parse("\n\n  \n\n  i = 'foobar'\n5 +  5  \n\n")
    @parser.parse("i = 'foobar'")
    @parser.parse("i = 'foobar'\n")
    @parser.parse(" # comments")
    @parser.parse("# comments")
    @parser.parse("1+2# comments")
    @parser.parse("\n\n1+2# comments\n\n")
  end
  
end