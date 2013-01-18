#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper.rb'))

class RuntimeTests::FutureTest < Test::Unit::TestCase  
  include RuntimeHelper
  
  def test_simple
    run_source("")
    
    assert_equal(1, ::Dog.database["tracks"].count)
    
    t = ::Dog::Track.new
    t.save
    
    fs = [
      ::Dog::Future.new(::Dog::Value.empty_structure._id).save,
      ::Dog::Future.new(::Dog::Value.empty_structure._id).save,
      ::Dog::Future.new(::Dog::Value.empty_structure._id).save,
      ::Dog::Future.new(::Dog::Value.empty_structure._id).save
    ]
    
    fs = ::Dog::Future.find()
    
    for f in fs do
      f = ::Dog::Future.from_hash(f)
      f.broadcast_tracks << t
      f.save
    end
    
    assert_equal(2, ::Dog.database["tracks"].count)
    assert_equal(4, ::Dog::Future.find({"broadcast_tracks" => t._id}).count)
    
    ::Dog::Future.remove_broadcast_track_from_all(t._id)
    assert_equal(0, ::Dog::Future.find({"broadcast_tracks" => t._id}).count)
  end
end

