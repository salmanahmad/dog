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

  def test_on_each
    
    program = <<-EOD

    DEFINE write TO channel MESSAGE m DO
      COMPUTE future.send TO channel VALUE m
    END

    messages = COMPUTE future.channel BUFFER 1
    
    ON EACH message DO
      PRINT message
    END
    
    COMPUTE future.send TO messages VALUE 1
    
    
    EOD

    tracks = run_source(program)
    
  end


  
end