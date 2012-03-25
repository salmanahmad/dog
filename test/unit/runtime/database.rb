#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class RuntimeTests::DatabaseTest < RuntimeTestCase
  
  def test_simple
    Dog::Database.initialize
    
    puts Dog::database[:track_parents].select("variables.*").filter("track_parents.track_id" => 5).join(:tracks, :id => :parent_id).join(:variables, :track_id => :id).limit(1).sql
    
  end
  
  
end