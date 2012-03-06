#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::ReplyTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :reply
  end
  
  def test_simple
    @parser.parse("REPLY TO PERSON FROM request WITH data")
    @parser.parse("REPLY TO PERSON FROM request WITH data, constant = 7")
    @parser.parse("REPLY TO PERSON FROM request WITH data, constant = 7, name = 'spongebob'")
  end
  
  def test_with_required
    assert_raises Dog::ParseError do
      @parser.parse("REPLY TO PERSON FROM request")
    end
  end
  
  def test_person_required
    assert_raises Dog::ParseError do
      @parser.parse("REPLY WITH data")
    end
    
    assert_raises Dog::ParseError do
      @parser.parse("REPLY TO WITH data")
    end
  end
  
end