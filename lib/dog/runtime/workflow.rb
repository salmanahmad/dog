#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class Workflow < DatabaseObject
    collection "workflows"
    
    attr_accessor :_id
    attr_accessor :track_id
    attr_accessor :type
    attr_accessor :routing
    attr_accessor :created_at
    
    def to_hash
      return {
        type: self.type,
        track_id: self.track_id,
        routing: (self.routing || {}),
        created_at: (self.created_at || DateTime.now)
      }
    end
    
  end
end