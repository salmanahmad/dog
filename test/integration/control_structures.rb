#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::ControlStructuresTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_simple
    program = <<-EOD
    i = 0
    IF i == 0 THEN
      i = "foobar"
    END
    EOD

    tracks = run_source(program)
    assert_equal("foobar", tracks.last.variables["i"].value)
    assert_equal("foobar", tracks.last.stack.last.value)
  end
  
  def test_else
    program = <<-EOD
    i = 1
    IF i == 0 THEN
      i = "if"
    ELSE IF i == 1 THEN
      i = "else if"
    END
    EOD

    tracks = run_source(program)
    assert_equal("else if", tracks.last.variables["i"].value)
    assert_equal("else if", tracks.last.stack.last.value)

    program = <<-EOD
    i = 3
    IF i == 0 THEN
      i = "if"
    ELSE IF i == 1 THEN
      i = "else if"
    ELSE
      i = "else"
    END
    EOD

    tracks = run_source(program)
    assert_equal("else", tracks.last.variables["i"].value)
    assert_equal("else", tracks.last.stack.last.value)
  end
  
  def test_assigment
    program = <<-EOD
    i = 0
    x = IF i == 0 THEN
      i = "foobar"
    END
    EOD

    tracks = run_source(program)
    assert_equal("foobar", tracks.last.variables["x"].value)
  end

end
