#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog  
  class RoutedMessage < DatabaseObject
    include Routability
    collection "messages"
    
    attr_accessor :_id
    attr_accessor :type
    attr_accessor :value
    attr_accessor :routing
    attr_accessor :created_at
    
    def to_hash
      return {
        type: self.type,
        value: self.value,
        routing: (self.routing || {}),
        created_at: (self.created_at || Time.now)
      }
    end
    
    def to_hash_for_event
      to_hash
    end
    
  end
  
  class Message < Structure
    
  end
end