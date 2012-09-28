#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::WaitTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
  end
  
  def test_simple
    @parser.parse("WAIT ON 5")
    @parser.parse("SPAWN COMPUTE matrix HEIGHT 500 WIDTH 500")
    
    assert_raise ::Dog::ParseError do
      @parser.parse("SPAWN 5 + 5")
    end
    
  end
  
  
  
end