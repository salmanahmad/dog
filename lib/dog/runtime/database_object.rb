#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class DatabaseObject
    class << self
      attr_accessor :collection_name
    end
    
    def self.from_hash
      object = self.new
      for key, value in hash do
        object.instance_variable_set("@#{key}".intern, value)
      end
      
      return object
    end
    
    def self.collection(name)
      self.collection_name = name
    end
    
    def collection_name
      self.class.collection_name
    end
    
    def save
      if self._id then
        # TODO - Consider using Collection#find_and_modify for atomic semantics.
        # http://api.mongodb.org/ruby/current/Mongo/Collection.html#find_and_modify-instance_method
        ::Dog::database[self.collection_name].update({"_id" => self._id}, self.to_hash)
      else
        id = ::Dog::database[self.collection_name].insert(self.to_hash)
        self._id = id
      end
    end
    
  end    
end
