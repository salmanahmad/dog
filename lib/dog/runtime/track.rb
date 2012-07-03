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
      WAITING = "waiting"
      FINISHED = "finished" 
      ERROR = "error"
      DELETED = "deleted"
    end
    
    attr_accessor :_id
    
    attr_accessor :function_name
    attr_accessor :function_filename
    attr_accessor :current_node_path
    
    attr_accessor :access_ancestors
    attr_accessor :control_ancestors
    
    attr_accessor :state
    attr_accessor :stack
    attr_accessor :variables
    
    attr_accessor :return_value
    attr_accessor :error_value
    
    # TODO - Think about adding back references when we
    # decide on the object model for the language
    #attr_accessor :references
    
    def to_hash
      return {
        function_name: self.function_name,
        current_node_path: self.current_node_path,
        access_ancestors: self.access_ancestors,
        control_ancestors: self.control_ancestors,
        state: self.state,
        stack: self.stack,
        variables: self.variables,
        return_value: self.return_value,
        error_value: self.error_value
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
        "ancestors" => {
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
        root = Track.new
        root.function_name = name
        root.function_filename = filename
        root.ancestors = []
        root.depth = 0
        root.checkpoint = [0]
        root.save
      end
      
      return root
    end
    
    def continue
      # TODO - check for state first
      while self.current_node_path do
         node_path = Runtime.node_at_path_for_filename(self.current_node_path, self.function_filename).visit(self)
         self.current_node_path = node_path
         # TODO - when do I save this stuff?
      end
      
      # Return from the function call...
    end
    
  end
  
end