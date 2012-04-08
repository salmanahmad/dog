#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class RoutedTask < DatabaseObject
    include Routability
    collection "tasks"
    
    attr_accessor :_id
    attr_accessor :type
    attr_accessor :value
    attr_accessor :routing
    attr_accessor :replication
    attr_accessor :duplication
    attr_accessor :responses
    attr_accessor :created_at
    
    def process_response(response, person)
      response ||= {}
      self.responses ||= []
      
      if self.responses.count >= self.replication then
        raise "The task has already been answered."
      end
      
      task = Kernel.const_get(self.type).new
      task.assign(response)
      task.assign(self.value)
      
      if task.required_output_present? then
        if response.include? "_person_id"
          # TODO - Enforce this somewhere
          raise "Error. The _person key was set on response"
        end
        
        response["_person_id"] = person._id
        self.responses << response
        return true
      else
        # TODO raise exception with the errors for reporting
        raise "Required task output was not present."
      end
    end
    
    def to_hash
      return {
        type: self.type,
        value: self.value,
        routing: (self.routing || {}),
        replication: (self.replication || 1),
        duplication: (self.duplication || 1),
        responses: (self.responses || []),
        created_at: (self.created_at || Time.now)
      }
    end
    
    def to_hash_for_event
      hash = to_hash
      hash.delete(:replication)
      hash.delete(:duplication)
      hash.delete(:responses)
      return hash
    end
    
  end
  
  class Task < Structure
    
  end
end

