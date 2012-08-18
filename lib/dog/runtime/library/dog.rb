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

    implementation "pending_structure" do
      argument "type"
      argument "buffer_size"
      argument "channel_mode"

      body do
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

        value.buffer_size = size
        value.channel_mode = channel

        dog_return(value)
      end
    end
  end
end
