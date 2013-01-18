#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::SpawnTest < Test::Unit::TestCase
  include RuntimeHelper
  
  def test_perform
    program = <<-EOD
    
    DEFINE read DO
      PRINT "read"
      RETURN 5
    END
    
    x = SPAWN COMPUTE read
    
    PRINT "main"
    PRINT x + 4
    
    EOD

    tracks, output = run_source(program, true)
    assert_equal("main\nread\n9.0" , output)
  end
  
end
