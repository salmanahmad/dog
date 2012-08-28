#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::RoutingTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_simple
    program = <<-EOD
    
    DEFINE do_laundry FOR people DO
      PERFORM "do laundry"
      RETURN confirmation
    END
    
    salman = people.person {
      first_name = "salman"
    }
    
    ASK salman TO do_laundry
    
    EOD
    
    run_source(program)
    assert_equal(1, ::Dog::RoutedTask.find().count)
    
  end
end
