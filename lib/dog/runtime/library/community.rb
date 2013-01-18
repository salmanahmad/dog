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

    implementation "build_profile:on" do
      argument "community"

      body do
        checkpoint do
          community = variable("community").ruby_value
          dog_call(community["profile"], community["package"])
        end
        
        checkpoint do
          type = track.stack.pop
          dog_return(type)
        end
      end
    end
  end
end
