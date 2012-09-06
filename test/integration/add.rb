#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::AddTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_simple
    program = <<-EOD

    car = {
      messages = {}
    }

    ADD "hi" TO car.messages
    ADD "hello" TO car.messages

    EOD

    tracks = run_source(program)
    track = tracks.last
    assert_equal(track.variables["car"]["messages"][0].ruby_value, "hi")
    assert_equal(track.variables["car"]["messages"][1].ruby_value, "hello")

  end

  
end
