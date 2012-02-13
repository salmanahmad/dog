#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Track
    
    attr_accessor :parent_state
    attr_accessor :pending_states
    
    def finished?
      pending_states.empty?
    end
    
  end
  
end