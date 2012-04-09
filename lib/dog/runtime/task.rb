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
    
    def completed?
      self.responses ||= []
      return self.responses.length >= self.replication
    end
    
    def process_response(response, person)
      response ||= {}
      self.responses ||= []
      
      if self.responses.count >= self.replication then
        raise "The task has already been answered."
      end
      
      # TODO - This is a mass assignment flaw.
      # In the future only merge the output properties 
      task = self.type.new
      task.assign(self.value)
      task.assign(response)
      
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
    
    def self.from_hash(hash)
      object = super
      object.type = Kernel.const_get(object.type)
      return object
    end
    
    def self.for_person(person, options = {})
      # TODO - Refactor this with routability
      results = []
      
      records = self.find({}, {:sort => ["created_at", Mongo::DESCENDING]})
      
      for record in records do
        record = self.from_hash(record)
        
        if options[:after_task_id] && (BSON::ObjectId.from_string(options[:after_task_id]) == record._id) then
          break
        end
        
        if options[:completed] == true && !record.completed? then
          next
        end
        
        if options[:completed] == false && record.completed? then
          next
        end
        
        if person.accepts_routing?(record.routing) then
          results << record.to_hash_for_event
        end
      end

      return results
    end
    
    def to_hash
      return {
        type: self.type.name,
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
      hash["_id"] = self._id.to_s
      hash.delete(:replication)
      hash.delete(:duplication)
      hash.delete(:responses)
      return hash
    end
    
  end
  
  class Task < Structure
    
  end
end

