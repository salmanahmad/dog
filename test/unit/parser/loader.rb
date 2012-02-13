#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::LoadTest < Test::Unit::TestCase
  
  def test_parser_module
    assert_raise NameError do
      ::DogParser
    end
    
    assert_raise NameError do
      DogParser
    end
    
    assert_nothing_raised do
      Dog::Parser
      Dog::DogParser
    end
  end
  
end