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
    
    def initialize
      @parent = nil
      @children = []
    end
    
    def add_child(child)
      if !child.kind_of?(Array) then
        child = [child]
      end
      
      for c in child do
        unless c.nil? then
          c.parent = self
          self.children << c
        end
      end
    end
    
    def run
      raise "Run on state was called."
    end
  end
  
  class ProgramState < State
    def to_bark
      Marshal.dump(self)
    end
    
    def self.from_bark(bark)
      state = Marshal.load(bark)
      raise "Error" if state.class != self
      return state
    rescue
      raise "Could not load program from bark."
    end
    
    def run
      for child in children do
        child.run
      end
    end
  end
  
  class OperationState < State
    attr_accessor :operation
    
    def run
      operation.run
    end
  end
  
  class OnState < State
    attr_accessor :dependency
    
    def run
      
    end
  end
  
  class ForState < State
    attr_accessor :enumerable
    
    def run
      
    end
  end
  
  class RepeatState < State
    attr_accessor :count
    
    def run
      
    end
  end
  
  class IfState < State
    def run
      
    end
  end
  
  class ConditionState < State
    attr_accessor :condition
    
    def run
      
    end
  end
  
end