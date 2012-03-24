#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Record < Structure
    # TODO
    
    property "id", :type => String
    
    def initialize
      # TODO - Remove for Mongo?      
      self.id = UUID.new.generate
    end
    
    def save
      if required_properties_present? then
        self.to_hash
      else
        nil
      end
    end
    
    def self.relationship(name, options = {})
      
    end
  end
  
end