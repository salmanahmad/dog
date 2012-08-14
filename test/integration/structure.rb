#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::StructureTest < Test::Unit::TestCase
  include RuntimeHelper
  
  def test_simple
    program = <<-EOD
    user = {
      name = "foo"
      age = 7
    }
    
    PRINT user.name
    
    name = user.name
    age = user["age"]
    EOD

    tracks, output = run_source(program, true)
    assert_equal("foo", output)
    assert_equal("foo", tracks.last.variables["name"].value)
    assert_equal(7, tracks.last.variables["age"].value)
  end

  def test_construction
    program = <<-EOD
    user = {}
    
    user.name = "foobar"
    user.age = 7
    user.properties = {
      admin = true
    }
    
    name = user.name
    age = user["age"]
    admin = user["properties"]["admin"]
    EOD
    
    tracks = run_source(program)
    
    assert_equal("foobar", tracks.last.variables["name"].value)
    assert_equal(7, tracks.last.variables["age"].value)
    assert_equal(true, tracks.last.variables["admin"].value)
  end
  
  
end
