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
    assert_equal(5, tracks.last.variables["foo"].value["n:0.0"].value)
    assert_equal("Hello", tracks.last.variables["foo"].value["n:1.0"].value)
  end
  
  def test_add
    program = <<-EOD

    foo = COMPUTE dog.pending_structure ON "structure", -1, false

    ON EACH i IN foo DO
      PRINT i
    END

    COMPUTE dog.add ON foo, "3"
    COMPUTE dog.add ON foo, "2"
    COMPUTE dog.add ON foo, "1"
    EOD

    tracks, output = run_source(program, true)

    foo = tracks.last.variables["foo"]
    future = ::Dog::Future.find_one("value_id" => foo._id)

    assert(future != nil)
    assert_equal(1, future.handlers.size)

    handler = ::Dog::Value.from_hash(future.handlers.first)

    assert_equal("@each:i", future.handlers.first["value"]["s:name"]["value"])
    assert_equal("@each:i", handler["name"].value)
    assert_equal("3\n2\n1", output)
  end
  
  def test_on_each_returns
    program = <<-EOD

    foo = COMPUTE dog.pending_structure ON "structure", -1, false

    ON EACH i IN foo DO
      RETURN i + 5
    END

    output = COMPUTE dog.add ON foo, 5
    EOD

    tracks, output = run_source(program, true)
    assert_equal(10, tracks.last.variables["output"].ruby_value)
  end
  
  
  def test_multiple_on_each_returns
    program = <<-EOD

    foo = COMPUTE dog.pending_structure ON "structure", -1, false

    ON EACH i IN foo DO
      RETURN i + 5
    END
    
    ON EACH x IN foo DO
      RETURN x - 5
    END

    output = COMPUTE dog.add ON foo, 5
    EOD

    tracks, output = run_source(program, true)
    o = tracks.last.variables["output"]
    assert_equal(2, o.value.size)
    assert_equal(10, o[0].ruby_value)
    assert_equal(0, o[1].ruby_value)
  end
end
