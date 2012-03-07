#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class RuntimeTests::PrintTest < RuntimeTestCase
  
  def test_simple
    # TODO
    return
    
    output = run_code("PRINT 'Hello? Yes, this is Dog.'")
    assert_equal(output, "Hello? Yes, this is Dog.")
    
    output = run_code("INSPECT 'Hello? Yes, this is Dog.'")
    assert_equal(output, "\"Hello? Yes, this is Dog.\"")
  end
  
  
end