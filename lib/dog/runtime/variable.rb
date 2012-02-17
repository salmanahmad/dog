#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Variable
    
    attr_accessor :name
    attr_accessor :value
    attr_accessor :valid
    attr_accessor :dirty
    
    @@variables = {}
    
    def self.variables
      @@variables
    end
    
    def self.named(name, track = nil)
      if track.nil? then
        track = Track.current
      end
      
      @@variables ||= {}
      @@variables[track.name] ||= {}
      
      variable = @@variables[track.name][name]
      
      if variable.nil? then
        variable = Variable.new
        variable.name = name
        variable.value = nil
        
        @@variables[track.name][name] = variable
      end
      
      return variable
    end
    
    def value=(v)
      @value = v
    end
    
    def value
      @value
    end
    
  end
  
end