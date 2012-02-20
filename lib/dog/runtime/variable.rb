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
    
    @@variables = {}
    
    def self.variables
      @@variables
    end
    
    def self.exists?(name, track = nil)
      if track.nil? then
        track = Track.current
      end
      
      @@variables[track.name] ||= {}
      
      if @@variables[track.name].include? name then
        return true
      else
        return false
      end
    end
    
    def self.named(name, track = nil)
      if track.nil? then
        track = Track.current
      end
      
      @@variables ||= {}
      @@variables[track.name] ||= {}
      
      variable = @@variables[track.name][name]
      
      if variable.nil? then
        variable = self.new
        variable.name = name
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
  
  module PendingVariable
    
    attr_accessor :pending_count
    attr_accessor :dependencies
    
    def notify_dependencies(request_context)
    end
    
    def push_value(v)
      @value << v
    end
    
  end
  
  class VariableDependency
    attr_accessor :track
    attr_accessor :trigger_count
    attr_accessor :current_count
    
    def initialize
      self.trigger_count = 1
      self.current_count = 0
    end
    
    def notify?
      self.current_count += 1
      if self.current_count == self.trigger_count then
        self.current_count = 0
        return true
      else
        return false
      end
    end
    
  end
  
  class ListenVariable < Variable
    include PendingVariable
    
    def initialize
      @pending_count = -1
      @dependencies = []
      @value = []
    end
    
    def value
      raise "You cannot access the value of a ListenVariable directly. Use an ON block instead."
    end
    
    def notify_dependencies(request_context)
      
      until @value.empty? do
        v = @value.pop
        for dependency in dependencies do
          if dependency.notify? then
            EM.next_tick do 
              dependency.track.fiber.request_context = request_context
              dependency.track.fiber.resume v, false
            end
          end
        end
      end
      
    end
    
  end
  
  class AskVariable < Variable
    include PendingVariable
    
    attr_accessor :cursor
    
    def initialize
      @pending_count = 1
      @dependencies = []
      @value = []
      
      @cursor = 0
    end
    
    def value
      if self.cursor < self.pending_count then
        dependency = VariableDependency.new
        dependency.track = Track.current
        dependency.trigger_count = -1
        self.dependencies << dependency
        
        Fiber.yield
      end
      super
    end
    
    
    def notify_dependencies(request_context)
      
      while cursor < value.length do
        
        should_break = (cursor == (pending_count - 1))
        
        for dependency in dependencies do
          if dependency.notify? || should_break then
            start = ((cursor - 1) - (dependency.trigger_count - 2))
            finish = cursor
            v = value[start..finish]
            v = v.first if v.length == 1
            
            EM.next_tick do
              track_dependency.fiber.request_context = request_context
              track_dependency.fiber.resume v, should_break
            end
          end
        end
        
        cursor += 1
      end
      
    end
    
  end
  
end