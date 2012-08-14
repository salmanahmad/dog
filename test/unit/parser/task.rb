#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::TaskTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :function_definition
  end
  
  def test_wrong
    program = <<-EOD
DEFINE label FOR person ON image DO
  PERFORM "Hello, World"
  RETURN 5+5, foobar
END
EOD
    
    program.strip!
    assert_raise RuntimeError do
      @parser.parse(program)
    end
  end
  
  def test_correct
    program = <<-EOD
DEFINE label FOR person ON image DO
  PERFORM "Hello, World"
  RETURN foo, bar
END
EOD
    
    program.strip!
    @parser.parse(program)
  end
  
  
  
  
end
