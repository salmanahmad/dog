#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::ProgramTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
  end
  
  def test_config
    @parser.parse("foo; bar; baz;")
    @parser.parse("foo;bar;baz;")
    @parser.parse("foo;bar;baz")
    @parser.parse("\n\n\nfoo;bar;baz\n\n\n")
    @parser.parse(" ; ; ;")
    @parser.parse(";;;")
    @parser.parse("\n\n\n")
  end
  
end