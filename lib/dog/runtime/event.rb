#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class MailedEvent < DatabaseObject
    collection "mailed_events"
    
    attr_accessor :_id
    attr_accessor :channel_id
    attr_accessor :properties
    attr_accessor :routing
    attr_accessor :created_at
    
    def to_hash
      return {
        "channel_id" => self.channel_id,
        "properties" => self.properties,
        "routing" => self.routing,
        "created_at" => self.created_at
      }
    end
    
  end
  
  class RoutedEvent < StreamObject
    
  end
end