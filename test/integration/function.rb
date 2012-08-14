#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::FunctionTest < Test::Unit::TestCase
  include RuntimeHelper
  
  def test_concatenation
    program = <<-EOD
    DEFINE foo DO
      PRINT "foo called"
      "foobar"
    END
    
    i = COMPUTE foo
    EOD

    tracks, output = run_source(program, true)
    assert_equal("foobar", tracks.last.stack.last.value)
    assert_equal("foobar", tracks.last.variables["i"].value)
    assert_equal("foo called", output)
  end

  def test_recusion
    program = <<-EOD
    DEFINE fib ON a DO
      IF a == 1 OR a == 0 THEN
        RETURN a
      ELSE
        RETURN (COMPUTE fib ON a - 1) + (COMPUTE fib ON a - 2)
      END
    END
    
    i = COMPUTE fib ON 10
    PRINT i
    i
    EOD

    tracks, output = run_source(program, true)
    assert_equal(55, tracks.last.stack.last.value)
    assert_equal(55, tracks.last.variables["i"].value)
    assert_equal(55.to_f.to_s, output)
  end
end
