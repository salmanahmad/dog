#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::FutureTest < Test::Unit::TestCase
  include RuntimeHelper
  
  def test_perform
    program = <<-EOD
    
    DEFINE write TO i DO
      COMPUTE future.complete FUTURE i WITH 5
    END
    
    DEFINE read DO
      i = COMPUTE future.future
      SPAWN COMPUTE write TO i
      RETURN i
    END
    
    i = COMPUTE read

    x = i + 5
    
    EOD

    tracks = run_source(program)
    assert_equal(10, tracks.last.variables["x"].ruby_value)
  end
  
  
  def test_access
    program = <<-EOD
    
    DEFINE write TO i DO
      COMPUTE future.complete FUTURE i WITH {name = {foo = "hi"}}
    END
    
    DEFINE read DO
      i = COMPUTE future.future
      SPAWN COMPUTE write TO i
      RETURN i
    END
    
    i = COMPUTE read

    x = i.name.foo
    
    EOD

    tracks = run_source(program)
    assert_equal("hi", tracks.last.variables["x"].ruby_value)
  end
  
  def test_channels
    program = <<-EOD

    DEFINE ponger READS input WRITES output DO
      REPEAT 3 TIMES 
        message = WAIT ON input
        message = "Pong: " + message
        COMPUTE future.send TO output VALUE message
      END

      message = WAIT ON input
      COMPUTE future.send TO output VALUE "stop"

      RETURN
    END

    input = COMPUTE future.channel BUFFER 1
    output = COMPUTE future.channel BUFFER 1

    SPAWN COMPUTE ponger READS output WRITES input

    FOREVER DO
      COMPUTE future.send TO output VALUE "Hi"
      message = WAIT ON input

      PRINT "I Got '" + message + "'"

      IF message == "stop" THEN
        BREAK
      END
    END

    EOD
    
    the_output = "I Got 'Pong: Hi'\nI Got 'Pong: Hi'\nI Got 'Pong: Hi'\nI Got 'stop'"
    tracks, output = run_source(program, true)
    assert_equal(the_output, output)
  end
  
  
  def test_wait_multiple
    program = <<-EOD

    DEFINE write TO channel MESSAGE m DO
      COMPUTE future.send TO channel VALUE m
    END

    ch1 = COMPUTE future.channel BUFFER 1
    ch2 = COMPUTE future.channel BUFFER 1
    ch3 = COMPUTE future.channel BUFFER 1

    SPAWN COMPUTE write TO ch1 MESSAGE "1"
    SPAWN COMPUTE write TO ch2 MESSAGE "2"
    SPAWN COMPUTE write TO ch3 MESSAGE "3"

    REPEAT 3 TIMES 
      i = WAIT ON ch1, ch2, ch3

      PRINT i
    END

    EOD

    tracks, output = run_source(program, true)
    assert_equal([1,2,3].join("\n"), output)
  end
  
  
  
  def test_value_from_future
    program = <<-EOD

    DEFINE write TO channel MESSAGE m DO
      COMPUTE future.send TO channel VALUE m
    END

    ch1 = COMPUTE future.channel BUFFER 1
    ch2 = COMPUTE future.channel BUFFER 1

    SPAWN COMPUTE write TO ch1 MESSAGE "1"
    SPAWN COMPUTE write TO ch2 MESSAGE "2"

    i = WAIT ON ch1, ch2
    
    IF (COMPUTE future.is VALUE i FROM_FUTURE ch1) THEN
      PRINT "Okay!"
    END
    
    EOD

    tracks, output = run_source(program, true)
    assert_equal("Okay!", output)
  end
  
  
  def test_on
    
    
    program = <<-EOD

    DEFINE write TO channel MESSAGE m DO
      COMPUTE future.send TO channel VALUE m
    END

    ch1 = COMPUTE future.channel BUFFER 1
    ch2 = COMPUTE future.channel BUFFER 1

    SPAWN COMPUTE write TO ch1 MESSAGE "1"
    SPAWN COMPUTE write TO ch2 MESSAGE "2"
    
    REPEAT 2 DO
      ON message IN ch1 DO
        PRINT "From ch1"
      ELSE ON message IN ch2 DO
        PRINT "From ch2"
      END
    END
    
    EOD

    tracks, output = run_source(program, true)
    assert_equal("From ch1\nFrom ch2", output)

  end
  
  
  def test_on_each
    
    program = <<-EOD

    DEFINE write TO channel MESSAGE m DO
      COMPUTE future.send TO channel VALUE m
    END

    messages = COMPUTE future.channel BUFFER 1
    
    ON EACH message DO
      PRINT message
    END
    
    COMPUTE future.send TO messages VALUE "1"
    COMPUTE future.send TO messages VALUE "2"
    
    
    EOD

    tracks, output = run_source(program, true)
    assert_equal("1\n2", output)

  end
  
  def test_multiple_on_each
    program = <<-EOD

    messages = COMPUTE future.channel BUFFER 0
    
    ON EACH message DO
      PRINT message
    END
    
    ON EACH message DO
      PRINT message
    END
    
    ON EACH x IN messages DO
      PRINT x
    END
    
    COMPUTE future.send TO messages VALUE "1"
    
    
    EOD

    tracks, output = run_source(program, true)
    assert_equal("1\n1\n1", output)
    
  end
  
  
  def test_on_single_in
    program = <<-EOD

    DEFINE write TO channel MESSAGE m DO
      COMPUTE future.send TO channel VALUE m
    END

    messages = COMPUTE future.channel BUFFER 1

    SPAWN COMPUTE write TO messages MESSAGE "Hello"
    
    ON message DO
      PRINT message
    END
    
    EOD

    tracks, output = run_source(program, true)
    assert_equal("Hello", output)

  end
  
  
  def test_buffer_size
    program = <<-EOD

    DEFINE wait ON channel DO
      message = WAIT ON channel
      PRINT message
    END

    messages = COMPUTE future.channel BUFFER 0
    COMPUTE future.send TO messages VALUE "Test"

    SPAWN COMPUTE wait ON messages
    
    
    EOD

    tracks, output = run_source(program, true)
    assert_equal("", output)

    program = <<-EOD

    DEFINE wait ON channel DO
      message = WAIT ON channel
      PRINT message
    END

    messages = COMPUTE future.channel BUFFER 1
    COMPUTE future.send TO messages VALUE "Test"

    SPAWN COMPUTE wait ON messages
    
    
    EOD

    tracks, output = run_source(program, true)
    assert_equal("Test", output)
    
    
    
    
    program = <<-EOD

    messages = COMPUTE future.channel BUFFER 0

    ON EACH message DO
      PRINT message
    END

    COMPUTE future.send TO messages VALUE "Test"

    EOD

    tracks, output = run_source(program, true)
    assert_equal("Test", output)

  end
  
  
  
  
  
end
