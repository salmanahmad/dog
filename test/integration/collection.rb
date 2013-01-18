#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper.rb'))

class IntegrationTests::CollectionTest < Test::Unit::TestCase
  include RuntimeHelper
  
  def test_simple
    program = <<-EOD
    DEFINE car {}
    DEFINE cars OF car
    
    type = COMPUTE collection.type ON cars
    EOD
    
    tracks = run_source(program)
    assert_equal("dog.type", tracks.last.variables["type"].type)
    assert_equal("car", tracks.last.variables["type"]["name"].ruby_value)
    assert_equal("", tracks.last.variables["type"]["package"].ruby_value)
  end
end
