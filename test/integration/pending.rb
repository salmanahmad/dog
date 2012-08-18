#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::PendingTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_simple
    program = <<-EOD

    foo = COMPUTE dog.pending_structure ON "structure", -1, false
    PRINT foo

    EOD

    tracks, output = run_source(program, true)
  end
end
