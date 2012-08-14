#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

# TODO - This file is no longer necessary. It is being kept because
# it has an interesting scaffolding on how to test a RACK-based app.
# The actual test cases need to be updated in the future.

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

=begin
Thread.abort_on_exception = true
Thread.new do
  Dog.bark! do
    module Dog::Application
    
      include Dog
    
      module Handlers
        def self.meetings(meeting)
          Dog.reply :message => "This is a message"
        end
      end
    
      class Meeting < Event
        property "data", :type => Hash, :direction => "input", :required => true
        property "message", :direction => "output"
      end
    
      Server.listen(:via => "http", :at => "meetings", :eligibility => People, :event => Meeting, :handler => :meetings)
    end
  end
end

sleep(1)
=end

class RuntimeTests::ServerTest < Test::Unit::TestCase  
  include RuntimeHelper
  
  def test_invalid_input
    return
    
    response = HTTParty.post 'http://localhost:4567/meetings'
    assert client_error?(response)
    
    response = HTTParty.post 'http://localhost:4567/meetings', :body => { :data => {:key => "value"} }
    assert ok?(response)
    assert_equal response.parsed_response, {"success" => true, "errors" => nil, "data" => {"key" => "value"}, "message" => "This is a message"}
    assert_equal response["message"], "This is a message"
  end

  
end

