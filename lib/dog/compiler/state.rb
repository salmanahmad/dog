#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class State
    
    attr_accessor :parent
    attr_accessor :children
    attr_accessor :operation
    
    def initialize
      @parent = nil
      @children = []
      @variable_dependencies = []
      @variable_output = nil
      @operation = nil
    end
    
    def run
      # TODO
    end
    
    def to_bark
      Marshal.dump(self)
    end
    
    def self.from_bark(bark)
      state = Marshal.load(bark)
      raise "Error" if state.class != self
      return state
    rescue
      raise "Could not load state machine from bark."
    end
    
  end
  
end