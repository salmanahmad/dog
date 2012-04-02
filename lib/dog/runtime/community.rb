#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class Community < DatabaseObject
    collection "communities"
    
    attr_accessor :_id
    attr_accessor :name
    attr_accessor :properties
    
    def members
      
    end
    
    def self.from_hash
      
    end
    
    def to_hash
      return {
        name: self.name,
        properties: self.properties
      }
    end
  end
end