#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::ShellTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_simple
    program = <<-EOD

    DEFINE label FOR shell ON message DO
      PERFORM 'read input; echo input=$input;'
      RETURN images
    END

    PRINT COMPUTE label ON "foo"

    EOD

    tracks, output = run_source(program, true)
    assert_equal('input={"argv":["foo"],"kwargs":{},"name":"label"}', output)

  end

  
end
