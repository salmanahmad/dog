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
    
    # TODO - Think about adding back references when we
    # decide on the object model for the language
    #attr_accessor :references
    
    def initialize(name = nil)
      
      if name then
        path = Runtime.bite_code["symbols"][name]
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
    
    def finish
      if self.has_listen then
        self.state = ::Dog::Track::STATE::LISTENING
      else
        self.state = ::Dog::Track::STATE::FINISHED
      end
    end
    
    def to_hash
      return {
        function_name: self.function_name,
        function_filename: self.function_filename,
        current_node_path: self.current_node_path,
        mandatory_arguments: self.mandatory_arguments,
        optional_arguments: self.optional_arguments,
        access_ancestors: self.access_ancestors,
        control_ancestors: self.control_ancestors,
        state: self.state,
        stack: self.stack,
        variables: self.variables,
        return_value: self.return_value,
        error_value: self.error_value,
        has_listen: self.has_listen
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
    
    def continue
      # TODO - check for state first
      
      called_track = nil
      
      while self.current_node_path do
         node = Runtime.node_at_path_for_filename(self.current_node_path, self.function_filename)
         
         # TODO - Really consider fixing this... it is gross
         
         node_path = node.visit(self)
         
         if node_path.class == Track then
           called_track = node_path
           break
         else
          self.current_node_path = node_path
         end
      end
      
      self.save
      
      if self.state == STATE::FINISHED || self.state == STATE::LISTENING
        # I'm done!...
        parent_track = Track.find_by_id(self.control_ancestors.last)
        
        if parent_track then
          parent_current_node = Runtime.node_at_path_for_filename(parent_track.current_node_path, parent_track.function_filename)
          parent_current_node.write_stack(parent_track, self.return_value)
        
          parent_track.current_node_path = parent_current_node.parent.path
          parent_track.state = STATE::RUNNING
          parent_track.continue
        end
      end
      
      if called_track then
        called_track.continue 
      end
    end
    
  end
  
end