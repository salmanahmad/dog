#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

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
  
  
  def test_find_by_email
    run_source("")
    
    assert_equal(0, ::Dog.database["people"].count)
    
    p = ::Dog::Person.new
    p.first_name = "salman"
    p.email = "salman@example.com"
    p.save
    
    p2 = ::Dog::Person.find_by_email("salman@example.com")
    
    assert_equal("salman@example.com", p2.email)
    assert_equal(p.id, p2.id)
  end
  
  
  def test_id
    run_source("")
    
    assert_equal(0, ::Dog.database["people"].count)
    
    p = ::Dog::Person.new
    p.first_name = "salman"
    p.email = "salman@example.com"
    p.save
    
    p2 = ::Dog::Person.find_by_email("salman@example.com")
    
    id = p2.id
    assert_equal(BSON::ObjectId, id.class)
    
    p3 = ::Dog::Person.find_by_id(id)
    assert_equal(p3.id, p2.id)
  end
  
end

