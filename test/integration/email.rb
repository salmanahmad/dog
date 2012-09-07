#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::EmailTest < Test::Unit::TestCase
  include RuntimeHelper
  
  def test_simple
    program = <<-EOD

    salman = people.person {
      email = "salman@salmanahmad.com"
    }

    i = "Hello, World!"
    
    NOTIFY salman VIA email OF i

    EOD

    tracks = run_source(program)
  end

end
