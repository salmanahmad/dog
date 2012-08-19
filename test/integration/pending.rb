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
    PRINT foo.hi

    EOD

    tracks, output = run_source(program, true)
    assert_equal("{}", output)
    assert_equal(::Dog::Track::STATE::WAITING, tracks.last.state)
  end
  
  def test_no_block
    program = <<-EOD

    foo = COMPUTE dog.pending_structure ON "structure", -1, false

    EOD

    tracks, output = run_source(program, true)
    assert_equal(::Dog::Track::STATE::FINISHED, tracks.last.state)
  end
  
  def test_add_without_block
    program = <<-EOD

    foo = {}
    foo = COMPUTE dog.add ON foo, 5
    foo = COMPUTE dog.add ON foo, "Hello"
    
    EOD
    
    tracks = run_source(program)
    assert_equal(5, tracks.last.variables["foo"].value["n:0"].value)
    assert_equal("Hello", tracks.last.variables["foo"].value["n:1"].value)
  end
  
  def test_add
    program = <<-EOD

    foo = COMPUTE dog.pending_structure ON "structure", -1, false
    
    #ON EACH i IN foo DO
    #
    #END
    
    COMPUTE dog.add ON foo, "Hello!"
    EOD

    tracks, output = run_source(program, true)
  end
end
