#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::PauseStopExitTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_exit
    program = <<-EOD
    PRINT "Hello"
    PRINT "World"
    EOD

    tracks, output = run_source(program, true)
    assert_equal("Hello\nWorld", output)

    program = <<-EOD
    PRINT "Hello"
    EXIT
    PRINT "World"
    EOD

    tracks, output = run_source(program, true)
    assert_equal("Hello", output)
  end

  def test_stop
    program = <<-EOD
    PRINT "Hello"
    PRINT "World"
    EOD

    tracks, output = run_source(program, true)
    assert_equal("Hello\nWorld", output)
    assert_equal(1, ::Dog::Track.find().count())
    assert_equal(::Dog::Track::STATE::FINISHED, ::Dog::Track.find().to_a.first["state"])

    program = <<-EOD
    PRINT "Hello"
    STOP
    PRINT "World"
    EOD

    tracks, output = run_source(program, true)
    assert_equal("Hello", output)
    assert_equal(1, ::Dog::Track.find().count())
    assert_equal(::Dog::Track::STATE::WAITING, ::Dog::Track.find().to_a.first["state"])
  end

  def test_pause
    program = <<-EOD
    
    DEFINE print_first DO
      PRINT "1"
    END
    
    DEFINE print_second DO
      PRINT "2"
    END
    
    SPAWN COMPUTE print_first
    SPAWN COMPUTE print_second
    
    EOD
    
    tracks, output = run_source(program, true)
    assert_equal("1\n2", output)
    
    
    program = <<-EOD
    
    DEFINE print_first DO
      PAUSE
      PRINT "1"
    END
    
    DEFINE print_second DO
      PRINT "2"
    END
    
    SPAWN COMPUTE print_first
    SPAWN COMPUTE print_second
    
    EOD
    
    tracks, output = run_source(program, true)
    assert_equal("2\n1", output)
  end

end
