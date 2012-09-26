#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::ComputeTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :compute
  end
  
  def test_simple
    @parser.parse("COMPUTE average")
    @parser.parse("COMPUTE average ON data")
    @parser.parse("COMPUTE average ON a AND b")
    @parser.parse("COMPUTE average ON a AND b")
    @parser.parse("COMPUTE average ON a THEN b USING 5")
    @parser.parse("COMPUTE average ON data USING {c = 5}")
    
    
    @parser.parse("COMPUTE histogram ON my_data MAX 100 MIN 10 TITLE 'Hello World'")
    
    @parser.parse("COMPUTE average ON 10 USING {c = 5, d = 'hello, world'}")
  end
  
end