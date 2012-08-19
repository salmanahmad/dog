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
    attr_accessor :buffer_size
    attr_accessor :channel_mode
    attr_accessor :type
    attr_accessor :value
    
    attr_accessor :min_numeric_key
    attr_accessor :max_numeric_key
    
    def initialize(type = nil, value = nil)
      self._id = UUID.new.generate
      self.type = type
      self.value = value
      self.pending = false
    end
    
    def self.primitive_types
      ["string", "number", "boolean", "null"]
    end
    
    def to_hash
      if Value.primitive_types.include? self.type then
        return {
          "_id" => self._id,
          "pending" => self.pending,
          "buffer_size" => self.buffer_size,
          "channel_mode" => self.channel_mode,
          "type" => self.type,
          "value" => self.value
        }
      else
        processed_value = {}
        for k, v in self.value do
          processed_value[k] = v.to_hash
        end
        
        return {
          "_id" => self._id,
          "pending" => self.pending,
          "buffer_size" => self.buffer_size,
          "channel_mode" => self.channel_mode,
          "type" => self.type,
          "value" => processed_value
        }
      end
    end
    
    def [](k)
      if k.kind_of? Numeric then
        k = "n:#{k}"
      else
        k = "s:#{k}"
      end
      
      self.value[k]
    end
    
    def []=(k, v)
      if k.kind_of? Numeric then
        self.min_numeric_key ||= k
        self.max_numeric_key ||= k
        
        self.min_numeric_key = [k, self.min_numeric_key].min
        self.max_numeric_key = [k, self.max_numeric_key].max
        
        k = "n:#{k}"
      else
        k = "s:#{k}"
      end
      
      self.value[k] = v
    end
    
    def self.from_hash(hash)
      value = Value.new
      value._id = hash["_id"]
      value.pending = hash["pending"]
      value.buffer_size = hash["buffer_size"]
      value.channel_mode = hash["channel_mode"]
      value.type = hash["type"]
      value.value = hash["value"]
      
      unless Value.primitive_types.include? value.type then
        real_value = {}
        
        for k, v in value.value do
          real_value[k] = Value.from_hash(v)
        end
        
        value.value = real_value
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
      
      if self.primitive? then
        return self.value
      else
        h = {}
        for k, v in self.value do
          h[k[2,k.length]] = v.ruby_value
        end
        
        return h
      end
    end
    
    def primitive?
      Value.primitive_types.include? self.type
    end
    
    def self.empty_structure
      value = Value.new
      value.type = "structure"
      value.value = {}
      return value
    end
    
    def self.string_value(string)
      value = Value.new
      value.type = "string"
      value.value = string
      return value
    end
    
    def self.number_value(number)
      value = Value.new
      value.type = "number"
      value.value = number
      return value
    end
    
    def self.true_value
      value = Value.new
      value.type = "boolean"
      value.value = true
      return value
    end
    
    def self.false_value
      value = Value.new
      value.type = "boolean"
      value.value = false
      return value
    end
    
    def is_null?
      self.type == "null"
    end
    
    def is_false?
      self.type == "boolean" && self.value == false
    end
    
    def self.null_value
      value = Value.new
      value.type = "null"
      value.value = nil
      return value
    end
    
  end
  
end
