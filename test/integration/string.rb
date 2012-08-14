#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::StringTest < Test::Unit::TestCase
  include RuntimeHelper
  
  def test_concatenation
    program = <<-EOD
    "foo" + "bar"
    EOD
    
    tracks = run_source(program)
    assert_equal("foobar", tracks.last.stack.last.value)
  end
  
end
