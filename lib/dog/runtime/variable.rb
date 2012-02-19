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
    
    attr_accessor :listen
    attr_accessor :track_dependencies
    
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
    
    def self.named(name, listen = false, track = nil)
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
        variable.listen = listen
        variable.track_dependencies = []
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
    
    def notify_dependencies
      if self.listen then
        # TODO this okay because we currently only letting on clauses
        # that wait on a variable from a LISTEN or an ASK. We may need to
        # do something to keep track of what values you have sent along already
        until value.empty? do
          v = value.pop
          for track_dependency in track_dependencies do
            # TODO figure out when I should resume with true
            EM.next_tick { track_dependency.fiber.resume v, false }
          end
        end
      end
    end
    
  end
  
end