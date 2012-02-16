#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class ParserTests::IfTest < Test::Unit::TestCase
  
  def setup
    @parser = Dog::Parser.new
    @parser.parser.root = :if
  end
  
  def test_empty_if
    program = <<-EOD
    IF true THEN 
      
    END
    EOD
    
    @parser.parse(program.strip)
  end
  
  def test_statements
    program = <<-EOD
IF (i == 9) THEN

  a = 5
  b = a + 5
  c = 'Hello, World!'

END
    EOD
    
    @parser.parse(program.strip)
    
  end
  
  def test_indent
    program = <<-EOD
    IF (i == 9) THEN

    a = 5
    b = a + 5
    c = 'Hello, World!'

    END
    EOD

    @parser.parse(program.strip)

  end
  
  def test_conditions
    program = <<-EOD
    IF (i == 9) AND (d == 7) THEN

    a = 5
    b = a + 5
    c = 'Hello, World!'

    END
    EOD

    @parser.parse(program.strip)

  end
  
  def test_else
    # TODO - Add a test case for else statements
  end
  
  def test_operator
    
    program = <<-EOD
    IF waiting_users.count > 0 THEN
      a = 5
      b = a + 5
      c = 'Hello, World!'
    END
    EOD

    @parser.parse(program.strip)
  end
  
  def test_else
    program = <<-EOD
    IF waiting_users.count > 0 THEN
      PRINT 'foo'
      PRINT 'foo'
      PRINT 'foo'
    ELSE
      PRINT 'bar'
    END
    EOD
    
    # TODO Add tests to ensure that ELSE is working correctly...
    @parser.parse(program.strip)
  end
  
end