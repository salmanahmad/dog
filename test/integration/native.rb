#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::NativeTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_simple
    program = <<-EOD

    DEFINE foo DO

    END

    sum = COMPUTE system.print ON 5 + 5

    EOD

    tracks, output = run_source(program, true)
    assert_equal(10.to_f.to_s, output)
  end
  
  
  def test_simple_2
    program = <<-EOD

    DEFINE car {}

    civic = car {
      age = 5
    }

    type = COMPUTE system.type_of ON civic

    EOD

    tracks = run_source(program)
    assert_equal(".car", tracks.last.variables["type"].ruby_value)
  end
end
