#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

# TODO - This file is no longer necessary. It is being kept because
# it has an interesting scaffolding on how to test a RACK-based app.
# The actual test cases need to be updated in the future.

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class RuntimeTests::PersonTest < Test::Unit::TestCase  
  include RuntimeHelper
  
  def test_simple
    run_source("")
    
    assert_equal(0, ::Dog.database["people"].count)
    
    p = ::Dog::Person.new
    p.first_name = "salman"
    p.save
    
    assert_equal(1, ::Dog.database["people"].count)
    
    p2 = ::Dog::Person.find_by_id(p._id)
    assert_equal("salman", p2.first_name)
    
    
  end
  
end

