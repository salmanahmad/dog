#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Library
  module Community
    include ::Dog::NativePackage

    name "community"

    implementation "build_profile" do
      argument "community"

      body do
        community = variable("community").ruby_value
        
        # TODO - Have a better way to call Dog functions which handles checkpoints, etc.
        # Currenlty this is really really unsafe. I have no idea how this will work and it
        # very well may crash and burn
        track = ::Dog::Track.new(community["name"], community["package"])
        ::Dog::Runtime.run_track(track)
        type = track.stack.pop
        
        dog_return(type)
      end
    end
  end
end
