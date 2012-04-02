#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Track
    
    attr_accessor :_id
    attr_accessor :ancestors
    attr_accessor :checkpoint
    attr_accessor :depth
    
    attr_accessor :context
    attr_accessor :fiber
    
    def self.from_hash
      # TODO
    end
    
    def to_hash
      return {
        "ancestors" => self.ancestors,
        "checkpoint" => self.checkpoint,
        "depth" => self.depth
      }
    end
    
    def save
      if self._id then
        ::Dog::database["tracks"].update({"_id" => self._id}, self.to_hash)
      else
        id = ::Dog::database["tracks"].insert(self.to_hash)
        self._id = id
      end
    en
    
    def self.create
      parent = Track.current
      
      track = Track.new
      track.ancestors = parent.scoped_ancestors
      track.depth = parent.depth + 1
      track.checkpoint = 0
      track.save
        
      return track
    end
    
    def context
      @context ||= {}
      @context
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
      root = ::Dog.database["tracks"].find_one({
        "ancestors" => {
          "$size" => 0
        }
      })
      
      if root then
        return Track.from_hash(root)
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