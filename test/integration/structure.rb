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
  
  def test_defaults
    program = <<-EOD
    
    DEFINE car {
      wheels = 4
    }
    
    civic = car {}
    EOD
    
    tracks = run_source(program)
    assert_equal(4, tracks.last.variables["civic"].value["s:wheels"].value)
    assert_equal(4, tracks.last.variables["civic"].ruby_value["wheels"])
    
    
    program = <<-EOD
    
    DEFINE foo DO
      "foo"
    END
    
    DEFINE car {
      wheels = COMPUTE foo
    }
    
    civic = car {}
    EOD
    
    tracks = run_source(program)
    assert_equal("foo", tracks.last.variables["civic"].value["s:wheels"].value)
    assert_equal("foo", tracks.last.variables["civic"].ruby_value["wheels"])
  end
  
  def test_min_max_key
    program = <<-EOD
    
    DEFINE car {
      wheels = 4
      age = 35
    }
    
    civic = car {}
    EOD
    
    tracks = run_source(program)
    
    civic = tracks.last.variables["civic"]
    assert_equal(nil, civic.min_numeric_key)
    assert_equal(nil, civic.max_numeric_key)
    
    program = <<-EOD
    
    DEFINE car {
      wheels = 4
      age = 35
      5 = 9
      9 = 5
    }
    
    civic = car {}
    EOD
    
    tracks = run_source(program)
    
    civic = tracks.last.variables["civic"]
    
    assert_equal(5, civic.min_numeric_key)
    assert_equal(9, civic.max_numeric_key)
    
    
    
    program = <<-EOD
    
    DEFINE car {
      wheels = 4
      age = 35
      5 = 9
      9 = 5
    }
    
    civic = car {}
    civic[0] = 5
    EOD
    
    tracks = run_source(program)
    civic = tracks.last.variables["civic"]
    assert_equal(0, civic.min_numeric_key)
    assert_equal(9, civic.max_numeric_key)
    
  end
end
