#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::WhileTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :while
    @parser.should_clean_tree = false
  end
  
  def test_simple
    program = <<-EOD

WHILE 5 DO
  i = 5 + 5
END

EOD
    
    program.strip!
    
    @parser.parse(program)
    
    
    program = <<-EOD

WHILE false DO
  PRINT 'hello'
  PRINT 'hi'
END

EOD

    program.strip!
    node = @parser.parse(program)
  end
  
end