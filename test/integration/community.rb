#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::CommunityTest < Test::Unit::TestCase
  include RuntimeHelper
  
  def test_simple
    program = <<-EOD
    DEFINE COMMUNITY mit USING mit_profile {
      gpa
      age = 18
      
    }
    
    profile = COMPUTE community.build_profile ON mit
    EOD
    
    tracks = run_source(program)
    assert_equal({"gpa" => nil, "age" => 18.0}, tracks.last.variables["profile"].ruby_value)
    
  end
end
