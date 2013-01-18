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
  
  def test_repeat
    
    program = <<-EOD

REPEAT 5 TIMES
  i = 5 + 5
END

EOD
    
    program.strip!
    
    @parser.parse(program)
    
    
    
    program = <<-EOD

REPEAT 5 DO
  i = 5 + 5
END

EOD
    
    program.strip!
    
    @parser.parse(program)
  end
  
  def test_forever
    program = <<-EOD

FOREVER DO
  i = 5 + 5
END

EOD
    
    program.strip!
    
    @parser.parse(program)
    
    
    
    program = <<-EOD

FOREVER DO
  i = 5 + 5
  IF i == 10 DO
    BREAK
  END
END

EOD
    
    program.strip!
    
    @parser.parse(program)
  end
  
end