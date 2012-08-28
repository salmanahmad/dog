#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::PeopleTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_simple
    program = <<-EOD

    salman = people.person {
      name = "Salman"
    }
    
    SAVE salman TO people.people

    EOD

    tracks = run_source(program)
    assert_equal(1, ::Dog.database["people"].count)
  end
  
  
  def test_person_from
    program = <<-EOD

    hi = "Hello!"
    user = PERSON FROM hi

    EOD

    tracks = run_source(program)
    assert_equal(nil, tracks.last.variables["user"].ruby_value)
  end
  
end
