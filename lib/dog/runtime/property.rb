#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

# TODO - How do I handle multiple parameters of the same name?

module Dog
  
  class Property
    attr_accessor :identifier
    attr_accessor :value
    attr_accessor :required
    attr_accessor :direction
    
    def self.from_hash(hash)
      property = self.new
      property.identifier = hash["identifier"]
      property.value = hash["value"]
      property.required = hash["required"]
      property.direction = hash["direction"]
      
      return property
    end
    
    def to_hash
      return {
        "identifier" => self.identifier,
        "value" => self.value, 
        "required" => self.required,
        "direction" => self.direction
      }
    end
  end
  
  class CommunityAttribute
    attr_accessor :identifier
  end
  
  class CommunityRelationship
    attr_accessor :identifier
    attr_accessor :inverse_identifier
    attr_accessor :inverse_community
  end
  
end