#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::ScopeTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_local
    program = <<-EOD
    
    DEFINE car {}
    DEFINE system {}
    DEFINE cars OF car

    output = local car

    EOD

    tracks = run_source(program)
    assert_equal(nil, tracks.last.variables["output"].value)
  end

  def test_cascade
    program = <<-EOD
    
    DEFINE car {}
    DEFINE system {}
    DEFINE cars OF car


    output = car

    EOD

    tracks = run_source(program)
    assert_equal("dog.type", tracks.last.variables["output"].type)
    assert_equal("car", tracks.last.variables["output"]["name"].value)
  end
  
  def test_external
    program = <<-EOD
    
    DEFINE car {}
    DEFINE system {}
    DEFINE cars OF car

    
    system = {
      print = "Hello, World!"
    }
    
    output = external system

    EOD

    tracks = run_source(program)
    assert_equal("dog.package", tracks.last.variables["output"].type)
  end

  def test_internal
    program = <<-EOD
    
    DEFINE car {}
    DEFINE system {}
    DEFINE cars OF car
    
    
    system = {
      print = "Hello, World!"
    }
    
    output = internal system

    EOD

    tracks = run_source(program)
    assert_equal("dog.type", tracks.last.variables["output"].type)
  end



end
