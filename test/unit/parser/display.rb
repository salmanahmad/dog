#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::DisplayTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
  end
  
  def test_display
    @parser.parse("DISPLAY message TO public")
    @parser.parse("DISPLAY message TO user")
    @parser.parse("DISPLAY message TO package.global")
    @parser.parse("DISPLAY message TO people FROM mit WHERE gpa > 8 ")
    @parser.parse("DISPLAY message TO external package.global")
    @parser.parse("DISPLAY message TO internal package.global")

  end
  
  
  
end