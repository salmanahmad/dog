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
    
    def self.primitive_types
      ["dog.string", "dog.number", "dog.boolean", "dog.null"]
    end
    
    def initialize(type = nil, value = nil)
      self._id = BSON::ObjectId.new
      self.type = type
      self.value = value
      self.pending = false
      self.from_future = nil
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
      
      if self.value.nil? then
        processed_value = value
      elsif self.primitive? then
        processed_value = value
      else
        processed_value = []
        for k, v in value do
          processed_value << {
            "key" => k,
            "value" => v.to_hash
          }
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
    
    def keys
      self.value.keys
    end
    
    def [](k)
      v = self.value[k]
      
      if v.nil? then
        return ::Dog::Value.null_value
      else
        return v
      end
    end
    
    def []=(k, v)
      if k.kind_of? Numeric then
        self.min_numeric_key ||= k
        self.max_numeric_key ||= k
        
        self.min_numeric_key = [k, self.min_numeric_key].min
        self.max_numeric_key = [k, self.max_numeric_key].max
        
        k = k.to_f
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
      
      unless value.primitive? then
        real_value = {}
        
        for item in value.value do
          k = item["key"]
          v = item["value"]
          real_value[k] = Value.from_hash(v)
        end
        
        value.value = real_value
      end
      
      return value
    end
    
    def self.from_ruby_value(ruby_value, type = nil)
      if ruby_value.kind_of? Hash then
        type ||= "dog.structure"
        
        value = Value.new
        value.type = type
        value.value = {}
        
        for k, v in ruby_value do
          value[k] = self.from_ruby_value(v)
        end
        
        return value
      elsif ruby_value.kind_of? Array then
        value = Value.empty_array
        
        ruby_value.each_index do |index|
          value[index] = self.from_ruby_value(ruby_value[index])
        end
        
        return value
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
          h[k] = v.ruby_value
        end
        
        return h
      end
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
      value.value = string.to_s
      return value
    end
    
    def self.number_value(number)
      value = Value.new
      value.type = "dog.number"
      value.value = number.to_f
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
    
    def primitive?
      Value.primitive_types.include? self.type
    end
    
    def is_null?
      self.type == "dog.null"
    end
    
    def is_false?
      (self.type == "dog.boolean" && self.value == false) || self.is_null?
    end
    
  end
  
end
