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
      
      variable = nil
      variable_handle = dependency[0]
      
      if dependency.length == 1 then
        name = dependency[0]
        
        if Variable.exists?(name) then
          variable = Variable.named(name)
        elsif Variable.exists?(name + "s") then
          # TODO more rigorous pluralization here...
          variable = Variable.named(name + "s")
        else
          raise "Could not find variable reference '#{name}' in ON block."
        end
      else
        name = dependency[1]
        if Variable.exists?(name) then
          variable = Variable.named(name)
        else
          raise "Could not find variable reference '#{name}' in ON block."
        end
      end
      
      # TODO right now we are not support EACH # offers...
      # TODO right now we are only supporting listen variables...
      if !variable.listen then
        raise "Attempting to have an ON block on a variable that is not the result of an ASK or a LISTEN."
      end
      
      track = Track.new
      fiber = TrackFiber.new do
        
        loop do
          value, should_break = Fiber.yield
          
          on_track = Track.new
          on_fiber = TrackFiber.new do
            variable = Variable.named(variable_handle)
            variable.value = value
            for child in children do
              child.run
            end
            # Remove the track and clean up the parent track...
          end
          
          on_fiber.track = on_track
          on_fiber.request_context = Fiber.current.request_context
          on_fiber.resume
          
          
          break if should_break
        end
      end
      
      variable.track_dependencies << track
      fiber.track = track
      fiber.resume
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