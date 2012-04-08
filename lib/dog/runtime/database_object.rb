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
    
    def self.create(hash)
      object = self.from_hash(hash)
      object.save
      return object
    end
    
    def self.from_hash(hash)
      object = self.new
      for key, value in hash do
        object.instance_variable_set("@#{key}".intern, value)
      end
      
      return object
    end
    
    def self.collection(name)
      self.collection_name = name
    end
    
    def self.find_by_id(id)
      return nil if id.nil?
      id = BSON::ObjectId.from_string(id) if id.class == String
      return self.find_one({"_id" => id})
    end
    
    def self.find_one(conditions = {})
      document = ::Dog::database[self.collection_name].find_one(conditions)
      
      if document then
        return self.from_hash(document)
      else
        return nil
      end
    end
    
    def self.find(conditions = {})
      return ::Dog::database[self.collection_name].find(conditions)
    end
    
    def collection_name
      self.class.collection_name
    end
    
    def id
      self._id
    end
    
    def id=(some_id)
      self._id = some_id
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
