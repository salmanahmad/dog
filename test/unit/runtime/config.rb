#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class RuntimeTests::ConfigTest < RuntimeTestCase
  
  def test_integer
    # TODO
    return
    
    assert_equal(Dog::Config.get('port'), nil)
    run_code("CONFIG port = 3000")
    assert_equal(Dog::Config.get('port'), 3000)
  end
  
  def test_string
    # TODO
    return
    
    assert_equal(Dog::Config.get('api_key'), nil)
    run_code("CONFIG api_key = 'foobar'")
    assert_equal(Dog::Config.get('api_key'), "foobar")
  end
  
  def test_boolean
    # TODO
    return
    
    assert_equal(Dog::Config.get('debug'), nil)
    run_code("CONFIG debug = true")
    assert_equal(Dog::Config.get('debug'), true)
  end
  
  def test_array
    # TODO
    return
    
    assert_equal(Dog::Config.get('options'), nil)
    run_code("CONFIG options = [1,2,'hi']")
    assert_equal(Dog::Config.get('options'), [1,2,'hi'])
  end
  
  
end