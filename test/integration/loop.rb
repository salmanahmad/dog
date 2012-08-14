#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::LoopTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_simple
    program = <<-EOD
    i = 0
    x = 0

    WHILE i < 10 DO
      i = i + 1
      x = i
    END
    EOD

    tracks = run_source(program)
    assert_equal(10, tracks.last.variables["i"].value)
    assert_equal(10, tracks.last.variables["x"].value)
  end
  
  def test_assignment
    program = <<-EOD
    i = 0
    x = 0

    x = WHILE i < 10 DO
      i = i + 1
    END
    EOD

    tracks = run_source(program)
    assert_equal(10, tracks.last.variables["i"].value)
    assert_equal(nil, tracks.last.variables["x"].value)
  end

  def test_break
    program = <<-EOD
    WHILE true DO
      BREAK
    END

    i = "done"
    EOD

    tracks = run_source(program)
    assert_equal("done", tracks.last.variables["i"].value)

    program = <<-EOD
    x = WHILE true DO
      BREAK "foobar"
    END

    i = "done"
    EOD

    tracks = run_source(program)
    assert_equal("foobar", tracks.last.variables["x"].value)
    assert_equal("done", tracks.last.variables["i"].value)

    program = <<-EOD
    i = 0
    WHILE true DO
      IF i == -5 THEN
        BREAK
      ELSE
        i = i - 1
      END
    END
    EOD

    tracks = run_source(program)
    assert_equal(-5, tracks.last.variables["i"].value)
  end
end
