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
        checkpoint do
          collection = variable("collection").ruby_value
          dog_call(collection["name"], collection["package"])
        end
        
        checkpoint do
          type = track.stack.pop
          dog_return(type)
        end
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
