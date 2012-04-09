#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  module Routability
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      def routability_person_checkpoint_attribute(attribute)
        @routability_person_checkpoint_attribute = attribute
      end

      def routability_cache_collection(collection)
        @routability_cache_collection = collection
      end
      
      def for_person(person, options = {})
        results = []
        first_record_id = nil

        records = self.find({}, {:sort => ["created_at", Mongo::DESCENDING]})

        for record in records do
          record = self.from_hash(record)
          # TODO break if record._id == person.last_task_id
          first_record_id ||= record._id

          if person.accepts_routing?(record.routing) then
            results << record.to_hash_for_event
            # TODO update user cache
          end
        end

        # TODO person.last_task_id = first_record_id if first_record_id - Except don't call save.
        # Instead call update or equivalent method to just update that one field.
        
        # TODO Don't return results. Requery on the user's routing collection
        return results
      end
    end
    
    def route_to_person?(person)
      return person.accepts_routing?(self.routing)
    end
    
  end
end
