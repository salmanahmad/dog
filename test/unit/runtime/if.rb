#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class RuntimeTests::IfTest < RuntimeTestCase
  
  def test_simple
    # TODO
    return
    
    program = <<-EOD
    
    flag = true
    IF flag THEN
      PRINT 'true'
    ELSE
      PRINT 'false'
    END
    EOD
    
    output = run_code(program.strip)
    assert_equal(output, "true")
  end
  
  def test_literal
    # TODO
    return
    
    program = <<-EOD
    
    IF false THEN
      PRINT 'true'
    ELSE
      PRINT 'false'
    END
    EOD
    
    output = run_code(program.strip)
    assert_equal(output, "false")
  end
  
  def test_expression
    # TODO
    return
    
    program = <<-EOD
    
    IF 5 == 5 THEN
      PRINT 'true'
    ELSE
      PRINT 'false'
    END
    EOD
    
    output = run_code(program.strip)
    assert_equal(output, "true")
    
    program = <<-EOD
    
    IF 5 != 5 THEN
      PRINT 'true'
    ELSE
      PRINT 'false'
    END
    EOD
    
    output = run_code(program.strip)
    assert_equal(output, "false")
  end
  
  def test_variable
    # TODO
    return
    
    program = <<-EOD
    
    data.foo.bar = 8
    data.foo.baz = 7
    
    IF (data.foo.bar == 8) AND (data.foo.baz == 7) THEN
      PRINT 'true'
    ELSE
      PRINT 'false'
    END
    EOD
    
    output = run_code(program.strip)
    assert_equal(output, "true")
  end
  
  def test_unary
    # TODO
    return
    
    program = <<-EOD
    
    data.foo.bar = 8
    data.foo.baz = 7
    
    IF NOT ((data.foo.bar == 8) AND (data.foo.baz == 7)) THEN
      PRINT 'true'
    ELSE
      PRINT 'false'
    END
    EOD
    
    output = run_code(program.strip)
    assert_equal(output, "false")
  end
  
  
end