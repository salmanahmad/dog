#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class Balance < Dog::Event 
  property "name", :required => true, :direction => "input"
  property "amount", :required => true, :direction => "output"
end

class RuntimeTests::EventTest < RuntimeTestCase
  
  def test_simple
    b = Balance.import({"name" => "foobar"})
    assert_equal(b.class, Balance)
    
    b = Balance.import({})
    assert_equal(b, nil)
  end
  
  def test_inheritance
    p = Balance.properties
    
    assert_equal p.keys.size, 4
    ["success", "errors", "name", "amount"].each do |value|
      assert p.keys.include?(value)
    end
  end
  
end