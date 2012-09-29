#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Library
  module Collection
    include ::Dog::NativePackage

    name "collection"

    implementation "type:on" do
      argument "collection"
      
      body do
        collection = variable("collection").ruby_value
        
        # TODO - Have a better way to call Dog functions which handles checkpoints, etc.
        # Currenlty this is really really unsafe. I have no idea how this will work and it
        # very well may crash and burn
        track = ::Dog::Track.new(collection["name"], collection["package"])
        ::Dog::Runtime.run_track(track)
        type = track.stack.pop
        
        dog_return(type)
      end
    end
    
    
    implementation "size:on" do
      argument "collection"
      
      body do |track|
        collection = variable("collection")
        
        if collection.type == "collection" then
          # TODO
        else
          size = ::Dog::Value.number_value(collection.value.keys.size)
        end
        
        dog_return(size)
      end
    end
  end
end
