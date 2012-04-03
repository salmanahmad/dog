#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class TrackFiber < Fiber
    attr_accessor :track
    
    def track
      if @track.class != Track then
        @track = Track.find_by_id(@track)
        @track.instance_variable_set(:@fiber, self) 
      end
      
      return @track
    end
    
    def track=(t)
      @track = t._id
      t.instance_variable_set(:@fiber, self)
    end
  end
  
end