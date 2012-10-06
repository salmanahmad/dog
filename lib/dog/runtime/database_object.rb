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
    
    def self.collection(name)
      self.collection_name = name
    end
    
    def self.create(hash)
      object = self.from_hash(hash)
      object.save
      return object
    end
    
    # TODO - migrate all of the custom self.from_hash
    # over to just from_hash
    
    def from_hash(hash)
      for key, value in hash do
        self.instance_variable_set("@#{key}".intern, value)
      end
    end
    
    def self.from_hash(hash)
      object = self.new
      object.from_hash(hash)
      return object
    end
    
    def self.update(selector, document, opts = {})
      ::Dog::database[self.collection_name].update(selector, document, opts)
    end
    
    def self.remove(selector = {}, opts = {})
      ::Dog::database[self.collection_name].remove(selector, opts)
    end
    
    def self.find_by_id(id)
      return nil if id.nil?
      if id.class == String
        id = BSON::ObjectId.from_string(id) rescue id
      end
      
      return self.find_one({"_id" => id})
    end
    
    def self.find_one(conditions = {}, opts = {})
      document = ::Dog::database[self.collection_name].find_one(conditions)
      
      if document then
        return self.from_hash(document)
      else
        return nil
      end
    end
    
    def self.find(conditions = {}, opts = {})
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
    
    def reload
      if self._id then
        document = ::Dog::database[self.collection_name].find_one({"_id" => self._id})
        self.from_hash(document)
      end
    end
    
    def remove
      if self._id then
        self.class.remove({"_id" => self._id})
      end
    end
    
    def save
      hash = self.to_hash
      if self._id then
        hash["_id"] = self._id
      else
        raise "Attempting to save a database object without an _id"
      end
      
      ::Dog::database[self.collection_name].save(hash, {:safe => true})
    end
    
  end    
end
