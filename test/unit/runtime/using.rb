#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class RuntimeTests::UsingTest < RuntimeTestCase
  
  def test_simple
    # TODO
    return
    
    # Note: I need to space for this mock to work. It is okay.
    output = run_code(" USING foo: 'baz', bar : 3", :using_clause)
    assert_equal(output, {"foo" => 'baz', "bar" => 3})
  end
  
  
end