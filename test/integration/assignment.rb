#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::AssignmentTest < Test::Unit::TestCase
  include RuntimeHelper
  
  def test_literal
    program = <<-EOD
    i = "Hello, World!"
    EOD
    
    tracks = run_source(program)
    assert_equal("Hello, World!", tracks.last.stack.last.value)
    assert_equal("Hello, World!", tracks.last.variables["i"].value)
    
    program = <<-EOD
    i = true
    EOD
    
    tracks = run_source(program)
    assert_equal(true, tracks.last.stack.last.value)
    assert_equal(true, tracks.last.variables["i"].value)
    
    program = <<-EOD
    i = 3.14
    EOD
    
    tracks = run_source(program)
    assert_equal(3.14, tracks.last.stack.last.value)
    assert_equal(3.14, tracks.last.variables["i"].value)
  end
  
  def test_operation
    program = <<-EOD
    i = 5 - 10 * 2
    EOD
    
    tracks = run_source(program)
    assert_equal(-15, tracks.last.stack.last.value)
    assert_equal(-15, tracks.last.variables["i"].value)
    
    program = <<-EOD
    i = (5 - 10) * 2
    EOD
    
    tracks = run_source(program)
    assert_equal(-10, tracks.last.stack.last.value)
    assert_equal(-10, tracks.last.variables["i"].value)
    
    program = <<-EOD
    i = 5 + 5
    EOD
    
    tracks = run_source(program)
    assert_equal(10, tracks.last.stack.last.value)
    assert_equal(10, tracks.last.variables["i"].value)
    
    program = <<-EOD
    i = 3.14 - 0.14
    EOD
    
    tracks = run_source(program)
    assert_equal(3, tracks.last.stack.last.value)
    assert_equal(3, tracks.last.variables["i"].value)
  end
  
  def test_multi_steps
    program = <<-EOD
    i = 3.14 - 0.14
    x = i + 1
    EOD
    
    tracks = run_source(program)
    assert_equal(4, tracks.last.stack.last.value)
    assert_equal(4, tracks.last.variables["x"].value)
    assert_equal(3, tracks.last.variables["i"].value)
  end
  
end
