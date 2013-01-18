#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::LiteralTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :literal
  end
  
  def test_integers
    @parser.parse("0")
    @parser.parse("1")
    @parser.parse("13")
  end
  
  def test_floats
    @parser.parse("0.0")
    @parser.parse("1.")
    @parser.parse("3.14")
  end
  
  def test_negative_integers
    @parser.parse("-0")
    @parser.parse("-1")
    @parser.parse("-13")
  end
  
  def test_negative_floats
    @parser.parse("-0.0")
    @parser.parse("-1.")
    @parser.parse("-3.14")
  end
  
  def test_booleans
    @parser.parse("true")
    @parser.parse("TRUE")
    
    @parser.parse("false")
    @parser.parse("FALSE")
  end
  
  def test_strings
    @parser.parse("'Hello, World!'")
    @parser.parse('"Hello, World!"')
    
    @parser.parse("'Hello, \" World!'")
    
    @parser.parse('"Hello, \" World!"')
    @parser.parse('"Hello, \' World!"')
    
    # TODO - Figure out this error with single quoted strings...
    #@parser.parse("'Hello, \\\\ \' World!'")
    
  end
  
  def test_array
    @parser.parse("[]")
    @parser.parse("[1]")
    @parser.parse("[1,]")
    @parser.parse("[1,2,3]")
    @parser.parse("[1,2.0,-3]")
    @parser.parse("[1   ,    2.0, -3]")
    
    @parser.parse("[1,'Foo Bar']")
    @parser.parse("[1,'Foo Bar', true, false]")
    
    @parser.parse("[[1],'Foo Bar', true, false]")
    @parser.parse("[[[[[[3.14]]]]]]")
    @parser.parse("[{'key'=5}]")
    
    assert_raise Dog::ParseError do
      @parser.parse("[1items,]")
    end
  end
  
  def test_hash
    @parser.parse("{'key'='value'}")
    @parser.parse("{\"key\"='value'}")
    
    @parser.parse("{'key'=1,}")
    
    @parser.parse("{'key'=1}")
    @parser.parse("{'key'=true}")
    @parser.parse("{'key'=-4.5}")
    
    @parser.parse("{'key'=1, 'key2'='value'}")
    
    @parser.parse("{'key'=[1,2,3]}")
    @parser.parse("{'key'=[[1]]}")
    @parser.parse("{'key'=[[1,2,true]]}")
    
    @parser.parse("{'key'={'key'='value'}}")
    
    @parser.parse("{  'key' =   1   , 'key2'  =  'value'  }")
    @parser.parse("{\n\t'key'=1,\n\t'key2'='value'\n}")
  end
  
  def test_hash_key_can_be_numbers
    @parser.parse("{1='value'}")
  end
  
end