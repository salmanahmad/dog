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
    attr_accessor :type
    attr_accessor :value
    
    def initialize(type = nil, value = nil)
      self.type = type
      self.value = value
    end
    
    def self.primitive_types
      ["string", "number", "boolean", "null"]
    end
    
    def to_hash
      if Value.primitive_types.include? self.type then
        return {
          "type" => self.type,
          "value" => self.value
        }
      else
        processed_value = {}
        for k, v in self.value do
          processed_value[k] = v.to_hash
        end
        
        return {
          "type" => self.type,
          "value" => processed_value
        }
      end
    end
    
    def self.from_hash(hash)
      value = Value.new
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
    
    def primitive?
      Value.primitive_types.include? self.type
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
    
    def self.null_value
      value = Value.new
      value.type = "null"
      value.value = nil
      return value
    end
    
  end
  
end
