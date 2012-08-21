#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::ListenTest < Test::Unit::TestCase
  include RuntimeHelper
  
  def test_simple
    program = <<-EOD
    
    LISTEN TO people.public FOR events
    
    EOD
    
    tracks = run_source(program)
  end
  
end
