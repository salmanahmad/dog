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
      ASKING = "asking"
      WAITING = "waiting"
      LISTENING = "listening"
      FINISHED = "finished"
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
    attr_accessor :next_track
    
    attr_accessor :stack
    attr_accessor :variables
    attr_accessor :futures
    attr_accessor :state
    
    attr_accessor :access_ancestors
    attr_accessor :control_ancestors
    
    # TODO - I don't think that any of these are used anymore
    attr_accessor :has_listen
    attr_accessor :asking_id
    
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
      if self.has_listen then
        self.state = ::Dog::Track::STATE::LISTENING
      else
        self.state = ::Dog::Track::STATE::FINISHED
      end
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
      
      object.stack = stack
      object.variables = variables
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
          raise "A non-value was present on the stack"
        end
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
        
        "access_ancestors" => access_ancestors,
        "control_ancestors" => control_ancestors,
        
        "has_listen" => self.has_listen,
        "asking_id" => self.asking_id
      }
    end

    def to_hash_for_stream
      api_state = case self.state
      when ::Dog::Track::STATE::FINISHED,
        ::Dog::Track::STATE::ERROR,
        ::Dog::Track::STATE::DELETED
        'closed'
      when ::Dog::Track::STATE::LISTENING
        'listening'
      else
        'open'
      end
      stream_hash = {
        "id" => self._id.to_s,
        "name" => self.function_name.split('.'),
        "type" => "track",
        "state" => api_state
      }
      return stream_hash
    end
    
    def self.root
      root = self.find_one({
        "control_ancestors" => {
          "$size" => 0
        }
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