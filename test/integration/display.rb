#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::DisplayTest < Test::Unit::TestCase
  include RuntimeHelper
  
  def test_simple
    program = <<-EOD

    message = "Welcome!"
    
    DISPLAY message TO people.people
      
    EOD

    tracks = run_source(program)
    assert_equal(1, tracks.last.displays.keys.count)
    assert_equal(2, tracks.last.displays["message"].keys.count)
    assert_equal("Welcome!", tracks.last.displays["message"]["value"].ruby_value)

  end

end
