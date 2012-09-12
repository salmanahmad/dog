#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::FindTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_simple
    program = <<-EOD

    DEFINE COMMUNITY hogwarts USING hogwarts_profile {
      age
    }

    i = FIND people.people FROM hogwarts
    PRINT i
    PRINT "---"

    snape = people.person {
      name = "Snape"
    }

    SAVE snape TO hogwarts

    i = FIND people.people FROM hogwarts WHERE name == "Snape"
    PRINT i
    PRINT "---"
    
    
    i = FIND people.people FROM hogwarts
    PRINT i
    PRINT "---"

    EOD

    tracks, output = run_source(program, true)
  end

end

