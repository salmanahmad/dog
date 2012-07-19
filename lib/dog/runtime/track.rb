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
      LISTENING = "listening"
      FINISHED = "finished" 
      ERROR = "error"
      DELETED = "deleted"
    end
    
    attr_accessor :_id
    
    attr_accessor :function_name
    attr_accessor :function_filename
    attr_accessor :current_node_path
    
    attr_accessor :mandatory_arguments
    attr_accessor :optional_arguments
    
    attr_accessor :access_ancestors
    attr_accessor :control_ancestors
    
    attr_accessor :state
    attr_accessor :stack
    attr_accessor :variables
    
    attr_accessor :return_value
    attr_accessor :error_value
    
    attr_accessor :has_listen
    attr_accessor :listen_argument
    
    def initialize(name = nil)
      
      if name then
        path = Runtime.bite_code["symbols"][name]
        
        if path.nil? then
          raise "I could not find a symbol named: #{name}"
        end
        
        path = path.clone
        filename = path.shift
        
        self.function_name = name
        self.function_filename = filename
        self.current_node_path = path
      end
      
      self.access_ancestors = []
      self.control_ancestors = []
      
      self.state = STATE::RUNNING
      self.stack = {}
      self.variables = {}
      
      self.return_value = nil
      self.error_value = nil
    end
    
    def has_visited?(node)
      result = has_stack_path(node.path)
      return result
    end
    
    def should_visit(node)
      if node then
        self.current_node_path = node.path
      else
        finish
      end
    end
    
    def read_return_value
      value = self.return_value
      
      if value.nil? then
        return ::Dog::Value.null_value
      else
        return ::Dog::Value.from_hash(value)
      end
    end
    
    def write_return_value(value)
      if value.class != ::Dog::Value then
        raise "You cannot save a non-Value object to a local variable"
      end
      
      value = value.to_hash
      self.return_value = value
    end
    
    def read_variable(name)
      value = self.variables[name]
      if value.nil? then
        return ::Dog::Value.null_value
      else
        return ::Dog::Value.from_hash(value)
      end
    end
    
    def write_variable(name, value)
      if value.class != ::Dog::Value then
        raise "You cannot save a non-Value object to a local variable"
      end
      
      value = value.to_hash
      self.variables[name] = value
    end
    
    
    def has_stack_path(path)
      pointer = self.stack
      
      for item in path do
        item = item.to_s
        
        if pointer.respond_to?(:has_key?) && pointer.has_key?(item) then
          pointer = pointer[item]
        else
          return false
        end
      end
      
      return true
    end
    
    def write_stack(path, value)
      # TODO - The leafs of the stack must always be a Value. And a Value
      # must not appear anywhere but the leafs. I need to ensure that this
      # is always the case.
      
      if value.class != ::Dog::Value then
        raise "You cannot write a non-Value object to the Dog stack."
      end
      
      value = value.to_hash
      
      path = path.clone
      last = path.pop
      stack = self.stack
      
      return if last.nil?
      
      for index in path do
        index = index.to_s
        stack[index] ||= {}
        stack = stack[index]
      end
      
      stack[last.to_s] = value
    end
    
    def clear_stack(path)
      path = path.clone
      last = path.pop
      stack = self.stack
      
      return if last.nil?
      
      for index in path do
        index = index.to_s
        stack[index] ||= {}
        stack = stack[index]
      end
      
      stack[last.to_s] = nil
    end
    
    def read_stack(path)
      path = path.clone
      stack = self.stack
      
      begin
        for index in path do
          index = index.to_s
          stack = stack[index]
        end
        
        return ::Dog::Value.from_hash(stack)
      rescue
        return nil
      end
    end
    
    def finish
      if self.has_listen then
        self.state = ::Dog::Track::STATE::LISTENING
      else
        self.state = ::Dog::Track::STATE::FINISHED
      end
    end
    
    def to_hash
      return {
        "function_name" => self.function_name,
        "function_filename" => self.function_filename,
        "current_node_path" => self.current_node_path,
        "mandatory_arguments" => self.mandatory_arguments,
        "optional_arguments" => self.optional_arguments,
        "access_ancestors" => self.access_ancestors,
        "control_ancestors" => self.control_ancestors,
        "state" => self.state,
        "stack" => self.stack,
        "variables" => self.variables,
        "return_value" => self.return_value,
        "error_value" => self.error_value,
        "has_listen" => self.has_listen,
        "listen_argument" => self.listen_argument
      }
    end

    def to_hash_for_stream
      return {
        "id" => "handler:#{self._id}",
        # FIXME HACK -- remove this once the name is pluralized properly on backend
        "name" => [ self.function_name ],
        "type" => "track"
      }
    end

    def self.create(hash)
      parent = nil
      
      if hash[:parent_id] then
        parent = Track.find_by_id(hash[:parent_id])
      else
        parent = Track.current
      end
      
      track = Track.new
      track.ancestors = parent.scoped_ancestors
      track.depth = parent.depth + 1
      track.checkpoint = 0
      track.save
      
      return track
    end
    
    def scoped_ancestors
      ancestors = self.ancestors
      ancestors ||= []
      ancestors << self._id
      return ancestors
    end
    
    def checkpoint &block
      # TODO
    end
    
    def reset_checkpoint &block
      # TODO
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
    
    def self.initialize_root(name, filename)
      root = self.root
      
      unless root
        root = Track.new("root")
        root.save
      end
      
      return root
    end
    
  end
  
end