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
      PERFORM "Label these pictures"
      RETURN images
    END

    ASK people.public TO label ON "Hello!"

    EOD

    tracks = run_source(program)
    tasks = ::Dog::RoutedTask.find().to_a
    task = tasks.first
    
    assert_equal(1, tasks.size)
    assert_equal(3, task["properties"].size)
    assert_equal(["instructions", "message", "images"], task["properties"].map { |p| p["identifier"] })

  end

  def test_simple
    program = <<-EOD

    DEFINE label FOR people ON message DO
      PERFORM "Label these pictures"
      RETURN images
    END

    ASK people.public TO label ON "Hello!" USING rating = 7

    EOD

    tracks = run_source(program)
    tasks = ::Dog::RoutedTask.find().to_a
    task = tasks.first
    
    assert_equal(1, tasks.size)
    assert_equal(4, task["properties"].size)
    assert_equal(["instructions", "message", "rating", "images"], task["properties"].map { |p| p["identifier"] })


  end
  
end
