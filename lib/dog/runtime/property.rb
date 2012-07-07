#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Property
    attr_accessor :identifier
    attr_accessor :default
    attr_accessor :requirement
    attr_accessor :direction
    
    def self.from_hash(hash)
      property = self.new
      property.identifier = hash["identifier"]
      property.default = hash["default"]
      property.requirement = hash["requirement"]
      property.direction = hash["direction"]
      
      return property
    end
    
    def to_hash
      return {
        "identifier" => self.identifier,
        "default" => self.default, 
        "requirement" => self.requirement,
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