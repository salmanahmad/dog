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
    
    attr_accessor :_id
    attr_accessor :ancestors
    attr_accessor :checkpoint
    attr_accessor :depth
    
    # Volatile properties
    attr_accessor :fiber
    
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
    
    def fiber=(f)
      @fiber = f
      f.instance_variable_set(:@track, self._id)
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
        root = Track.new
        root.ancestors = []
        root.depth = 0
        root.checkpoint = 0
        root.save
        
        return root
      end
    end
    
    def self.current
      track = Fiber.current.track

      if track.nil?
        raise "Attempting to access a track outside of a fiber"
      end

      return track
    end
    
  end
  
end