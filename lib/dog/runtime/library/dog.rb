#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Library
  module Dog
    include ::Dog::NativePackage

    name "dog"

    implementation "add" do
      argument "container"
      argument "value"
      
      body do |track|
        container = variable("container")
        value = variable("value")
        
        if container.type == "collection" then
          # TODO
        else
          if container.pending then
            future = ::Dog::Future.find_one("value_id" => container._id)
            
            for handler in future.handlers do
              handler = ::Dog::Value.from_hash(handler)
              
              package_name = handler["package"].value
              function_name = handler["name"].value
              
              package = ::Dog::Runtime.bundle.packages[package_name]
              symbol = package.symbols[function_name]
              
              if future.value.max_numeric_key then
                index = future.value.max_numeric_key.ceil + 1
              else
                index = 0
              end
              
              future.value[index] = value
              future.save
              
              if symbol["implementations"].size != 0 then
                argument_name = symbol["implementations"].first["arguments"].first
                
                track = ::Dog::Track.new(function_name, package_name)
                track.variables[argument_name] = value
                
                # TODO - I need to handle the output fromt this and do things
                # like save the track or read the return value. If there are
                # multiple tracks with multiple return values then I should return
                # an array with a list of the values. Note: these values may include
                # a future - or should it include a "receipt". 
                ::Dog::Runtime.run_track(track)
              end
            end
            
          else
            if container.max_numeric_key then
              index = container.max_numeric_key.ceil + 1
            else
              index = 0
            end
            
            container[index] = value
          end
          
          dog_return(container)
        end
      end
    end
    
    implementation "register_handler" do
      argument "structure"
      argument "type"
      
      body do |track|
        structure = variable("structure")
        type = variable("type")
        
        future = ::Dog::Future.find_one("value_id" => structure._id)
        
        if future.nil? then
          future = ::Dog::Future.new(structure._id, structure)
        end
        
        future.handlers << type
        future.save
      end
    end
    
    implementation "pending_structure" do
      argument "type"
      argument "buffer_size"
      argument "channel_mode"

      body do |track|
        value = nil

        type = variable("type")
        size = variable("buffer_size").ruby_value
        channel = variable("channel_mode").ruby_value

        if type.value == "structure" then
          value = ::Dog::Value.new("structure", {})
        elsif type.type == "type" then
          track = ::Dog::Track.new(type["name"], type["package"])
          ::Dog::Runtime.run_track(track)
          value = track.stack.pop
        else
          raise "Invalid type for pending structure"
        end

        value.pending = true
        value.buffer_size = size
        value.channel_mode = channel

        dog_return(value)
      end
    end
  end
end
