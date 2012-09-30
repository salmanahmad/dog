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
  
  def test_break_in_function
    program = <<-EOD
    DEFINE foo DO
      i = WHILE true DO
        BREAK "Hi"
      END
      
      PRINT i
    END
    
    COMPUTE foo
    EOD

    tracks, output = run_source(program, true)
    assert_equal("Hi", output)
  end
  
  def test_forever 
    program = <<-EOD

    i = 0
    x = FOREVER DO
      i = i + 1
      IF i == 10 THEN
        BREAK i
      END
    END
    EOD

    tracks = run_source(program)
    track = tracks.last
    assert_equal(10, track.variables["x"].ruby_value)
    assert_equal(10, track.variables["i"].ruby_value)
    
  end
  
  def test_repeat
    program = <<-EOD

    x = 5
    i = 0

    REPEAT 5 TIMES
      i = i + 1
    END
    
    REPEAT x DO
      i = i + 1
    END
    
    i = REPEAT 1000 TIMES
      i = i + 1
      BREAK i
    END
    
    EOD

    tracks = run_source(program)
    track = tracks.last
    assert_equal(11, track.variables["i"].ruby_value)

  end
  
  def test_for
    program = <<-EOD

    cars = {}
    ADD "a" TO cars
    ADD "a" TO cars
    ADD "a" TO cars
    ADD "a" TO cars

    new_cars = {}

    FOR EACH car IN cars DO
      ADD car TO new_cars
    END

    EOD

    tracks = run_source(program)
    track = tracks.last
    
    assert_equal(4, track.variables["new_cars"].keys.size)
    assert_equal("a", track.variables["new_cars"][0].ruby_value)
    assert_equal("a", track.variables["new_cars"][1].ruby_value)
    assert_equal("a", track.variables["new_cars"][2].ruby_value)
    assert_equal("a", track.variables["new_cars"][3].ruby_value)
    
    
  end
  
end
