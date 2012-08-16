#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::PackageTest < Test::Unit::TestCase
  def test_simple
    program = <<-EOD
    PACKAGE foo
    
    a = "Foobar"
    b = 7 + 7
    c = {
      test = true
      good_test = false
    }
    EOD
    
    parser = ::Dog::Parser.new
    pst = parser.parser.parse(program)
    assert_equal("foo", pst.package)
    
    
    
    program = <<-EOD
    PACKAGE foobar
    
    a = "Foobar"
    b = 7 + 7
    c = {
      test = true
      good_test = false
    }
    EOD
    
    parser = ::Dog::Parser.new
    pst = parser.parser.parse(program)
    assert_equal("foobar", pst.package)
    
    
    program = <<-EOD
    a = "Foobar"
    b = 7 + 7
    c = {
      test = true
      good_test = false
    }
    EOD
    
    parser = ::Dog::Parser.new
    pst = parser.parser.parse(program)
    assert_equal("", pst.package)
    
  end
  
  
  def test_multiple_package
    program = <<-EOD
    
    PACKAGE bar
    
    a = "Foobar"
    b = 7 + 7
    c = {
      test = true
      good_test = false
    }
    
    PACKAGE foo
    EOD
    
    parser = ::Dog::Parser.new
    pst = parser.parser.parse(program)
    assert_equal("foo", pst.package)
  end
end