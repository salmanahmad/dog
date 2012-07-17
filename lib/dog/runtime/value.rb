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
  end
  
end
