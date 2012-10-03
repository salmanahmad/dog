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
  
  def test_concatenation
    program = <<-EOD
    
    DEFINE write TO i DO
      COMPUTE future.complete FUTURE i WITH {name = "Hi"}
    END
    
    DEFINE read DO
      i = COMPUTE future.future
      SPAWN COMPUTE write TO i
      RETURN i
    END
    
    i = COMPUTE read

    PRINT i.name
    
    EOD

    tracks = run_source(program)
  end
end
