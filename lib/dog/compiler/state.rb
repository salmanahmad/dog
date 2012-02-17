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
      raise "Run on the base state was called."
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
      track = Track.new
      fiber = TrackFiber.new do
        for child in children do
          output = child.run
        end
        output
      end
      
      fiber.track = track
      fiber.resume
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
      count.run.to_i.times do
        for child in children do
          child.run
        end
      end
    end
  end
  
  class IfState < State
    def run
      for child in children do
        if child.run then
          break
        end
      end
    end
  end
  
  class ConditionState < State
    attr_accessor :condition
    
    def run
      if condition.nil? || (condition.run == true) then
        return true
      else
        return false
      end
    end
  end
  
end