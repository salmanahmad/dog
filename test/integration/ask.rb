#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::AskTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_simple
    program = <<-EOD

    DEFINE label FOR people ON message DO
      PRINT message
    END

    ASK people.public TO label ON "Hello!"

    EOD

    tracks, output = run_source(program, true)
    assert_equal("Hello!", output)
  end

  def test_simple_2
    program = <<-EOD

    DEFINE label FOR people ON message RATING rating DO
      PRINT message
      PRINT rating
    END

    ASK people.public TO label ON "Hello!" RATING 7

    EOD

    tracks, output = run_source(program, true)
    assert_equal("Hello!\n7.0", output)
  end

  # TODO - Add a test for PERFORM "Label these pictures" RETURN images

end
