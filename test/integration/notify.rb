#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::NotifyTest < Test::Unit::TestCase
  include RuntimeHelper

  def test_simple
    program = <<-EOD

    NOTIFY people.public VIA stream OF "Hello!"

    EOD

    tracks = run_source(program)
    messages = ::Dog::RoutedMessage.find().to_a
    message = messages.first

    assert_equal(1, messages.size)
    assert_equal(1, message["properties"].size)
    assert_equal("*value", message["properties"].first["identifier"])
    assert_equal("Hello!", message["properties"].first["value"])
  end
  
  def test_structure
    program = <<-EOD
    message = {
      title = "Some title"
      "body" = "Some body"
    }
    
    NOTIFY people.public VIA stream OF message

    EOD

    tracks = run_source(program)
    messages = ::Dog::RoutedMessage.find().to_a
    message = messages.first

    assert_equal(1, messages.size)
    assert_equal(2, message["properties"].size)

    assert_equal("title", message["properties"][0]["identifier"])
    assert_equal("body", message["properties"][1]["identifier"])

    assert_equal("Some title", message["properties"][0]["value"])
    assert_equal("Some body", message["properties"][1]["value"])
  end
end
