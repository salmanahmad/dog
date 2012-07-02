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
    
    module Status
      RUNNING = "running"
      WAITING = "waiting"
      FINISHED = "finished" 
      ERROR = "error"
      DELETED = "deleted"
    end
    
    attr_accessor :_id
    
    # TODO - Change ancestors to access_ancestors
    # TODO - Add new property called control_ancestors
    attr_accessor :ancestors
    attr_accessor :checkpoint
    attr_accessor :depth
    
    attr_accessor :references
    attr_accessor :variables
    attr_accessor :status
    
    # Volatile properties
    # None - for now
    
    def to_hash
      return {
        ancestors: self.ancestors,
        checkpoint: self.checkpoint,
        depth: self.depth
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
    
    def self.initialize_root(checkpoint)
      root = self.root
      
      unless root
        root = Track.new
        root.ancestors = []
        root.depth = 0
        root.checkpoint = checkpoint
        root.save
      end
      
      return root
    end
    
    def continue
      # TODO
    end
    
  end
  
end