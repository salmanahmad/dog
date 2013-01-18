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
    
    track = nil
    for t in tracks do
      if t.is_root? then
        track = ::Dog::Track.find_by_id(t._id)
        break
      end
    end
    
    assert_equal(10, track.variables["x"].ruby_value)

  end


  
end