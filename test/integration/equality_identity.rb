#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::EqualityIdentityTest < Test::Unit::TestCase
  include RuntimeHelper
  
  def test_equality
    program = <<-EOD
      a = "foo" == "bar"
      b = "foo" == "foo"
      
      c = 1 == 2
      d = 1 == 1
      
      e = {
        a = "foo"
        c = "bar"
      } == {
        a = "foo"
        b = "bar"
      }
      
      
      f = {
        a = "foo"
        b = "bar"
      } == {
        a = "foo"
        b = "bar"
      }
      
      g = {
        a = "foo"
        b = {}
      } == {
        a = "foo"
        b = {}
      }
      
      h = {
        a = "foo"
        b = {
          c = "foo"
        }
      } == {
        a = "foo"
        b = {
          c = "bar"
        }
      }
      
    EOD
    
    tracks = run_source(program)
    assert_equal(false, tracks.last.variables["a"].value)
    assert_equal(true, tracks.last.variables["b"].value)
    
    assert_equal(false, tracks.last.variables["c"].value)
    assert_equal(true, tracks.last.variables["d"].value)
    
    assert_equal(false, tracks.last.variables["e"].value)
    assert_equal(true, tracks.last.variables["f"].value)
    
    assert_equal(true, tracks.last.variables["g"].value)
    assert_equal(false, tracks.last.variables["h"].value)
  end
  
  def test_inequality
    program = <<-EOD
      a = "foo" != "bar"
      b = "foo" != "foo"
      
      c = 1 != 2
      d = 1 != 1
      
      e = {
        a = "foo"
        c = "bar"
      } != {
        a = "foo"
        b = "bar"
      }
      
      
      f = {
        a = "foo"
        b = "bar"
      } != {
        a = "foo"
        b = "bar"
      }
      
      g = {
        a = "foo"
        b = {}
      } != {
        a = "foo"
        b = {}
      }
      
      h = {
        a = "foo"
        b = {
          c = "foo"
        }
      } != {
        a = "foo"
        b = {
          c = "bar"
        }
      }
      
    EOD
    
    tracks = run_source(program)
    assert_equal(true, tracks.last.variables["a"].value)
    assert_equal(false, tracks.last.variables["b"].value)
    
    assert_equal(true, tracks.last.variables["c"].value)
    assert_equal(false, tracks.last.variables["d"].value)
    
    assert_equal(true, tracks.last.variables["e"].value)
    assert_equal(false, tracks.last.variables["f"].value)
    
    assert_equal(false, tracks.last.variables["g"].value)
    assert_equal(true, tracks.last.variables["h"].value)
  end
  
  def test_identical
    program = <<-EOD
      a = "foo" === "bar"
      b = "foo" !== "bar"
      
      c = {
        a = "hi"
      }
      
      d = c
      
      e = c === d
      f = c !== d
      
      d.a = "bye"
      
      g = c == d
      h = c === d
      
      
    EOD

    tracks = run_source(program)
    assert_equal(false, tracks.last.variables["a"].value)
    assert_equal(true, tracks.last.variables["b"].value)

    assert_equal(true, tracks.last.variables["e"].value)
    assert_equal(false, tracks.last.variables["f"].value)

    assert_equal(false, tracks.last.variables["g"].value)
    assert_equal(true, tracks.last.variables["h"].value)

  end
  
end
