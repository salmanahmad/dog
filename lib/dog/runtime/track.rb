#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Track < Sequel::Model(:tracks)
            
    attr_accessor :context
    attr_accessor :fiber
    
    many_to_one :parent, :class => self, :key => :parent_id
    one_to_many :children, :class => self, :key => :parent_id
    
    def self.create(values = {}, &block)
      ::Dog.database.transaction do
        track = super
        parent = track.parent
        if parent then 
          track.depth = parent.depth + 1
          track.save
        end
        
        parents = track.parents
        parents.unshift track
        
        for parent in parents do
          ::Dog.database[:track_parents].insert(:track_id => track.id, :parent_id => parent.id)
        end
        
        return track
      end
    end
    
    def context
      @context ||= {}
      @context
    end
    
    def parents
      parents = []
      parent = self.parent
      while(true)
        break if parent.nil?
        parents << parent
        parent = parent.parent
      end
      
      return parents
    end
   
    def fiber=(f)
      @fiber = f
      f.instance_variable_set(:@track, self.id)
    end
    
    def checkpoint &block
      # TODO
    end

    def reset_checkpoint &block
      # TODO
    end
    
    def self.root
      return @root if @root
      @root = Track.find_or_create(:root => true)
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