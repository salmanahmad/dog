#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Variable < Sequel::Model(:variables)
    
    plugin :serialization, :json
    serialize_attributes :json, :value
    
    # Raw SQL for performance here. This query is properly indexed and very fast.
    @find_variable_query = "SELECT 'variables'.* FROM 'tracks' INNER JOIN 'variables' ON ('variables'.'track_id' = 'tracks'.'id') WHERE 'tracks'.'id' IN (SELECT parent_id FROM track_parents WHERE track_id = ?) AND 'variables'.'name' = ? ORDER BY 'tracks'.'depth' DESC LIMIT 1"
    
    
    def person
      Person.filter(:id => self.person_id).first
    end
    
    def self.exists?(name, track = nil)
      if track.nil? then
        track = Track.current
      end
      
      rows = ::Dog::database[@find_variable_query, track.id, name]
      return rows.first
    end
    
    def self.named(name, track = nil)
      if track.nil? then
        track = Track.current
      end
      
      puts ::Dog::database.fetch(@find_variable_query, track.id, name).sql
      rows = ::Dog::database.fetch(@find_variable_query, track.id, name).all
      
      puts rows.inspect
      
      if rows.first then
        variable = Variable.load(rows.first)
      else
        variable = Variable.new
        variable.name = name
        variable.track_id = track.id
        puts "#{name} - #{track.id}"
        variable.save
      end
      
      return variable
    end
    
  end
  
  module PendingVariable
    
    # TODO implement this...
    attr_accessor :permissions
    
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
    
    def complete?
      return false
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
    
    def complete?
      @value.size == pending_count
    end
    
    def notify_dependencies(request_context)
      
      while cursor < @value.length do
        should_break = (cursor == (pending_count - 1))
        
        for dependency in dependencies do
          
          if dependency.notify? || should_break then
            
            if dependency.trigger_count == -1 then
              v = @value
            else
              start = ((cursor - 1) - (dependency.trigger_count - 2))
              finish = cursor
              v = @value[start..finish]
            end
            
            v = v.first if v.length == 1
            
            if complete? && @value.length == 1 then
              @value = @value.first
            end
            
            EM.next_tick do
              dependency.track.fiber.request_context = request_context
              dependency.track.fiber.resume v, should_break
            end
          end
        end
        
        @cursor += 1
      end
      
    end
    
  end
  
  
  # TODO - Find a better place for this perhaps?
  Tilt.register Tilt::ERBTemplate, 'task'
  Tilt.register Tilt::ERBTemplate, 'message'
  Tilt.register Tilt::ERBTemplate, 'layout'
  
  module RenderableVariable
    def render(data = {}, context = {})
      locals = {}
      for key, value in data do
        locals[key.to_sym] = value
      end
      
      binding = Binding.generate(context)
      
      layout = Config.get('layout')
      
      if layout then
        layout = File.absolute_path(layout, Environment.program_directory)
        layout_template = Tilt::ERBTemplate.new(layout)
        layout_template.render do
          content_template = Tilt::ERBTemplate.new(@value)
          content_template.render(binding, locals)
        end
      else
        content_template = Tilt::ERBTemplate.new(@value)
        content_template.render(binding, locals)
      end
    end
  end
  
  class TaskVariable < Variable
    include RenderableVariable
    
    def value
      return self
    end
    
    
  end
  
  class MessageVariable < Variable
    include RenderableVariable
    
    def value
      return self
    end
    
  end
  
  
end