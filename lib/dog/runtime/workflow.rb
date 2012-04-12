#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class RoutedWorkflow < DatabaseObject
    include Routability
    collection "workflows"
    
    attr_accessor :_id
    attr_accessor :track_id
    attr_accessor :type
    attr_accessor :name
    attr_accessor :value
    attr_accessor :routing
    attr_accessor :created_at
    
    def self.from_hash(hash)
      object = super
      object.type = Kernel.qualified_const_get(object.type)
      object.routing = People.from_database(object.routing || "{}")
      return object
    end
    
    def to_hash
      return {
        type: self.type.name,
        name: self.name,
        value: self.value,
        track_id: self.track_id,
        routing: People.to_database(self.routing || {}),
        created_at: (self.created_at || Time.now)
      }
    end
    
    def to_hash_for_event
      to_hash
    end
    
  end
  
  class Workflow < Structure
    
    class << self
      attr_accessor :people_variable_name
    end
    
    def self.people(name)
      self.people_variable_name = name
    end
    
  end
  
end