#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class RuntimeTests::MathTest < RuntimeTestCase
  
  def test_simple
    output = run_code("PRINT 5 + 5")
    assert_equal(output, 10.inspect)
    
    output = run_code("PRINT 5 + 5 - 10")
    assert_equal(output, 0.inspect)
    
    output = run_code("i = 5 + 5 - 10; PRINT i")
    assert_equal(output, 0.inspect)
  end
  
  def test_multiplication
    
  end
  
  def test_order_of_operations
    output = run_code("i = 5 + 5 * 10; PRINT i")
    assert_equal(output, 55.inspect, "Order of operations are not working correctly")
    
    output = run_code("i = 5 * 5 + 10; PRINT i")
    assert_equal(output, 35.inspect, "Order of operations are not working correctly")
  end
  
  
end