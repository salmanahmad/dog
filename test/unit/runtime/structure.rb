#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class StuctBoolean < Dog::Structure
  property "flag", :type => Dog::Boolean
end

class RuntimeTests::StructureTest < RuntimeTestCase
  
  
  def test_boolean
    s = StuctBoolean.new
    s.flag = true
    assert_equal(s.flag, true)
  end
  
  
end