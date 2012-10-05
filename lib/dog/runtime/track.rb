#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Track < DatabaseObject
    collection "tracks"
    
    module STATE
      RUNNING = "running"
      CALLING = "calling"
      WAITING = "waiting"
      FINISHED = "finished"
      
      # TODO - Remove the following from the code base
      ASKING = "asking"
      LISTENING = "listening"
      ERROR = "error"
      DELETED = "deleted"
    end
    
    attr_accessor :_id
    attr_accessor :future_return_id
    
    attr_accessor :package_name
    attr_accessor :function_name
    attr_accessor :implementation_name
    
    attr_accessor :current_instruction
    attr_accessor :next_instruction
    
    attr_accessor :stack
    attr_accessor :variables
    attr_accessor :futures
    attr_accessor :state
    
    attr_accessor :displays
    attr_accessor :listens
    
    attr_accessor :access_ancestors
    attr_accessor :control_ancestors
    
    # TODO - I don't think that any of these are used anymore
    attr_accessor :has_listen
    attr_accessor :asking_id
    
    def self.invoke(function, package, arguments = [], parent = nil)
      # TODO - This should be largely unnecssary. I should update the parser / compiler
      # so that it assigns the function arguments by immediately poping the values off
      # of the stack. Now only is that more performant, it also makes this code largely
      # disappear.
      implementation = 0
      
      new_track = ::Dog::Track.new
      new_track.package_name = package
      new_track.function_name = function
      new_track.implementation_name = implementation

      symbol = ::Dog::Runtime.bundle.packages[package].symbols[function]["implementations"][implementation]
      symbol_arguments = symbol["arguments"]

      arguments.each_index do |index|
        argument = arguments[index]
        variable_name = symbol_arguments[index]
        new_track.variables[variable_name] = argument
      end
      
      if parent then
        new_track.control_ancestors = parent.control_ancestors.clone
        new_track.control_ancestors << parent
      end
      
      return new_track
    end
    
    def initialize(function_name = nil, package_name = "", implementation_name = 0)
      self.package_name = package_name
      self.function_name = function_name
      self.implementation_name = implementation_name
      
      self.current_instruction = 0
      self.next_instruction = nil
      
      self.stack = []
      self.variables = {}
      self.futures = {}
      self.state = STATE::RUNNING
      
      self.displays = {}
      self.listens = {}
      
      self.access_ancestors = []
      self.control_ancestors = []
    end
    
    def context
      return @context if @context
      
      package = ::Dog::Runtime.bundle.packages[self.package_name]
      symbol = package.symbols[self.function_name]
      @context = symbol["implementations"][implementation_name]
    end
    
    def finish
      self.state = ::Dog::Track::STATE::FINISHED
    end
    
    def self.from_hash(hash)
      object = super
      
      stack = object.stack.map do |item|
        ::Dog::Value.from_hash(item)
      end
      
      variables = {}
      for key, value in object.variables do
        variables[key] = ::Dog::Value.from_hash(value)
      end
      
      futures = {}
      for key, value in object.futures do
        futures[key] = ::Dog::Value.from_hash(value)
      end
      
      displays = {}
      for key, value in object.displays do
        displays[key] = {
          "value" => ::Dog::Value.from_hash(value["value"]),
          "routing" => ::Dog::Value.from_hash(value["routing"])
        }
      end
      
      listens = {}
      for key, value in object.listens do
        listens[key] = {
          "value" => ::Dog::Value.from_hash(value["value"]),
          "routing" => ::Dog::Value.from_hash(value["routing"])
        }
      end
      
      object.stack = stack
      object.variables = variables
      object.displays = displays
      object.listens = listens
      object.futures = futures
      
      return object
    end
    
    def to_hash
      stack = self.stack.map do |item|
        if item.kind_of? ::Dog::Value then
          item.to_hash
        else
          raise "A non-value was present on the stack: #{item.inspect}"
        end
      end
      
      variables = {}
      for key, value in self.variables do
        if value.kind_of? ::Dog::Value then
          variables[key] = value.to_hash
        else
          raise "A non-value was present in the variables"
        end
      end
      
      displays = {}
      for key, value in self.displays do
        displays[key] = {
          "value" => value["value"].to_hash,
          "routing" => value["routing"].to_hash
        }
      end
      
      listens = {}
      for key, value in self.listens do
        listens[key] = {
          "value" => value["value"].to_hash,
          "routing" => value["routing"].to_hash
        }
      end
      
      futures = {}
      for key, value in self.futures do
        if value.kind_of? ::Dog::Value then
          futures[key] = value.to_hash
        else
          raise "A non-value was present on the stack"
        end
      end
      
      control_ancestors = self.control_ancestors.map do |item|
        if item.kind_of? Track then
          item.save
          item._id
        elsif item.kind_of? BSON::ObjectId then
          item
        else
          raise "An invalid object appeared in the control ancestors for a track"
        end
      end
      
      # TODO: I don't need this, do I?
      access_ancestors = []
      
      return {
        "future_return_id" => self.future_return_id,
        "package_name" => self.package_name,
        "function_name" => self.function_name,
        "implementation_name" => self.implementation_name,
        
        "current_instruction" => self.current_instruction,
        "next_instruction" => nil,
        
        "state" => self.state,
        "stack" => stack,
        "variables" => variables,
        "futures" => futures,
        
        "displays" => displays,
        "listens" => listens,
        
        "access_ancestors" => access_ancestors,
        "control_ancestors" => control_ancestors,
        
        "has_listen" => self.has_listen,
        "asking_id" => self.asking_id
      }
    end

    def to_hash_for_api_user(user = nil)
      displays = {}
      for key, value in self.displays do
        displays[key] = value["value"].ruby_value
      end
      
      listens = {}
      for key, value in self.listens do
        # TODO - Handle the schema for listens
        listens[key] = {}
      end
      
      returns = nil
      if self.state == ::Dog::Track::STATE::FINISHED then
        returns = self.stack.last.ruby_value
      end
      
      hash = {
        "_id" => self._id.to_s,
        "state" => self.state,
        "function_name" => self.function_name,
        "package_name" => self.package_name,
        "displays" => displays,
        "listens" => listens,
        "returns" => returns
      }
      
      return hash
      
    end

    def self.root
      root = self.find_one({
        "control_ancestors" => {
          "$size" => 0
        },
        "function_name" => "@root"
      })
      
      if root then
        return root
      else
        nil
      end
    end
    
    def is_root?
      return self.function_name == "@root" && self.package_name == ::Dog::Runtime.bundle.startup_package
    end
  end
end