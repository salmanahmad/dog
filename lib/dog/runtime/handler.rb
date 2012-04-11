#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  class Handler
    
    attr_accessor :variable_name
    
    def initialize(variable)
      self.variable_name = variable
    end
    
    def to_hash
      return {
        type: self.class.name,
        variable_name: self.variable_name
      }
    end
    
    def self.from_hash(hash)
      type = Kernel.qualified_const_get(hash["type"])
      object = type.new(hash["variable_name"])
      return object
    end
    
  end
end