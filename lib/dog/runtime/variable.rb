#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Variable < DatabaseObject
    collection "variables"
    
    attr_accessor :_id
    attr_accessor :track_id
    attr_accessor :person_id  # Used with LISTEN
    attr_accessor :task_id    # Used with ASK 
    attr_accessor :handlers   # Used with ASK. TODO
    attr_accessor :name
    attr_accessor :type
    attr_accessor :value
    
    # Denormalization
    attr_accessor :track_depth
    
    def to_hash
      type = nil
      value = nil
      
      if @value.kind_of? Structure then
        value = @value.export
        type = @value.class.name
      else
        value = @value
      end
      
      hash = {
        track_id: self.track_id,
        person_id: self.person_id,
        task_id: self.task_id,
        handlers: (self.handlers || []),
        track_depth: self.track_depth,
        name: self.name,
        type: type,
        value: value
      }
      
      return hash
    end
    
    def self.from_hash(hash)
      object = super
      
      type = hash["type"]
      if type then
        type = Kernel.qualified_const_get(type)
        if type.ancestors.include? Structure then
          object.value = type.import(object.value)
        end
      end
      
      return object
    end
    
    def person
      Person.find_by_id(self.person_id)
    end
    
    def self.notify_handlers_for_task(task)
      
      variable = Variable.find_one({"task_id" => task._id})
      
      if variable then
        variable.value = task.responses
        variable.save
        
        if task.completed? then
          for fiber in TrackFiber.fibers do
            # TODO If the fiber is not there, what do I do? Start a new one? I need to have my start up logic to do that...
            if fiber.track._id == variable.track_id then
              EM.next_tick do
                fiber.resume
              end
              break
            end
          end
        end
        
        response = task.responses.last
        for handler in variable.handlers do
          variable_name = handler["variable_name"]
          handler_class = Kernel.qualified_const_get(handler["type"])
          
          # TODO - Is this parent_id correct?
          track = Track.create(:parent_id => variable.track_id)
          
          fiber = TrackFiber.new do
            handler_class.new.run
          end
          
          variable = Variable.create(variable_name, track)
          variable.value = response
          variable.save
          track.fiber = fiber
          
          EM.next_tick do
            track.fiber.resume
          end
        end
      end
    end
    
    def listen(handler)
      return unless handler.kind_of? Handler
      
      self.handlers ||= []
      self.handlers << {
        "type" => handler.class.name,
        "variable_name" =>  handler.variable_name
      }
    end
    
    def self.exists?(name, track = nil)
      if track.nil? then
        track = Track.current
      end
      
      ancestors = track.scoped_ancestors
      document = self.find_one({
        "name" => name,
        "track_id" => {
          "$in" => ancestors
        }
      }, {
        :sort => {
          "track_depth" => -1
        }
      })
      
      return document
    end
    
    def value=(value)
      if value.class == RoutedTask then
        self.task_id = value._id
        @value = nil
      else
        @value = value
      end
    end
    
    def value
      if self.task_id then
        task = RoutedTask.find_by_id(self.task_id)
        if task.completed? then
          return @value
        else
          Fiber.yield
          self.reload
          return @value
        end
      else
        return @value
      end
    end
    
    def self.create(name, track = nil)
      if track.nil? then
        track = Track.current
      end
      
      variable = self.exists?(name, track)
      if variable.nil? || (variable.track_id != track.id) then
        variable = Variable.new
        variable.name = name
        variable.track_id = track._id
        variable.track_depth = track.depth
        variable.save
      end
      
      return variable
    end
    
    def self.named(name, track = nil)
      if track.nil? then
        track = Track.current
      end
      
      variable = self.exists?(name, track)
      unless variable then
        variable = Variable.new
        variable.name = name
        variable.track_id = track._id
        variable.track_depth = track.depth
        variable.save
      end
      
      return variable
    end
    
  end
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  # TODO - Remove this old stuff. I don't think any of it is necessary at all.
  
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