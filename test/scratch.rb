#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

# Note: This file is not an official part of the Dog source tree.
# It is intended for the developer to try stuff out in between
# commits. Because he is an idiot, he checked it in, and realized
# he kinda liked it so left it in. 
#
# Yes, he is kinda strange...

require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper.rb'))

class ScratchTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_simple
    program = <<-EOD
    
    
    DEFINE ponger READS input WRITES output DO
      i = 0
      FOREVER DO
        i = i + 1
        IF i == 10 THEN
          message = WAIT ON input
          COMPUTE future.send TO output VALUE "stop"
        ELSE
          message = WAIT ON input
          message = "Pong: " + message
          COMPUTE future.send TO output VALUE message
        END
      END
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

    tracks = run_source(program)
    #puts tracks.first.variables

  end

  
end