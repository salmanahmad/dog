#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class StreamObject < DatabaseObject
    include Routability
    collection "stream"
    
    attr_accessor :_id
    attr_accessor :type
    attr_accessor :name
    attr_accessor :properties
    attr_accessor :routing
    attr_accessor :handler
    attr_accessor :handler_argument
    attr_accessor :created_at
    
    def self.inherited(child)
      child.collection "stream"
    end
    
    def initialize
      self.type = self.class
    end
    
    def self.from_hash(hash)
      object = super
      object.type = Kernel.qualified_const_get(object.type)
      object.routing = People.from_database(object.routing || "{}")
      object.properties = object.properties.map { |property|
        Property.from_hash(property)
      }
      return object
    end
    
    def to_hash
      return {
        type: self.type.name,
        name: self.name,
        properties: ((self.properties || []).map { |property|
          property.to_hash
        }),
        routing: People.to_database(self.routing || {}),
        handler: self.handler,
        handler_argument: self.handler_argument,
        created_at: (self.created_at || Time.now)
      }
    end
    
    def to_hash_for_event
      to_hash
    end
    
  end
end

