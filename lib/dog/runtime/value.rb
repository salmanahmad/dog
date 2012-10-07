#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Value
    # TODO - The type in a value should be scoped to the package as well. Otherwise, we could have two 'people' structs
    attr_accessor :_id
    attr_accessor :pending
    attr_accessor :from_future
    attr_accessor :buffer_size
    attr_accessor :channel_mode
    attr_accessor :person
    attr_accessor :type
    attr_accessor :value
    
    attr_accessor :min_numeric_key
    attr_accessor :max_numeric_key
    
    def initialize(type = nil, value = nil)
      self._id = UUID.new.generate
      self.type = type
      self.value = value
      self.pending = false
      self.from_future = nil
    end
    
    def self.primitive_types
      ["dog.string", "dog.number", "dog.boolean", "dog.null"]
    end
    
    def clone
      hash = self.to_hash
      ::Dog::Value.from_hash(hash)
    end
    
    def to_hash
      if !self.person.nil? then
        person = self.person.to_hash
      else
        person = nil
      end
      
      if Value.primitive_types.include? self.type then
        return {
          "_id" => self._id,
          "pending" => self.pending,
          "from_future" => self.from_future,
          "buffer_size" => self.buffer_size,
          "channel_mode" => self.channel_mode,
          "person" => person,
          "type" => self.type,
          "value" => self.value,
          "min_numeric_key" => self.min_numeric_key,
          "max_numeric_key" => self.max_numeric_key
        }
      else
        
        if self.type == "array" then
          processed_value = []
          for k, v in self.value do
            processed_value << v.to_hash
          end
        else
          processed_value = {}
          for k, v in self.value do
            processed_value[k] = v.to_hash
          end
        end
        
        return {
          "_id" => self._id,
          "pending" => self.pending,
          "from_future" => self.from_future,
          "buffer_size" => self.buffer_size,
          "channel_mode" => self.channel_mode,
          "person" => person,
          "type" => self.type,
          "value" => processed_value,
          "min_numeric_key" => self.min_numeric_key,
          "max_numeric_key" => self.max_numeric_key
        }
      end
    end
    
    def keys
      items = []
      for key, v in self.value do
        item = key[2, key.length]

        if key[0,1] == "n" then
          item = item.to_f
        end

        items << item
      end

      return items
    end
    
    def [](k)
      if k.kind_of? Numeric then
        # TODO - THIS IS REALLY REALLY REALLY BAD - I NEED TO FIGURE OUT A BETTER
        # WAY TO SUPPORT LOOKUPS HERE! THE PROBLEM IS THAT MONGO CANNOT SUPPORT
        # '.' IN THE KEY NAME SO THIS IS A TEMPORARY FIX
        #k = "n:#{k.to_f}"
        k = "n:#{k.to_i}"
      else
        k = "s:#{k}"
      end
      
      i = self.value[k]
      if i.nil? then
        return ::Dog::Value.null_value
      else
        return i
      end
    end
    
    def []=(k, v)
      if k.kind_of? Numeric then
        self.min_numeric_key ||= k
        self.max_numeric_key ||= k
        
        self.min_numeric_key = [k, self.min_numeric_key].min
        self.max_numeric_key = [k, self.max_numeric_key].max
        
        # TODO - THIS IS REALLY REALLY REALLY BAD - I NEED TO FIGURE OUT A BETTER
        # WAY TO SUPPORT LOOKUPS HERE! THE PROBLEM IS THAT MONGO CANNOT SUPPORT
        # '.' IN THE KEY NAME SO THIS IS A TEMPORARY FIX
        #k = "n:#{k.to_f}"
        k = "n:#{k.to_i}"
      else
        k = "s:#{k}"
      end
      
      self.value[k] = v
    end
    
    def self.from_hash(hash)
      value = Value.new
      value._id = hash["_id"]
      value.pending = hash["pending"]
      value.from_future = hash["from_future"]
      value.buffer_size = hash["buffer_size"]
      value.channel_mode = hash["channel_mode"]
      value.person = hash["person"]
      value.type = hash["type"]
      value.value = hash["value"]
      value.min_numeric_key = hash["min_numeric_key"]
      value.max_numeric_key = hash["max_numeric_key"]
      
      value.person = ::Dog::Value.from_hash(value.person) if value.person
      
      unless Value.primitive_types.include? value.type then
        
        if value.value.kind_of? Array then
          array = value.value
          value.value = {}
          
          i = 0
          for v in array do
            value[i] = Value.from_hash(v)
            i += 1
          end
        else
          real_value = {}
          
          for k, v in value.value do
            real_value[k] = Value.from_hash(v)
          end
          
          value.value = real_value
        end
      end
      
      return value
    end
    
    # TODO - I need to add type safety here
    def self.from_ruby_value(ruby_value, type = nil)
      
      if ruby_value.kind_of? Hash then
        type ||= "structure"
        
        value = Value.new
        value.type = type
        value.value = {}
        
        for k, v in ruby_value do
          value[k] = self.from_ruby_value(v)
        end
        
        return value
      elsif ruby_value.kind_of? Array then
        # TODO
      else
        if ruby_value.kind_of? String then
          return self.string_value(ruby_value)
        elsif ruby_value.kind_of? Numeric then
          return self.number_value(ruby_value)
        elsif ruby_value.kind_of? NilClass then
          return self.null_value
        elsif ruby_value.kind_of? FalseClass then
          return self.false_value
        elsif ruby_value.kind_of? TrueClass then
          return self.true_value
        end
      end
    end
    
    def ruby_value
      # TODO - property add a types package and add array and structure to them
      if self.primitive? then
        return self.value
      elsif self.type == "dog.array"
        a = []
        
        for k, v in self.value do
          a << v.ruby_value
        end
        
        return a
      else
        h = {}
        for k, v in self.value do
          if k[0,1] == "n" then
            h[k[2,k.length].to_f] = v.ruby_value
          else
            h[k[2,k.length]] = v.ruby_value
          end
        end
        
        return h
      end
    end
    
    def mongo_value
      if self.primitive? then
        return self.value
      elsif self.type == "array"
        a = []
        
        for k, v in self.value do
          a << v.mongo_value
        end
        
        return a
      else
        h = {}
        for k, v in self.value do
          if k[0,1] == "n" then
            h[k[2,k.length].to_i.to_s] = v.mongo_value
          else
            h[k[2,k.length]] = v.mongo_value
          end
        end
        
        return h
      end
    end
    
    def primitive?
      Value.primitive_types.include? self.type
    end

    def self.empty_structure
      value = Value.new
      value.type = "dog.structure"
      value.value = {}
      return value
    end

    def self.empty_array
      value = Value.new
      value.type = "dog.array"
      value.value = {}
      return value
    end
    
    def self.string_value(string)
      value = Value.new
      value.type = "dog.string"
      value.value = string
      return value
    end
    
    def self.number_value(number)
      value = Value.new
      value.type = "dog.number"
      value.value = number
      return value
    end
    
    def self.true_value
      value = Value.new
      value.type = "dog.boolean"
      value.value = true
      return value
    end
    
    def self.false_value
      value = Value.new
      value.type = "dog.boolean"
      value.value = false
      return value
    end
    
    def self.null_value
      value = Value.new
      value.type = "dog.null"
      value.value = nil
      return value
    end
    
    def is_null?
      self.type == "dog.null"
    end
    
    def is_false?
      (self.type == "dog.boolean" && self.value == false) || self.is_null?
    end
    
  end
  
end
