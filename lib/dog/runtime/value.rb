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
    
    def to_hash
      return {
        "type" => self.type,
        "value" => self.value
      }
    end
    
    def self.from_hash(hash)
      value = Value.new
      value.type = hash["type"]
      value.value = hash["value"]
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
    
    def self.null_value
      value = Value.new
      value.type = "null"
      value.value = nil
      return value
    end
    
  end
  
end
